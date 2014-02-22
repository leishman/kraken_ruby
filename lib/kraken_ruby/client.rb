require 'kraken_ruby/version'
require 'httparty'

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

    def server_time
      get_public 'Time'
    end

    def assets(opts={})
      get_public 'Assets'
    end

    def asset_pairs(opts={})
      get_public 'AssetPairs', opts
    end

    def ticker(pairs) # takes string of comma delimited pairs
      opts = { 'pair' => pairs }
      get_public 'Ticker', opts
    end
    
    def order_book(pair, opts={})
      opts['pair'] = pair
      get_public 'Depth', opts
    end

    def trades(pair, opts={})
      opts['pair'] = pair
      get_public 'Trades', opts
    end

    def spread(pair, opts={})
      opts['pair'] = pair
      get_public 'Spread', opts
    end

    def get_public(method, opts={})
      url = @base_uri + @api_version + '/public/' + method
      r = self.class.get(url, query: opts)
      hash = Hashie::Mash.new(JSON.parse(r.body))
      hash[:result]
    end

    ###############################
    ###### Private Data: ##########
    ### Coming in Next Release ####
    ###############################

  end
end
