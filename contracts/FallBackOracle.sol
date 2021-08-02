// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

// Printing to the Hardhat console
import "hardhat/console.sol";

// Contracts for Tellor Oracle and Uniswap Pool
import "usingtellor/contracts/UsingTellor.sol"; 
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

// Libraries for assisting with math operations
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

/** 
 @author Christopher Pondoc
 @title Fallback Oracle
 @dev This contract implements an oracle which uses Uniswap as its main
 source of data, and then falls back to Tellor depending on certain conditions.
**/
contract FallBackOracle is UsingTellor {

    // Taking care of large prices
    using SafeMath for uint256;

    // Storage
    mapping(uint => address) public priceFeeds; // Mapping for Data IDs and addresses
    
    // Functions
    /**
     * @dev Determines if a value from Uniswap is within a specific percentange range
     * of Tellor's value
     * @param _uniswapValue value of a specific price id from Uniswap pool
     * @param _tellorValue value of a specific price id from Tellor oracle
     * @param _percent the whole number percentage of how close the values should be
     * @return bool if value is within threshold
     */
    function withinThreshold(uint256 _uniswapValue, uint256 _tellorValue, uint256 _percent) internal pure returns (bool) {
      // Calculate difference between the two values
      uint256 valueDifference = 0;
      if (_uniswapValue > _tellorValue) {
        valueDifference = _uniswapValue.sub(_tellorValue);
      } else {
        valueDifference = _tellorValue.sub(_uniswapValue);
      }

      // Determine if within or outside of threshold
      return (valueDifference.mul(100) < _percent.mul(_uniswapValue));
    }

    /**
     * @dev Grabs current Tellor value, as well as the timestamp retrieved
     * @param _dataId ID of the price feed to pull value from (see Tellor reference)
     * @return uint256 value of price
     * @return uint256 timestamp of value
     */
    function grabTellorValue(uint256 _dataId) internal view returns (uint256, uint256) {
      (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(_dataId);
      if (!ifRetrieve) return (0, 0);
      return (value, _timestampRetrieved);
    }

     /**
     * @dev Grabs current Uniswap Value by determining time weighted average tick (currently offset of 8)
     * @param _pool Uniswap pool object where data is pulled from
     * @param _secondInterval interval of time to look at for looking at price data
     * @param _liquidityBound lower bound to check for how much liquidity exists
     * @return uint256 value of price
     */
    function grabUniswapValue(IUniswapV3Pool _pool, uint32[] memory _secondInterval, uint128 _liquidityBound) internal view returns (uint256) {
      // Get value of the data
      (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = _pool.observe(_secondInterval);

      // Calculate the tick and time difference
      int24 tickDifference = int24(tickCumulatives[1]) - int24(tickCumulatives[0]);
      uint24 timeDifference = uint24(_secondInterval[0]) - uint24(_secondInterval[1]);

      // Calculate the time weighted average tick, and then utilize tick math to get sqrt price
      int24 timeWeightedAverageTick = tickDifference / int24(timeDifference);
      uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(timeWeightedAverageTick);
      return uint(sqrtPriceX96).mul(uint(sqrtPriceX96)).mul(1e8) >> (96 * 2);
    }

    /**
     * @dev Grabs value from both Uniswap and Tellor, and determines which value to return
     * @param _timeSpan time span to look at for Uniswap price pool data
     * @param _dataId price id to look at for both oracles (see Tellor Reference)
     * @param _liquidityBound lower bound to check for how much liquidity exists
     * @return uint256 value of price
     * @return uint256 timestamp of value
     */
    function grabNewValue(uint32[] memory _timeSpan, uint256 _dataId, uint128 _liquidityBound) external view returns (uint256, uint256) {
      // Set up Uniswap Pool
      IUniswapV3Pool uniswapPool = IUniswapV3Pool(address(priceFeeds[_dataId]));
      uint256 uniswapPrice = grabUniswapValue(uniswapPool, _timeSpan, _liquidityBound);

      // Check for conditions of Uniswap Pool -- liquidity
      if (uniswapPool.liquidity() < _liquidityBound) {
        console.log("We'll use Tellor!");
      }

      // Retrieve Tellor Value
      (uint256 tellorValue, uint256 tellorTimestamp) = grabTellorValue(_dataId);
      return (tellorValue, tellorTimestamp);
    }

    // Getter to receive respective contract address from mapping
    function getUniswapAddress(uint _dataId) external view returns (address) {
      return priceFeeds[_dataId];
    }

    /**
     * @dev Sets up respective addresses + pools, and also creates the mapping of price feeds
     * @param _tellorAddress the address of the tellor contract
     * @param _dataIds a list of data IDs
     * @param _contracts a list of corresponding Uniswap pool contracts
     */
    constructor(address payable _tellorAddress, uint[] memory _dataIds, address[] memory _contracts) 
    UsingTellor(_tellorAddress) public {
      // Length of Data IDs and Contracts should be the same
      require(_dataIds.length == _contracts.length, "Data IDs and Contracts are not same length");
      for (uint i = 0; i < _dataIds.length; i++) {
        priceFeeds[_dataIds[i]] = _contracts[i];
      }
    }
}