require 'kraken_ruby'

describe Kraken::Client do

	# YOU MUST SET ENVIRONMENT VARIABLES KRAKEN_API_KEY AND
  # KRAKEN_API_SECRET TO TEST PRIVATE DATA QUERIES. PRIVATE
  # TESTS WILL FAIL OTHERWISE.

  API_KEY    = ENV['KRAKEN_API_KEY']
  API_SECRET = ENV['KRAKEN_API_SECRET']

	before :each do
		sleep 0.3 # to prevent rapidly pinging the Kraken server
	end

	let(:kraken){Kraken::Client.new(API_KEY, API_SECRET)}

	context "public data" do
		it "gets the proper server time" do
			kraken_time = DateTime.parse(kraken.server_time.rfc1123)
			utc_time = Time.now.getutc
			expect(kraken_time.day).to eq utc_time.day
			expect(kraken_time.hour).to eq utc_time.hour
		end

		it "gets list of tradeable assets" do
			expect(kraken.assets).to respond_to :XXBT
		end

		it "gets list of asset pairs" do
			expect(kraken.asset_pairs).to respond_to :XXBTZEUR
		end

		it "gets public ticker data for given asset pairs" do
			result = kraken.ticker('XXBTZEUR, XXBTZGBP')
			expect(result).to respond_to :XXBTZEUR
			expect(result).to respond_to :XXBTZGBP
		end

		it "gets order book data for a given asset pair" do
			order_book = kraken.order_book('XXBTZEUR')
			expect(order_book.XXBTZEUR).to respond_to :asks
		end

		it "gets an array of trades data for a given asset pair" do
			trades = kraken.trades('XXBTZEUR')
			expect(trades.XXBTZEUR).to be_instance_of(Array)
		end

		it "gets an array of spread data for a given asset pair" do
			spread = kraken.spread('XXBTZEUR')
			expect(spread.XXBTZEUR).to be_instance_of(Array)
		end
	end

	context "private data" do # More tests to come
		it "gets the user's balance" do
			expect(kraken.balance).to be_instance_of(Hash)
		end

    it "uses a 64 bit nonce" do
      nonce = kraken.send :nonce
      expect(nonce.to_i.size).to eq(8)
    end

    it "gets deposit methods" do
      result = kraken.deposit_methods("XXBT").first
      expect(result).to have_key 'method'
      expect(result).to have_key 'limit'
      expect(result).to have_key 'fee'
    end

    it "gets deposit status" do
      results = kraken.deposit_status(asset: "XXBT")
      expect(results).to be_instance_of(Array)
      if result = results.first
        expect(result).to have_key 'method'
        expect(result).to have_key 'aclass'
        expect(result).to have_key 'refid'
        expect(result).to have_key 'txid'
        expect(result).to have_key 'info'
        expect(result).to have_key 'amount'
        expect(result).to have_key 'fee'
        expect(result).to have_key 'status'
        expect(result).to have_key 'time'
      end
    end

    it "gets withdraw status" do
      results = kraken.withdraw_status(asset: "XXBT")
      pp results
      expect(results).to be_instance_of(Array)
      if result = results.first
        expect(result).to have_key 'method'
        expect(result).to have_key 'aclass'
        expect(result).to have_key 'refid'
        expect(result).to have_key 'txid'
        expect(result).to have_key 'info'
        expect(result).to have_key 'amount'
        expect(result).to have_key 'fee'
        expect(result).to have_key 'status'
        expect(result).to have_key 'time'
      end
    end
  end
end
