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

profile = DATA.read

char_set = [*'0'..'9', *'a'..'z']
num_set = [*'0'..'9']
char_set.each do |i1|
  char_set.each do |i2|
    char_set.each do |i3|
      num_set.each do |i4|
        name = i1 + i2 + i3 + i4
        salt = Digest::SHA256.hexdigest rand(100000000).to_s
        password =  Digest::SHA256.hexdigest(salt + name)
        mysql.xquery("INSERT INTO users(`username`, `password`, `salt`, `profile`, `created_at`, `updated_at`) values(?, ?, ?, ?, NOW(), NOW())", name, password, salt, profile) 
        ret = mysql.xquery("select last_insert_id() as from users").first
        mysql.xquery("REPLACE user_logins set last_access = NOW(), user_id = ?", ret["id"]);
      end
    end
  end
end

__END__
既存のスキーマとクエリを改善することで性能向上させてください。
インデックスを適切にはりましょう。
covering indexにできるように気をつけましょう。
b+treeの構造を頭に浮かべてどのようなインデックスが有効に使われるか考えましょう
キャッシュする価値があるものはキャッシュしていきましょう。
キャッシュのリソースは有限です。何を積むべきか検討しましょう。
余裕がある人はechoにlike機能を追加しましょう。
更に余裕がある人はユーザについているlike数でランキングを出す方法を検討しましょう。
更に余裕がある人はfeedsの取得の仕方について考察をお願いします。
ここまでやれば課題+宿題は終わりです。
