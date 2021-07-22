const { expect } = require("chai");
const { abi, bytecode} = require('@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json');
const { ethers } = require("hardhat");

describe("FallBackOracle", function() {
    
  it("Let's see what happens!", async function() {

    // Set up UniswapV3Factory and get its address
    const UniswapV3Factory = await ethers.getContractFactory(abi, bytecode);
    const uniswapV3Factory = await UniswapV3Factory.deploy();
    await uniswapV3Factory.deployed();

    // Set up the FallBackOracle
    const FallBackOracle = await ethers.getContractFactory("FallBackOracle");
    const fallBackOracle = await FallBackOracle.deploy(uniswapV3Factory.address);
    await fallBackOracle.deployed();

    const firstTick = await fallBackOracle.getValue();
    console.log(firstTick);
  });
});
