//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";
import "usingtellor/contracts/UsingTellor.sol"; 
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

contract FallBackOracle is UsingTellor {

    // Pool to create
    IUniswapV3Pool uniswapPool;

    // Grabs current Tellor value, as well as the timestamp retrieved
    function grabTellorValue(uint256 _dataId) internal view returns (uint256, uint256) {
      (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(_dataId);
      if (!ifRetrieve) return (0, 0);
      return (value, _timestampRetrieved);
    }

    // Grab the value from Uniswap and the second difference
    function grabUniswapValue(uint32[] memory testValues) external view returns (uint160[] memory) {
      (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = uniswapPool.observe(testValues);
      int56 tickDifference = (tickCumulatives[0] - tickCumulatives[1]);
      uint160 secondDifference = (secondsPerLiquidityCumulativeX128s[0] - secondsPerLiquidityCumulativeX128s[1]);
      return secondsPerLiquidityCumulativeX128s;
    }

    function grabNewValue(uint256 _dataId) external view returns (uint256) {
      // Retrieve Tellor Value
      (uint256 tellorValue, uint256 tellorTimestamp) = grabTellorValue(_dataId);
      return tellorValue;
    }

    constructor(address payable _tellorAddress, address _poolAddress) UsingTellor(_tellorAddress) public {
      uniswapPool = IUniswapV3Pool(_poolAddress);
    }
}