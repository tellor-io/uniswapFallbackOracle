const { expect } = require("chai");
const { abi, bytecode} = require('@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json');
const { ethers } = require("hardhat");
const BN = require('bn.js');

// Addresses for Main Functions
const tellorAddress = "0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0";
const sampleUniswapAddress = "0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8";

// Sample variables for data IDs and contracts
const IDs = [1]
const contractAddresses = [sampleUniswapAddress]

describe("Fallback Oracle", function() {

  // Set up FallBack Oracle Contract
  beforeEach(async function() {
    let FallBackOracle = await ethers.getContractFactory("FallBackOracle");
    fallBackOracle = await FallBackOracle.deploy(tellorAddress, IDs, contractAddresses);
    await fallBackOracle.deployed();
  });

  // Use Tellor Playground to update values and check both the mapping and 
  // return function
  it("Check for Tellor Update Values", async function() {
    const firstVal = (await fallBackOracle.grabNewValue(1));
    const secondVal = (await fallBackOracle.grabNewValue(2));
    console.log(firstVal);
    console.log(secondVal);
    const ticks = await fallBackOracle.grabUniswapValue(1, [0, 20]);
    console.log(ticks);
  });
});
