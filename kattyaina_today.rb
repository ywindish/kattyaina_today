# kattyaina_today.rb
# TODO ちゃんと spec を書けるようにしよう
#
require 'json'
require 'uri'
require 'net/http'
require 'date'
require 'pp'
require 'mastodon' # https://github.com/tootsuite/mastodon-api

class KattyainaBot

  def initialize(target_date = Date.today)
    @target_date = target_date
  end

  def run
    json = get_schedules_json
    items = pickup_game_on_sale(json)
    message = build_toot_message(items)
    toot(message)
  end

  def get_schedules_json
    query_date = @target_date.strftime('%YF%m')
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
    JSON.parse(json)
  end

  def pickup_game_on_sale(json)
    sdate_str = sprintf('%d.%d.%d', @target_date.year, @target_date.month, @target_date.day)
    items = []
    json['result']['items'].each do |item|
      if item['sdate'] != sdate_str
        next
      end
      # 長すぎてtootできないことがあるのでタイトルだけにして様子を見る。current_price は nil のこともあるので注意
      #items.push sprintf('%s: %s %d円', item['maker'], item['title'], item['current_price'])
      items.push item['title']
    end
    items
  end

  def build_toot_message(items)
    message = ''
    if items.empty?
      message = '本日発売のゲームが見つかりませんでした。安心して積みゲーを崩せるかも。'
    else
      message = "本日発売のゲームはこちらです。カッチャイナー\n\n#{items.join("\n")}"
    end
    message = message.slice(0,498) + '..' if message.size > 500 # 長過ぎるときは省略
    pp message
  end

  def toot(message)
    client = Mastodon::REST::Client.new(base_url: 'https://funayurei.windish.jp', bearer_token: ENV['MASTODON_TOKEN'])
    client.create_status(message)
  end

end

KattyainaBot.new.run
