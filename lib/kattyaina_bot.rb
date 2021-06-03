# kattyaina_bot.rb
#
require 'json'
require 'uri'
require 'net/http'
require 'date'
require 'pp'
require 'logger'
require 'mastodon' # https://github.com/tootsuite/mastodon-api

class KattyainaBot

  attr_accessor :base_url, :token, :target_date, :dry_run

  def initialize(base_url, token, target_date=nil, dry_run=nil)
    @logger = Logger.new(STDOUT)

    @target_date = begin
      Date.parse(target_date)
    rescue Exception => e
      Date.today
    end

    @base_url = base_url
    @token = token
    @dry_run = dry_run

    @logger.info("target date: #{@target_date}")
  end

  def run
    json = get_schedules_json
    items = pickup_game_on_sale(json)
    message = build_toot_message(items)
    toot(message)
  end

  def get_schedules_json
    # TODO think url generation algorizm F,A,D..
    # F=12-5, D=6,9-11, A=?
    query_date = @target_date.strftime('%YD%m')
    url = %Q(https://search.nintendo.jp/nintendo_soft/search.json?opt_sshow=1&xopt_ssitu[]=sales_termination&fq=sodate_s%3A%5B#{query_date}%20TO%20*%5D&limit=300&page=1&sort=sodate%20asc%2Chards%20asc%2Csform_s%20asc%2Ctitle%20asc&opt_sche=1)
    @logger.info("target url: #{url}")

    uri = URI.parse(url)
    json = Net::HTTP.get(uri)

    JSON.parse(json)
  end

  def pickup_game_on_sale(json)
    sdate_str = sprintf('%d.%d.%d', @target_date.year, @target_date.month, @target_date.day)
    items = []
    json['result']['items'].each do |item|
      if item['sdate'].to_s != sdate_str
        next
      end
      items.push item['title']
    end
    items
  end

  def build_toot_message(items)
    message = ''
    if items.empty?
      # message = '本日発売のゲームが見つかりませんでした。安心して積みゲーを崩せるかも。'
      @logger.info("result message: empty.")
    else
      message = "本日発売のゲームはこちらです。カッチャイナー\n\n#{items.join("\n")}"
      message = message.slice(0,498) + '..' if message.size > 500 # too large
      @logger.info("result message: #{message}")
    end

    message
  end

  def toot(message)
    return if @dry_run || message == ''

    client = Mastodon::REST::Client.new(base_url: @base_url, bearer_token: @token)
    client.create_status(message)
  end

end
