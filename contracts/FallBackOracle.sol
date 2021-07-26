//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0;

import "hardhat/console.sol";
import "usingtellor/contracts/UsingTellor.sol"; 

/*
Notes: might have to use a greater fee within creating a pool to make it work
*/

contract FallBackOracle is UsingTellor {

    function grabTellorValue(uint256 _dataId) internal view returns (uint256, uint256) {
      (bool ifRetrieve, uint256 value, uint256 _timestampRetrieved) = getCurrentValue(_dataId);
      if (!ifRetrieve) return (0, 0);
      return (value, _timestampRetrieved);
    }

    function grabNewValue(uint256 _dataId) external view returns (uint256) {
      // Retrieve Tellor Value
      (uint256 tellorValue, uint256 tellorTimestamp) = grabTellorValue(_dataId);
      return tellorValue;
    }

    constructor(address payable _tellorAddress) UsingTellor(_tellorAddress) public {}
}