require 'httparty'
require 'hashie'
require 'base64'
require 'addressable/uri'


module Kraken
  class Client
    include HTTParty

    def initialize(api_key=nil, api_secret=nil, options={})
      @api_key      = api_key
      @api_secret   = api_secret
      @api_version  = options[:version] ||= '0'
      @base_uri     = options[:base_uri] ||= 'https://api.kraken.com'
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
      url = @base_uri + '/' + @api_version + '/public/' + method
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

    def open_orders(opts={})
      post_private 'OpenOrders', opts
    end

    def query_orders(opts={})
      post_private 'QueryOrders', opts
    end

    def trade_history(opts={})
      post_private 'TradesHistory', opts
    end

    def query_trades(tx_ids, opts={})
      opts['txid'] = tx_ids
      post_private 'QueryTrades', opts
    end

    def open_positions(tx_ids, opts={})
      opts['txid'] = tx_ids
      post_private 'OpenPositions', opts
    end

    def ledgers_info(opts={})
      post_private 'Ledgers', opts
    end

    def query_ledgers(ledger_ids, opts={})
      opts['id'] = ledger_ids
      post_private 'QueryLedgers', opts
    end

    def trade_volume(asset_pairs)
      opts['pair'] = asset_pairs
      post_private 'TradeVolume', opts
    end

    #### Private User Trading (Still experimental!) ####

    def add_order(opts={})
      required_opts = %w{pair, type, ordertype, volume}
      opts.keys.each do |key|
        unless required_opts.include?(1) 
          raise "Required options, not given. Input must include #{required_opts}"
        end
      end
      post_private 'AddOrder', opts
    end

    #######################
    #### Generate Signed ##
    ##### Post Request ####
    #######################

    private

      def post_private(method, opts={})
        opts['nonce'] = nonce
        post_data = encode_options(opts)

        headers = {
          'API-Key' => @api_key,
          'API-Sign' => generate_signature(method, post_data, opts) 
        }

        url = @base_uri + url_path(method)
        r = self.class.post(url, { headers: headers, body: post_data }).parsed_response
        r['error'].empty? ? r['result'] : r['error']
      end

      def nonce
        len = 16
        SecureRandom.random_number(10 ** len).to_s.ljust(len, '0')
      end

      def encode_options(opts)
        uri = Addressable::URI.new
        uri.query_values = opts
        uri.query
      end

      def generate_signature(method, post_data, opts={})
        key = Base64.decode64(@api_secret)
        message = generate_message(method, opts, post_data)
        generate_hmac(key, message)
      end

      def generate_message(method, opts, data)
        digest = OpenSSL::Digest.new('sha256', opts['nonce'] + data).digest
        url_path(method) + digest
      end

      def generate_hmac(key, message)
        Base64.strict_encode64(OpenSSL::HMAC.digest('sha512', key, message))
      end

      def url_path(method)
        '/' + @api_version + '/private/' + method
      end

  end
end
