# FallBack Oracle
This projects implements an oracle that draws values from Uniswap's V3 exchange, and defaults to the Tellor oracle depending on certain criteria.

Created by: Christopher Pondoc

## Motivation

Uniswap V3's pools and AMMs can be utilized to retrieve relative prices between two different tokens. Thus, the decentralized exchange can be used as an oracle. However, the data from these pools is not always reliable -- in some cases, users may want to default to a decentralized oracle, such as Tellor, in order to retrieve proper price data. This smart contract implements this functionality, which retrieves values from both Uniswap and Tellor and allows the user to specify certain levers to determine which source to use.

## Reference

### Price IDs
For reference, the fallback oracle utilizes the price IDs from the Tellor oracle, which have a numerical id correspond to a specific exchange (i.e. BTC/USD, ETH/USD, ETC.). For each of those price IDs/feeds, there is a specific pool in UniswapV3 that is deployed as a contract on mainnet that has the corresponding data. Thus, a mapping of IDs to contract addresses is created to access any available data feed.

### Criteria for Fallback

In order to fallback, at least one of serveral criteria have to be true. These are:
* **Liquidity**: Is there enough liquidity in the Uniswap Pool for the given price feed to have a reliable value?
* **Data Freshness**: Is the data recent enough -- against Tellor's retrieved value -- in order for a reliable value?
* **Threshold**: Is the given price close enough to the value of Tellor's to merit a reliable value?

All of these given levers can be specified by the user in order to help them customize how much they want to compare Uniswap and Tellor values.

### Compiling and Testing
```
npx hardhat compile

npx hardhat test
```
