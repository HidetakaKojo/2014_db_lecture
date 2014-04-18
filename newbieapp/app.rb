#coding: utf-8

require 'sinatra/base'
require 'sinatra/param'
require 'mysql2-cs-bind'
require 'dalli'
require 'rack/session/dalli'
require 'yaml'
require 'json'
require 'digest/sha2'

class NewbieApp < Sinatra::Base
  enable :method_override
  use Rack::Session::Dalli,
    memcache_server:  'localhost:11211',
    cache:             Dalli::Client.new,
    namespace:        'signin.session'

  Row_count = 50

  helpers Sinatra::Param
  helpers do
    include Rack::Utils; alias_method :h, :escape_html 
    def hbr(str)
      str = h(str)
      str.gsub(/\r\n|\r|\n/, "<br />")
    end

    def mysql_main
      return $mysql_main if $mysql_main
      config = ::YAML.load_file(File.dirname(__FILE__) + "/config/database.yaml")['mysql_main']
      $mysql_main = Mysql2::Client.new(
        host:      config["host"],
        port:      config["port"],
        username:  config["username"],
        password:  config["password"],
        database:  config["db"],
        socket:    config["socket"],
        reconnect: true
      )
    end
    def mysql_echo
      return $mysql_echo if $mysql_echo
      config = ::YAML.load_file(File.dirname(__FILE__) + "/config/database.yaml")['mysql_echo']
      $mysql_echo = Mysql2::Client.new(
        host:      config["host"],
        port:      config["port"],
        username:  config["username"],
        password:  config["password"],
        database:  config["db"],
        socket:    config["socket"],
        reconnect: true
      )
    end
    def memcached
      return $dc if $dc
      $dc = Dalli::Client.new("localhost:11211", {namespace: 'newbie.cache', compress: true})
    end

    def require_signin
      unless is_login
        redirect "/signin"
        exit
      end
    end
    def is_login
      session["id"]? true: false
    end
    def get_user_by_username(username)
      mysql_main.xquery("SELECT * FROM users WHERE username=?", username).first
    end
    def get_username(user_id)
      user = mysql_main.xquery("SELECT * FROM users WHERE id=?", user_id).first
      username = user ? user["username"] : nil
    end
  end

  error 400 do
    'bad request'
  end

  post '/echos' do
    require_signin
    param :body, String, required: true, max_length: 140
    param :token, String, required: true
    halt 400 if params['token'] != session['token']
    mysql_echo.xquery("insert into echos(`user_id`, `body`, `created_at`, `updated_at`) values(?, ?, NOW(), NOW())", session['id'], params['body'])
    redirect '/'
  end

  delete '/echos' do
    require_signin
    param :token, String, required: true
    param :id, Integer, required: true
    halt 400 if params['token'] != session['token']
    mysql_echo.xquery("delete from echos where id = ? AND user_id = ?", params["id"], session["id"])
    redirect '/'
  end

  get '/friends' do
    require_signin
    @checking = mysql_main.xquery("select * from friends JOIN users ON friends.to_id = users.id JOIN user_logins ON users.id = user_logins.user_id where friends.from_id = ?", session["id"])
    @checked = mysql_main.xquery("select * from friends JOIN users ON friends.from_id = users.id JOIN user_logins ON users.id = user_logins.user_id where friends.to_id = ?", session["id"]).each do |friend|
      friend["is_checking"] = mysql_main.xquery("select * from friends where from_id = ? AND to_id = ?", session["id"], friend["id"]).first ? true : false
    end
    erb :friends
  end

  get '/friends/:username' do
    require_signin
    param :username, String, required: true
    @friend = get_user_by_username(params['username'])
    redirect '/' if @friend["id"] == session["id"]
    @is_checking = mysql_main.xquery("select * from friends where from_id = ? AND to_id = ?", session["id"], @friend["id"]).first ? true : false
    @is_checked = mysql_main.xquery("select * from friends where from_id = ? AND to_id = ?", @friend["id"], session["id"]).first ? true : false

    @echos = mysql_echo.xquery("select * from echos where user_id = ? order by created_at desc limit #{Row_count}", @friend["id"])
    erb :friend
  end

  post '/friends/:username' do
    require_signin
    param :from_id, Integer, required: true
    param :username, String, required: true
    param :token, String, required: true
    halt 400 if params['token'] != session['token']
    user = get_user_by_username(params["username"])
    mysql_main.xquery("INSERT INTO friends(`from_id`, `to_id`, `status`, `created_at`, `updated_at`) values(?, ?, ?, NOW(), NOW())", params["from_id"], user["id"], 0)
    redirect "/friends/#{user["username"]}"
  end

  delete '/friends/:to_username' do
    require_signin
    param :from_id, Integer, required: true
    param :to_username, String, required: true
    param :token, String, required: true
    halt 400 if params['token'] != session['token']
    user = get_user_by_username(params["to_username"])
    mysql_main.xquery("DELETE FROM friends WHERE from_id = ? AND to_id = ?", params["from_id"], user["id"])
    redirect "/friends"
  end

  get '/' do
    require_signin
    param :page, Integer
    row_count =  Row_count
    @page = params['page'] || 1
    offset = (@page - 1) * row_count
    users = mysql_main.xquery("select * from friends where friends.from_id = ?", session["id"]).map do |user|
      user["to_id"]
    end
    users.push session["id"]
    @echos = mysql_echo.xquery("select * from echos where user_id IN (?) order by created_at desc limit #{offset}, #{row_count}", users).each do |echo|
      echo["username"] = get_username(echo["user_id"])["username"]
    end
    erb :index
  end

  get '/signin' do
    redirect '/' if session['id']
    erb :signin
  end

  post '/signin' do
    param :username, String, required: true
    param :password, String, required: true
    user = get_user_by_username(params["username"])
    if user && user["password"] == Digest::SHA256.hexdigest(user["salt"] + params["password"])
      session.clear
      session["id"] = user["id"]
      session["token"] = Digest::SHA256.hexdigest rand(100000000).to_s
      mysql_main.xquery("REPLACE user_logins SET last_access=NOW(), user_id=?", user["id"])
      redirect '/'
    else
      redirect '/signin'
    end
  end

  post '/signout' do
    require_signin
    param :token, String, required: true
    halt 400 if params['token'] != session['token']
    session.destroy
    redirect '/signin'
  end

  get '/regist' do
    redirect '/' if session['id']
    erb :regist
  end

  post '/regist' do
    redirect '/' if session['id']
    param :username, String, required: true
    param :password, String, required: true, min_length: 3
    user = get_user_by_username(params["username"])
    halt 400, "duplicate username" if user
    salt = Digest::SHA256.hexdigest rand(100000000).to_s
    password = Digest::SHA256.hexdigest(salt + params["password"])
    mysql_main.xquery("INSERT INTO users(`username`, `password`, `salt`, `created_at`, `updated_at`) values(?, ?, ?, NOW(), NOW())", params["username"], password, salt)
    user = get_user_by_username(params["username"])
    session.clear
    session["id"] = user["id"]
    session["token"] = Digest::SHA256.hexdigest rand(100000000).to_s
    mysql_main.xquery("REPLACE user_logins SET last_access=NOW(), user_id=?", user["id"])
    redirect '/'
  end
end
