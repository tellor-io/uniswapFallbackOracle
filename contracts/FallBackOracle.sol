// SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";
import "usingtellor/contracts/UsingTellor.sol"; 
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

contract FallBackOracle is UsingTellor {

    // Mapping for Data IDs and Uniswap Contract Addresses
    mapping(uint => address) public priceFeeds;

    using SafeMath for uint256;

    // Grabs current Tellor value, as well as the timestamp retrieved
    function grabTellorValue(uint256 _dataId) internal view returns (uint256, uint256) {
      (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(_dataId);
      if (!ifRetrieve) return (0, 0);
      console.log("Price ID %s has value of %s", _dataId, value);
      return (value, _timestampRetrieved);
    }

    // Grab the value from Uniswap and the second difference
    function grabUniswapValue(uint _dataId, uint32[] memory testValues) external view returns (uint256 price) {

      // Create a pool for the specific price feed and get the last observation within 20 seconds
      IUniswapV3Pool uniswapPool = IUniswapV3Pool(address(priceFeeds[_dataId]));
      (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = uniswapPool.observe(testValues);

      // Calculate the time weighted average tick
      int24 tickDifference = int24(tickCumulatives[1]) - int24(tickCumulatives[0]);
      uint24 timeDifference = uint24(testValues[0]) - uint24(testValues[1]);
      int24 timeWeightedAverageTick = tickDifference / int24(timeDifference);
      uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(timeWeightedAverageTick);
      return uint(sqrtPriceX96).mul(uint(sqrtPriceX96)).mul(1e5) >> (96 * 2);
    }

    // General function grab new values from the oracle
    function grabNewValue(uint256 _dataId) external view returns (uint256) {
      // Retrieve Tellor Value
      (uint256 tellorValue, uint256 tellorTimestamp) = grabTellorValue(_dataId);
      return tellorValue;
    }

    // Getter to receive respective contract address from mapping
    function getUniswapAddress(uint _dataId) external view returns (address) {
      return priceFeeds[_dataId];
    }

    // Sets up respective addresses, and also creates the mapping of price feeds
    constructor(address payable _tellorAddress, uint[] memory dataIds, address[] memory contracts) 
    UsingTellor(_tellorAddress) public {
      // Length of Data IDs and Contracts should be the same
      require(dataIds.length == contracts.length, "Data IDs and Contracts are not same length");
      for (uint i = 0; i < dataIds.length; i++) {
        priceFeeds[dataIds[i]] = contracts[i];
      }
    }
}