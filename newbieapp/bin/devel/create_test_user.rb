#!/usr/bin/env ruby

require 'mysql2-cs-bind'
require 'digest/sha2'
require 'yaml'

name = ARGV[0]

config = ::YAML.load_file(File.dirname(__FILE__) + "/../config/database.yaml")['mysql']
mysql = Mysql2::Client.new(
  host:      config["host"],
  port:      config["port"],
  username:  config["username"],
  password:  config["password"],
  database:  config["db"],
  socket:    config["socket"],
  reconnect: true
)
salt = Digest::SHA256.hexdigest rand(100000000).to_s
password =  Digest::SHA256.hexdigest(salt + name)
profile = DATA.read
user = xquery("SELECT * FROM users where username = ?", name).first
exit "duplicate username" if user
mysql.xquery("INSERT INTO users(`username`, `password`, `salt`, `profile`, `created_at`, `updated_at`) values(?, ?, ?, NOW(), NOW())", name, password, salt, profile)

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
