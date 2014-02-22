require 'fakeweb'
require_relative '../lib/kraken_ruby/client'

describe Kraken::Client do

	before(:all) do
		@kraken = Kraken::Client.new 'fake key', 'fake secret'
	end

	context "Public Information"

		before(:all) do
			@base_uri = 'http://fake.com/api/0/public/'
		end

		it "gets the server time" do
			pending
		end

		it "gets asset listings" do
			pending
		end

		it "gets asset pairs" do
			pending
		end

		it "gets the ticker" do
			pending
		end

		it "gets the order book" do
			pending
		end
	end

	private

		def fake method, path, body
			FakeWeb.register_url(method, "#{BASE_URI}#{path}", body: bod)
		end

end

