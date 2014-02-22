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
      urlpath = '/' + @api_version + '/private/' + method

      key_b64 = Base64.decode64(@api_secret)
      opts['nonce'] = Time.now.to_i * 10_000_000_000

      post_data = encode_options(opts)
      opt_digest = OpenSSL::Digest.new('sha256', opts['nonce'].to_s + post_data).digest
      message = urlpath + opt_digest
      digest = OpenSSL::Digest::Digest.new('sha512')
      signature = OpenSSL::HMAC.digest(digest, key_b64, message)

      headers = {
        'User-Agent' => 'leishman',
        'API-Key' => @api_key,
        'API-Sign' => Base64.encode64(signature)
      }

      url = @base_uri + @api_version + '/private/' + method
      self.class.post(url, { headers: headers, body: post_data })
    end

  end
end
