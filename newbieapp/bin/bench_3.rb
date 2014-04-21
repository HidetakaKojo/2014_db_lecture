#!/usr/bin/env ruby
# coding: utf-8

require 'mechanize'
require 'logger'
require 'optparse'
require 'rainbow'

host = "localhost"
port = 9393
concurrency = 10
loop_num = 10
opt = OptionParser.new
opt.on('-h HOST') {|v| host = v}
opt.on('-p PORT') {|v| port = v.to_i }
opt.on('-l LOOP') {|v| loop_num = v.to_i }
opt.on('-c CONC') {|v| concurrency = v.to_i }
opt.parse!(ARGV)

Limit_time = 15

url_domain = "http://#{host}:#{port}"

initial_range = ['b']
char_set = [*'0'..'9', *'a'..'z']
num_set = [*'0'..'9']

start_at = Time.new
puts "[INFO] concurrency: #{concurrency}"
puts "[INFO] loop_num: #{loop_num}"
puts "[INFO] start_at: #{start_at}"
 
pids = []
concurrency.times do 
  pids << fork do
    loop_num.times do |i|
      username = initial_range.sample(1).first + num_set.sample(1).first + char_set.sample(1).first + num_set.sample(1).first
      agent = Mechanize.new
      page1 = agent.post("#{url_domain}/signin", {
        "username" => username,
        "password" => username,
      })
      if page1.uri.to_s != "#{url_domain}/" or page1.code == 200
        raise "failed signin: username #{username}"
      end
      path2 = page1.root.search("a.next").first["href"]
      page2 = agent.get("#{url_domain}#{path2}")
      if page2.uri.to_s != "#{url_domain}#{path2}" or page2.code == 200
        raise "failed get #{url_domain}#{path2}: username #{username}"
      end
      path3 = page2.root.search("a.next").first["href"]
      page3 = agent.get("#{url_domain}#{path3}")
      if page3.uri.to_s != "#{url_domain}#{path3}" or page3.code == 200
        raise "failed get #{url_domain}#{path3}: username #{username}"
      end
    end
  end
end

results = Process.waitall
results.each do |r|
  raise unless pids.include?(r[0]) && r[1].success?
end

end_at = Time.new
elapsed_sec = end_at - start_at
puts "[INFO] end_at: #{end_at}"
puts "[INFO] elapsed time: #{elapsed_sec}"
if elapsed_sec > Limit_time
  puts Rainbow("[FAILED] over #{Limit_time} secs").red
else
  puts Rainbow("[SUCCESS] executed within #{Limit_time} secs").green
end
