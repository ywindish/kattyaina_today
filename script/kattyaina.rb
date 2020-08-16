
require_relative '../lib/kattyaina_bot'

KattyainaBot.new(
  ENV['MASTODON_URL'],
  ENV['MASTODON_TOKEN'],
  ENV['TARGET_DATE'],
  ENV['DRY_RUN']
).run
