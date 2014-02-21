require 'httparty'
require 'securerandom'
require 'hashie'
require 'Base64'
require 'open-uri'
require 'addressable/uri'

require 'debugger'

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

    def post_private(method, opts={})
      urlpath = '/' + @api_version + '/private/' + method

      key_b64 = Base64.decode64(@api_secret)
      opts['nonce'] = Time.now.to_i * 10_000_000_000
      # opts['otp'] = ''

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
      r = self.class.post(url, { headers: headers, body: post_data })

    end

  end
end

