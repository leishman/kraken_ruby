# KrakenRuby

### IMPORTANT

This gem is currently built to only query data. There is an experimental ```add_order``` trading method that can be used at **your own risk**. Please thoroughly vet everything in the code for yourself before using this gem to buy, sell, or move any of your assets. 

PLEASE submit an issue or pull request if you notice any bugs, security holes, or potential improvements.

### Description

This gem is a wrapper for the [Kraken Digital Asset Trading Platform](https://www.kraken.com) API. Official documentation from Kraken can be found [here](https://www.kraken.com/help/api).

The current version (0.2.0) can be used to query public and private market data. Private data queries require use of your account API keys.

### Pending Future Updates

- Solid trade execution functionality
- More comprehensive test suite for methods requiring authentication (using VCR perhaps)
- More comprehensive documentation

## Installation

Add this line to your application's Gemfile:

    gem 'kraken_ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kraken_ruby

## Usage

Create a Kraken client:

```ruby
API_KEY = '3bH+M/nLp......'
API_SECRET = 'wQG+7Lr9b.....'

kraken = Kraken::Client.new(API_KEY, API_SECRET)

time = kraken.server_time
time.unixtime #=> 1393056191
```

### Public Data Methods

#### Server Time

This functionality is provided by Kraken to to aid in approximating the skew time between the server and client.

```ruby
time = kraken.server_time

time.unixtime #=> 1393056191
time.rfc1123 #=> "Sat, 22 Feb 2014 08:28:04 GMT"
```

#### Asset Info

Returns the assets that can be traded on the exchange. This method can be passed ```info```, ```aclass``` (asset class), and ```asset``` options. An example below is given for each:

```ruby
kraken.assets
```

#### Asset Pairs

```ruby
pairs = kraken.asset_pairs
```

#### Ticker Information

```ruby
ticker_data = kraken.ticker('XLTCXXDG, ZUSDXXVN')
```

#### Order Book

Get market depth information for given asset pairs

```ruby
depth_data = kraken.order_book('LTCXRP')
```

#### Trades

Get recent trades

```ruby
trades = kraken.trades('LTCXRP')
```

#### Spread

Get spread data for a given asset pair

```ruby
spread = kraken.spread('LTCXRP')
```

### Private Data Methods

#### Balance

Get account balance for each asset
Note: Rates used for the floating valuation is the midpoint of the best bid and ask prices

```ruby
balance = kraken.balance
```

#### Trade Balance

Get account trade balance

```ruby
trade_balance = kraken.trade_balance
```

#### Open Orders

```ruby
open_orders = kraken.open_orders
```

#### Query Orders

See all orders

```ruby
orders = kraken.query_orders
```

#### Trades History

Get array of all trades

```ruby
trades = kraken.trade_history
```

#### Query Trades

**Input:** Comma delimited list of transaction (tx) ids

```ruby
trades = kraken.query_trades(tx_ids)
```

#### Open Positions

**Input:** Comma delimited list of transaction (tx) ids

```ruby
positions = kraken.open_positions(tx_ids)
```

#### Ledgers Info

```ruby
ledgers = kraken.ledgers_info
```

#### Ledgers Info

**Input:** Comma delimited list of ledger ids

```ruby
ledgers = kraken.query_ledgers(ledger_ids)
```

#### Trade Volume

**Input:** Comma delimited list of asset pairs

```ruby
asset_pairs = 'XLTCXXDG, ZEURXXDG'
volume = kraken.query_ledgers(asset_pairs)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request