// SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

// Printing to the Hardhat console
import "hardhat/console.sol";

// Contracts for Tellor Oracle and Uniswap Pool
import "usingtellor/contracts/UsingTellor.sol"; 
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

// Libraries for assisting with math operations
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

contract FallBackOracle is UsingTellor {

    // Taking care of large prices
    using SafeMath for uint256;

    mapping(uint => address) public priceFeeds; // Mapping for Data IDs and addresses

    // Grabs current Tellor value, as well as the timestamp retrieved
    function grabTellorValue(uint256 _dataId) internal view returns (uint256, uint256) {
      (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(_dataId);
      if (!ifRetrieve) return (0, 0);
      return (value, _timestampRetrieved);
    }

    // Grab the value from Uniswap and the second difference
    // Note: currently does moves by an offset of 8
    function grabUniswapValue(IUniswapV3Pool _pool, uint32[] memory testValues, uint128 _liquidityBound) internal view returns (uint256 price) {
      // Get value of the data
      (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = _pool.observe(testValues);

      // Calculate the tick and time difference
      int24 tickDifference = int24(tickCumulatives[1]) - int24(tickCumulatives[0]);
      uint24 timeDifference = uint24(testValues[0]) - uint24(testValues[1]);

      // Calculate the time weighted average tick, and then utilize tick math to get sqrt price
      int24 timeWeightedAverageTick = tickDifference / int24(timeDifference);
      uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(timeWeightedAverageTick);
      return uint(sqrtPriceX96).mul(uint(sqrtPriceX96)).mul(1e8) >> (96 * 2);
    }

    // General function grab new values from the oracle
    function grabNewValue(uint32[] memory _timeSpan, uint256 _dataId, uint128 _liquidityBound) external returns (uint256) {
      // Set up Uniswap Pool
      IUniswapV3Pool uniswapPool = IUniswapV3Pool(address(priceFeeds[_dataId]));
      uint256 uniswapPrice = grabUniswapValue(uniswapPool, _timeSpan, _liquidityBound);

      // Check for conditions of Uniswap Pool -- liquidity
      if (uniswapPool.liquidity() < _liquidityBound) {
        console.log("We'll use Tellor!");
      }

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