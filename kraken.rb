require 'httparty'
require 'securerandom'
require 'hashie'

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

    def get_public(path, opts={})
      url = @base_uri + @api_version + '/public/' + path
      p url
      r = self.class.get(url, query: opts)
      hash = Hashie::Mash.new(JSON.parse(r.body))
      hash[:result]
    end

    def post_private(path, opts={})

    end

  end
end

kraken = Kraken::Client.new
p kraken.server_time
# p kraken.assets
# p kraken.asset_pairs({info: 'margin'})
# p kraken.ticker({ pair: 'LTCXRP, XXBTZEUR' })
p kraken.order_book({ pair: 'LTCXRP' })