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

    ######################
    ##### Private Data ###
    ######################

    def balance(opts={})
      post_private 'Balance', opts
    end

    def trade_balance(opts={})
      post_private 'TradeBalance', opts
    end

    def get_public(method, opts={})
      url = @base_uri + @api_version + '/public/' + method
      r = self.class.get(url, query: opts)
      hash = Hashie::Mash.new(JSON.parse(r.body))
      hash[:result]
    end

    def encode_options(opts)
      uri = Addressable::URI.new
      uri.query_values = opts
      uri.query
    end

      #### IN PROGRESS #######
    def post_private(method, opts={})

      # define path

      urlpath = '/' + @api_version + '/private/' + method

      # create nonce

      # opts['nonce'] = Time.now.to_i.to_s.ljust(16,'0')
      opts['nonce'] = '1393181048417996'

      # encode post data (nonce only)

      post_data = encode_options(opts)

      # decode base 64 key

      key = Base64.decode64(@api_secret)

      # create digest of nonce + post data

      opt_digest = OpenSSL::Digest.new('sha256', opts['nonce'] + post_data).digest

      # create message: urlpath + SHA256(nonce + post_data)

      message = urlpath + opt_digest

      # create auth code

      signature = Base64.encode64("#{OpenSSL::HMAC.digest('sha512', key, message)}").strip
      
      headers = {
        'API-Key' => @api_key,
        'API-Sign' => signature
      }
      
      url = @base_uri + @api_version + '/private/' + method
      self.class.post(url, { headers: headers, body: post_data })
    end

  end
end
