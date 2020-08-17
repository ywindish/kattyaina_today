require 'spec_helper'

RSpec.describe KattyainaBot do

  let (:base_url) {
    'https://funayurei.windish.jp'
  }
  let (:token) {
    'xxxxx'
  }
  let (:dry_run) {
    1
  }
  let (:target_date) {
    '2020.8.13'
  }

  it "base_url" do
    expect(KattyainaBot.new(base_url, token).base_url).to eq base_url
  end

  it "token" do
    expect(KattyainaBot.new(base_url, token).token).to eq token
  end

  it "dry_run is default" do
    expect(KattyainaBot.new(base_url, token).dry_run).to eq nil
  end

  it "dry_run" do
    expect(KattyainaBot.new(base_url, token, nil, dry_run).dry_run).to eq 1
  end

  it "target_date is default" do
    expect(KattyainaBot.new(base_url, token).target_date.is_a? Date).to eq true
  end

  it "target_date" do
    expect(KattyainaBot.new(base_url, token, target_date).target_date).to eq Date.parse(target_date)
  end

end
