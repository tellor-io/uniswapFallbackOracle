//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";
import "usingtellor/contracts/UsingTellor.sol"; 
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

/*
Notes: might have to use a greater fee within creating a pool to make it work
*/

contract FallBackOracle is UsingTellor {

    IUniswapV3Pool uniswapPool;

    function grabTellorValue(uint256 _dataId) internal view returns (uint256, uint256) {
      (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(_dataId);
      if (!ifRetrieve) return (0, 0);
      return (value, _timestampRetrieved);
    }

    function grabUniswapValue(uint32[] memory testValues) external view {
      (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = uniswapPool.observe(testValues);
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