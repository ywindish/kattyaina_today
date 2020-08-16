require 'spec_helper'

RSpec.describe KattyainaBot do

  let (:base_url) {
    'https://funayurei.windish.jp'
  }
  let (:token) {
    'xxxxx'
  }
  let (:dry_run) {
    nil
  }
  let (:target_date) {
    '2020.8.13'
  }

  it "base_url" do
    expect(KattyainaBot.new(base_url, token).base_url).to eq base_url
  end

end
