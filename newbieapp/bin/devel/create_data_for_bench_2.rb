#!/usr/bin/env ruby
# coding: utf-8

require 'mysql2-cs-bind'
require 'digest/sha2'
require 'yaml'

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

a000 = mysql.xquery("select id from users where username = ?", 'a000').first
b000 = mysql.xquery("select id from users where username = ?", 'b000').first

[*a000['id']..(b000["id"]-1)].each do |to_id|
  [*a000['id']..(b000["id"]-1)].sample(300).each do |from_id|
    next if to_id == from_id
    mysql.xquery("INSERT INTO friends(`to_id`, `from_id`, `status`, `created_at`, `updated_at`) values(?, ?, 0, NOW(), NOW())", from_id, to_id)
  end
end
