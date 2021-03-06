require 'almanack/server'

class CanterburySoftwareCluster
  MAX_AGE_IN_SECONDS = 30 * 60

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    headers['Cache-Control'] = "max-age=#{MAX_AGE_IN_SECONDS}"
    headers['Access-Control-Allow-Origin'] = "*"
    [status, headers, response]
  end
end

Almanack.config do |c|
  c.title = "Christchurch Tech Events"
  c.theme = "legacy" # available: legacy
  c.days_lookahead = 30

  # Caching
  c.cache_responses = true
  c.cache_expiry = 900 # seconds

  meetup_key = ENV['MEETUP_API_KEY'] || raise("MEETUP_API_KEY env var missing")

  meetup_groups = %w(
    The-Foundation-Christchurch
    WikiHouse-NZ
    Christchurch-Net-User-Group
    SERVER-User-Group-Christchurch-New-Zealand
    CHC-JS
    Christchurch-Bitcoin-Meetup
    NZPUG-Christchurch
    Design-Thinking-Group
    Think-Open-Data
    Crypto-currency-and-Blockchain-Policy
    SilverStripe-Christchurch-Meetup
    OWASP-New-Zealand-Chapter-Christchurch
    Christchurch-Test-Professionals-Network
    Christchurch-Agile-Professionals-Network
    Women-in-IT-Chch
    Lean-Startup-Christchurch
    Christchurch-Ruby-Group
    The-Valley-in-Christchurch
  )

  meetup_groups.each do |group|
    c.add_meetup_group group_urlname: group, key: meetup_key
  end

  c.add_ical_feed ENV['SHARED_GCAL_URL'] || raise("SHARED_GCAL_URL env var missing")
end

use CanterburySoftwareCluster
run Almanack::Server
