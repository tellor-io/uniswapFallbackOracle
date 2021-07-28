const { expect } = require("chai");
const { ethers } = require("hardhat");
const BN = require('bn.js');

// Addresses for Main Functions
const tellorAddress = "0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0";
const sampleUniswapAddress = "0x1d42064Fc4Beb5F8aAF85F4617AE8b3b5B8Bd801";

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

  // Check each id with corresponding contract, as defined by reference variables
  it ("Check that all Tellor data IDs align with Uniswap contract addresses", async function() {
    expect(await fallBackOracle.getUniswapAddress(1)).to.equal(contractAddresses[0]);
  });

  // Use Tellor Playground to update values and check both the mapping and 
  // return function
  it("Check for Tellor Update Values", async function() {
    const firstVal = (await fallBackOracle.grabNewValue(1));
    const secondVal = (await fallBackOracle.grabNewValue(2));
    const lastVal = await fallBackOracle.grabUniswapValue(1, [20, 0]);
    console.log(lastVal);
  });
});
