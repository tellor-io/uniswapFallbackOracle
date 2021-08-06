// Necessary Dependencies
const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const {
  abi,
  bytecode
} = require("usingtellor/artifacts/contracts/TellorPlayground.sol/TellorPlayground.json")

// Sample variables for data IDs and contracts
const sampleUniswapAddress = "0x04916039b1f59d9745bf6e0a21f191d1e0a84287";
const IDs = [1]
var contractAddresses = [sampleUniswapAddress]

// Changeable parameters depending on test
var liquidityBound;
var timeDifference;
var percentDifference;

describe("Require Tests", function() {

  // Set up Tellor Playground
  this.beforeEach(async function() {
    let TellorPlayground = await ethers.getContractFactory(abi, bytecode);
    tellorPlayground = await TellorPlayground.deploy();
    await tellorPlayground.deployed();
  })

  // Check if too many IDs are submitted compared to addresses -- FAIL
  it("Check if too many IDs are submitted compared to addresses", async function() {
    const sampleIDs = [1, 2, 3]
    let FallBackOracle = await ethers.getContractFactory("FallBackOracle");
    await expect(FallBackOracle.deploy(tellorPlayground.address, sampleIDs, contractAddresses)).to.be.revertedWith("Data IDs and Contracts are not same length");
  });

  // Check if not enough IDs are submitted compared to addresses -- FAIL
  it("Check if too little IDs are submitted compared to addresses", async function() {
    const sampleIDs = []
    let FallBackOracle = await ethers.getContractFactory("FallBackOracle");
    await expect(FallBackOracle.deploy(tellorPlayground.address, sampleIDs, contractAddresses)).to.be.revertedWith("Data IDs and Contracts are not same length");
  });

  it("Check if just enough IDs are submitted compared to addresses", async function() {
    let FallBackOracle = await ethers.getContractFactory("FallBackOracle");
    fallBackOracle = await FallBackOracle.deploy(tellorPlayground.address, IDs, contractAddresses);
    await fallBackOracle.deployed();
  });

});

describe("Liquidity Tests", function() {

  // Set up FallBack Oracle Contract
  beforeEach(async function() {
    // Set up Tellor Playground
    let TellorPlayground = await ethers.getContractFactory(abi, bytecode);
    tellorPlayground = await TellorPlayground.deploy();
    await tellorPlayground.deployed();

    // Set up Fallback Oracle
    let FallBackOracle = await ethers.getContractFactory("FallBackOracle");
    fallBackOracle = await FallBackOracle.deploy(tellorPlayground.address, IDs, contractAddresses);
    await fallBackOracle.deployed();

    // Deploy sample value to Tellor Playground
    const requestId = 1;
    const mockValue = "117447456821";
    await tellorPlayground.submitValue(requestId, mockValue);

    // Define initial variables
    timeDifference = "28108699";
    percentDifference = "20";
  });

  // Check if Liquidity is larger than needed -> Uniswap
  it("Check for liquidity smaller than needed liquidity", async function() {
    liquidityBound = "100";
    var oracleData = await fallBackOracle.grabNewValue(1, BigNumber.from(liquidityBound), BigNumber.from(timeDifference), BigNumber.from(percentDifference));
    expect(oracleData[2]).to.equal(1);
  });

  // Check if Liquidity is smaller than needed -> Tellor
  it("Check for liquidity smaller than needed liquidity", async function() {
    liquidityBound = "342005866247579280920";
    var oracleData = await fallBackOracle.grabNewValue(1, BigNumber.from(liquidityBound), BigNumber.from(timeDifference), BigNumber.from(percentDifference));
    expect(oracleData[2]).to.equal(2);
  });

  // Check if liquidity is exactly what is needed -> Uniswap
  it("Check for liquidity is exactly needed liquidity", async function() {
    liquidityBound = "242005866247579280920";
    var oracleData = await fallBackOracle.grabNewValue(1, BigNumber.from(liquidityBound), BigNumber.from(timeDifference), BigNumber.from(percentDifference));
    expect(oracleData[2]).to.equal(1);
  });

});

describe("Price Tests", function() {

  // Set up FallBack Oracle Contract
  beforeEach(async function() {
    // Set up Tellor Playground
    let TellorPlayground = await ethers.getContractFactory(abi, bytecode);
    tellorPlayground = await TellorPlayground.deploy();
    await tellorPlayground.deployed();

    // Set up Fallback Oracle
    let FallBackOracle = await ethers.getContractFactory("FallBackOracle");
    fallBackOracle = await FallBackOracle.deploy(tellorPlayground.address, IDs, contractAddresses);
    await fallBackOracle.deployed();

    // Deploy sample value to Tellor Playground
    const requestId = 1;
    const mockValue = "105702711121"
    await tellorPlayground.submitValue(requestId, mockValue);

    // Define initial variables
    timeDifference = "28108699";
    liquidityBound = "100";
  });

  // Check if value has enough leeway-> Uniswap
  it("Check if value has enough leeway", async function() {
    percentDifference = "20"
    var oracleData = await fallBackOracle.grabNewValue(1, BigNumber.from(liquidityBound), BigNumber.from(timeDifference), BigNumber.from(percentDifference));
    expect(oracleData[2]).to.equal(1);
  });

  // Check if value is too far from Tellor's -> Tellor
  it("Check if value is too far from Tellor's", async function() {
    percentDifference = "3"
    var oracleData = await fallBackOracle.grabNewValue(1, BigNumber.from(liquidityBound), BigNumber.from(timeDifference), BigNumber.from(percentDifference));
    expect(oracleData[2]).to.equal(2);
  });

  // Check if value is exactly around Tellor's -> Uniswap
  it("Check if value is exactly around Tellor's", async function() {
    percentDifference = "11"
    var oracleData = await fallBackOracle.grabNewValue(1, BigNumber.from(liquidityBound), BigNumber.from(timeDifference), BigNumber.from(percentDifference));
    expect(oracleData[2]).to.equal(1);
  });

});


describe("Timestamp Tests", function() {

  // Set up FallBack Oracle Contract
  beforeEach(async function() {
    // Set up Tellor Playground
    let TellorPlayground = await ethers.getContractFactory(abi, bytecode);
    tellorPlayground = await TellorPlayground.deploy();
    await tellorPlayground.deployed();

    // Set up Fallback Oracle
    let FallBackOracle = await ethers.getContractFactory("FallBackOracle");
    fallBackOracle = await FallBackOracle.deploy(tellorPlayground.address, IDs, contractAddresses);
    await fallBackOracle.deployed();

    // Deploy sample value to Tellor Playground
    const requestId = 1;
    const mockValue = "117447456821"
    await tellorPlayground.submitValue(requestId, mockValue);

    // Define initial variables
    percentDifference = "50";
    liquidityBound = "100";
  });

  // Check if data is fresh enough -> Uniswap
  it("Check if data is not fresh enough -- Uniswap ", async function() {
    timeDifference = "300000"
    var oracleData = await fallBackOracle.grabNewValue(1, BigNumber.from(liquidityBound), BigNumber.from(timeDifference), BigNumber.from(percentDifference));
    expect(oracleData[2]).to.equal(1);
  });

  // Check if data is not fresh enough -> Tellor
  it("Check if data is not fresh enough -- Tellor ", async function() {
    timeDifference = "300"
    var oracleData = await fallBackOracle.grabNewValue(1, BigNumber.from(liquidityBound), BigNumber.from(timeDifference), BigNumber.from(percentDifference));
    expect(oracleData[2]).to.equal(2);
  });

});

