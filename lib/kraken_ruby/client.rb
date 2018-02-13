require 'base64'
require 'securerandom'
require 'addressable/uri'
require 'httparty'
require 'hashie'

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

    def ohlc(pair, opts={})
      opts['pair'] = pair
      get_public 'OHLC', opts
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

    def closed_orders(opts={})
      post_private 'ClosedOrders', opts
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

    #### Private User Trading ####

    def add_order(opts={})
      required_opts = %w{ pair type ordertype volume }
      leftover = required_opts - opts.keys.map(&:to_s)
      if leftover.length > 0
        raise ArgumentError.new("Required options, not given. Input must include #{leftover}")
      end
      post_private 'AddOrder', opts
    end

    def cancel_order(txid)
      opts = { txid: txid }
      post_private 'CancelOrder', opts
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

      # Generate a 64-bit nonce where the 48 high bits come directly from the current
      # timestamp and the low 16 bits are pseudorandom. We can't use a pure [P]RNG here
      # because the Kraken API requires every request within a given session to use a
      # monotonically increasing nonce value. This approach splits the difference.
      def nonce
        high_bits = (Time.now.to_f * 10000).to_i << 16
        low_bits  = SecureRandom.random_number(2 ** 16) & 0xffff
        (high_bits | low_bits).to_s
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
