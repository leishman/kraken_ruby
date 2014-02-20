require 'httparty'
require 'securerandom'
require 'hashie'
require 'Base64'
require 'open-uri'

module Kraken
  class Client
    include HTTParty
      # check verification

    def initialize(api_key=nil, api_secret=nil, options={})
      @api_key      = api_key
      @api_secret   = api_secret
      @api_version  = options[:version] ||= '0'
      @base_uri     = options[:base_uri] ||= 'https://api.kraken.com/'
    end

    ###########################
    ###### Public Data ########
    ###########################

    # gets kraken server time
    # returns object with rfc1123 or UNIX time
    def server_time
      get_public 'Time'
    end

    def assets(opts={})
      get_public 'Assets'
    end

    def asset_pairs(opts={})
      get_public 'AssetPairs', opts
    end

    # must give comma separated list of asset pairs
    def ticker(opts={})
      get_public 'Ticker', opts
    end

    # must give asset pair
    # optional count
    # example opts: { pair: 'LTCXRP', count: 5}
    def order_book(opts={})
      get_public 'Depth', opts
    end

    # must give asset pair
    def trades(opts={})
      get_public 'Trades', opts
    end

    def spread(opts={})
      get_public 'Spread', opts
    end

    def make_request verb, opts={}

    end

    def get_public(method, opts={})
      url = @base_uri + @api_version + '/public/' + method
      r = self.class.get(url, query: opts)
      hash = Hashie::Mash.new(JSON.parse(r.body))
      hash[:result]
    end

    def post_private(path, opts={})
      urlpath = '/' + @api_version + '/private/' + method
      key = Base64.encode64(@api_secret)
      opts['nonce'] = Time.now.to_i * 1000
      post_data = JSON.encode(opts)
      message = urlpath + OpenSSL::Digest.new('sha256', opts['nonce'].to_s + post_data)
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha512'), key, message)

      headers = {
        'API-Key': @api_key,
        'API-Sign': signature
      }

      post_data = {
        nonce: opts['nonce']
      }
    end

  end
end

kraken = Kraken::Client.new
# p kraken.server_time
# p kraken.assets
# p kraken.asset_pairs({info: 'margin'})
# p kraken.ticker({ pair: 'LTCXRP, XXBTZEUR' })
# p kraken.order_book({ pair: 'LTCXRP' })

# p kraken.trades({ pair: 'LTCXRP' })
p kraken.spread({ pair: 'LTCXRP' })
