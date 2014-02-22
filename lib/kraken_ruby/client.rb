require "kraken_ruby/version"
require 'httparty'
require 'securerandom'
require 'hashie'
require 'Base64'
require 'open-uri'
require 'addressable/uri'

module Kraken
  class Client
    include HTTParty

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

    # must pass comma separated list of asset pairs

    def ticker(opts={})
      get_public 'Ticker', opts
    end

    # must give asset pair
    # optional count
    # example opts: { pair: 'LTCXRP', count: 5}
    
    def order_book(opts={})
      get_public 'Depth', opts
    end

    # must pass asset pair

    def trades(opts={})
      get_public 'Trades', opts
    end

    # must pass asset pair

    def spread(opts={})
      get_public 'Spread', opts
    end

    def get_public(method, opts={})
      url = @base_uri + @api_version + '/public/' + method
      r = self.class.get(url, query: opts)
      hash = Hashie::Mash.new(JSON.parse(r.body))
      hash[:result]
    end
  end
end
