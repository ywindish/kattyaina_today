# kattyaina_today.rb
# TODO ちゃんと spec を書けるようにしよう
#
require 'json'
require 'uri'
require 'net/http'
require 'date'
require 'pp'
require 'mastodon' # https://github.com/tootsuite/mastodon-api

d = Date.today

# get schedules
query_date = d.strftime('%YB%m')
url = %Q(https://search.nintendo.jp/nintendo_soft/search.json?opt_sshow=1&xopt_ssitu[]=sales_termination&fq=sodate_s%3A%5B#{query_date}%20TO%20*%5D&limit=300&page=1&sort=sodate%20asc%2Chards%20asc%2Csform_s%20asc%2Ctitle%20asc&opt_sche=1)
uri = URI.parse(url)
json = Net::HTTP.get(uri)
# File.open(__dir__ + '/spec/result.json', 'w') do |f|
#   f.print json # backup
# end
# TODO テスト用。rspec をかいておきたいところ
# json = File.open(__dir__ + '/spec/result.json') do |f|
#   f.read
# end
result = JSON.parse(json)

# pickup game on sale at today
today_str = sprintf('%d.%d.%d', d.year, d.month, d.day)
today_items = []
result['result']['items'].each do |item|
  if item['sdate'] != today_str
    next
  end
  # TODO 長すぎてtootできないことがあるのでタイトルだけにして様子を見る。current_price は nil のこともあるので注意
  #today_items.push sprintf('%s: %s %d円', item['maker'], item['title'], item['current_price'])
  today_items.push item['title']
end

# building toot message
message = ''
if today_items.empty?
  message = '本日発売のゲームが見つかりませんでした。安心して積みゲーを崩せるかも。'
else
  message = <<TOOT
本日発売のゲームはこちらです。カッチャイナー

#{today_items.join("\n")}
TOOT
end
message = message.slice(0,498) + '..' if message.size > 500 # 長過ぎるときは省略
pp message

# toot!
client = Mastodon::REST::Client.new(base_url: 'https://funayurei.windish.jp', bearer_token: ENV['MASTODON_TOKEN'])
client.create_status(message)
