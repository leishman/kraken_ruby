require_relative 'kraken.rb'

f = File.open('kraken.key').to_a.map{ |l| l.strip }
API_KEY = f[0]
API_SECRET = f[1]
debugger
kraken = Kraken::Client.new(API_KEY, API_SECRET)
# p kraken.server_time
# p kraken.assets
# p kraken.asset_pairs({info: 'margin'})
# p kraken.ticker({ pair: 'LTCXRP, XXBTZEUR' })
# p kraken.order_book({ pair: 'LTCXRP' })

# p kraken.trades({ pair: 'LTCXRP' })
# p kraken.spread({ pair: 'LTCXRP' })
# p kraken.balance
p kraken.trade_balance