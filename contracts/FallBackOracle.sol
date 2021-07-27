// SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";
import "usingtellor/contracts/UsingTellor.sol"; 
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

contract FallBackOracle is UsingTellor {

    // Defining Uniswap Pool
    IUniswapV3Pool uniswapPool;

    // Mapping for Data IDs and Uniswap Contract Addresses
    mapping(uint => address) public priceFeeds;

    // Grabs current Tellor value, as well as the timestamp retrieved
    function grabTellorValue(uint256 _dataId) internal view returns (uint256, uint256) {
      (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(_dataId);
      if (!ifRetrieve) return (0, 0);
      return (value, _timestampRetrieved);
    }

    // Grab the value from Uniswap and the second difference
    function grabUniswapValue(uint _dataId, uint32[] memory testValues) external returns (uint160) {
      uniswapPool = IUniswapV3Pool(address(priceFeeds[_dataId]));
      (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = uniswapPool.observe(testValues);
      int56 tickDifference = (tickCumulatives[0] - tickCumulatives[1]);
      uint160 secondDifference = (secondsPerLiquidityCumulativeX128s[0] - secondsPerLiquidityCumulativeX128s[1]);
      return secondDifference;
    }

    // General function grab new values from the oracle
    function grabNewValue(uint256 _dataId) external view returns (uint256) {
      // Retrieve Tellor Value
      (uint256 tellorValue, uint256 tellorTimestamp) = grabTellorValue(_dataId);
      return tellorValue;
    }

    // Sets up respective addresses, and also creates the mapping of price feeds
    constructor(address payable _tellorAddress, uint[] memory dataIds, address[] memory contracts) 
    UsingTellor(_tellorAddress) public {
      require(dataIds.length == contracts.length, "Data IDs and Contracts are not same length");
      for (uint i = 0; i < dataIds.length; i++) {
        priceFeeds[dataIds[i]] = contracts[i];
      }
    }
}