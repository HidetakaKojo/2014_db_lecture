#!/usr/bin/env ruby
# coding: utf-8

require 'mysql2-cs-bind'
require 'digest/sha2'
require 'yaml'

config = ::YAML.load_file(File.dirname(__FILE__) + "/../../config/database.yaml")['mysql']
mysql = Mysql2::Client.new(
  host:      config["host"],
  port:      config["port"],
  username:  config["username"],
  password:  config["password"],
  database:  config["db"],
  socket:    config["socket"],
  reconnect: true
)

b000 = mysql.xquery("select id from users where username = ?", 'b000').first
ba00 = mysql.xquery("select id from users where username = ?", 'ba00').first
b010 = mysql.xquery("select id from users where username = ?", 'b010').first

bodys = []
DATA.each_line do |line|
  bodys.push line.chomp
end

#[*b000['id']..(ba00["id"]-1)].each do |from_id|
#  [*b000['id']..(ba00["id"]-1)].sample(100).each do |to_id|
#    next if to_id == from_id
#    mysql.xquery("INSERT INTO friends(`from_id`, `to_id`, `status`, `created_at`, `updated_at`) values(?, ?, 0, NOW(), NOW())", from_id, to_id)
#  end
#  mysql.xquery("REPLACE user_logins set last_access = NOW(), user_id = ?", from_id);
#  time = Time.new
#  100.times do |i|
#    body = bodys[rand(bodys.size)]
#    posttime = (time + i * 100).strftime("%Y-%m-%d %H:%M:%S")
#    mysql.xquery("INSERT INTO echos(`user_id`, `body`, `created_at`, `updated_at`) values(?, ?, ?, ?)", from_id, body, posttime, posttime);
#  end
#end
[*b000['id']..(b010["id"]-1)].each do |from_id|
  puts from_id
  time = Time.new - 7200
  9900.times do |i|
    body = bodys[rand(bodys.size)]
    posttime = (time + i).strftime("%Y-%m-%d %H:%M:%S")
    mysql.xquery("INSERT INTO echos(`user_id`, `body`, `created_at`, `updated_at`) values(?, ?, ?, ?)", from_id, body, posttime, posttime);
  end
end

__END__
I need plenty of rest in case tomorrow is a great day..
Keep looking up.. That’s the secret of life..
You play with the cards you’re dealt.. Whatever that means
Dogs could fly if we wanted to..
If you want something done right, you should do it yourself!
We all have our hang-ups!
I climbed over the fence, but I was still in the world!
A watched supper dish never fills!
