const { expect } = require("chai");
// const { abi, bytecode} = require('@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json');
const { ethers } = require("hardhat");

describe("Fallback Oracle", function() {
  let usingTellor;
  let tellorOracle;

  // Set up Tellor Playground Oracle and UsingTellor
  beforeEach(async function() {
    let TellorOracle = await ethers.getContractFactory("TellorPlayground");
    tellorOracle = await TellorOracle.deploy();
    await tellorOracle.deployed(); 

    let UsingTellor = await ethers.getContractFactory("FallBackOracle");
    usingTellor = await UsingTellor.deploy(tellorOracle.address);
    await usingTellor.deployed();
  });

  // Use Tellor Playground to update values and check both the mapping and 
  // return function
  it("Check for Tellor Update Values", async function() {
    await tellorOracle.submitValue(1, 2000);
    await tellorOracle.submitValue(2, 3000);
    expect(await usingTellor.grabNewValue(1)).to.equal(2000);
    expect(await usingTellor.grabNewValue(2)).to.equal(3000);
  });
});
