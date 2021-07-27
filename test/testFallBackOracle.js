const { expect } = require("chai");
const { abi, bytecode} = require('@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json');
const { ethers } = require("hardhat");

// Addresses for Main Functions
const tellorAddress = "0x88dF592F8eb5D7Bd38bFeF7dEb0fBc02cf3778a0";
const sampleUniswapAddress = "0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8";

describe("Fallback Oracle", function() {
  let usingTellor;
  let uniswapFactory;

  // Set up all pertinent libraries
  beforeEach(async function() {

    // Set up Uniswap Factory and Pool
    let UniswapFactory = await ethers.getContractFactory(abi, bytecode);
    uniswapFactory = await UniswapFactory.deploy();
    await uniswapFactory.deployed();

    let UsingTellor = await ethers.getContractFactory("FallBackOracle");
    //usingTellor = await UsingTellor.deploy(tellorOracle.address, "0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8");
    usingTellor = await UsingTellor.deploy(tellorAddress, sampleUniswapAddress);
    await usingTellor.deployed();

  });

  // Use Tellor Playground to update values and check both the mapping and 
  // return function
  it("Check for Tellor Update Values", async function() {
    const firstVal = (await usingTellor.grabNewValue(1));
    const secondVal = (await usingTellor.grabNewValue(2));
    console.log(firstVal);
    console.log(secondVal);
    await usingTellor.grabUniswapValue([2, 4]);
  });
});
