# FallBack Oracle
This projects implements an oracle that draws values from Uniswap's V3 exchange, and defaults to the Tellor oracle depending on certain criteria.

Created by: Christopher Pondoc

## Reference

For reference, the fallback oracle utilizes the price IDs from the Tellor oracle, which have a numerical id correspond to a specific exchange (i.e. BTC/USD, ETH/USD, ETC.). For each of those price IDs/feeds, there is a specific pool in UniswapV3 that is deployed as a contract on mainnet that has the corresponding data. Thus, a mapping of IDs to contract addresses is created to access any available data feed.