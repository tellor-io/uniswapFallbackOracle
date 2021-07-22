//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "hardhat/console.sol";
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

/*
Notes: might have to use a greater fee within creating a pool to make it work
*/

contract FallBackOracle {

  // Setting UniswapV3 Factories and Pools
  IUniswapV3Factory factory;
  IUniswapV3Pool pool;

  // Addresses for different coins
  address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;


  // Creating the actual oracle
  constructor(address _factory) {
    factory = IUniswapV3Factory(_factory);
    address poolAddress = factory.createPool(WETH9, USDC, 3000);
    pool = IUniswapV3Pool(poolAddress);
    console.log("Deploying an Oracle with pool address:", poolAddress);
  }

  function seeTokenZero() public view returns (address) {
      return pool.token0();
  }

  /*function getValue() public view returns (uint160) {
      (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        ) = pool.slot0();
        return sqrtPriceX96;
  }*/

}
