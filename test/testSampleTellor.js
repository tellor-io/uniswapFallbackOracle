const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("Test UsingTellor", function() {
  let usingTellor;
  let tellorOracle;

  // Set up Tellor Playground Oracle and UsingTellor
  beforeEach(async function() {
    let TellorOracle = await ethers.getContractFactory("TellorPlayground");
    tellorOracle = await TellorOracle.deploy();
    await tellorOracle.deployed(); 

    let UsingTellor = await ethers.getContractFactory("TestTellor");
    usingTellor = await UsingTellor.deploy(tellorOracle.address);
    await usingTellor.deployed();
  });

  it("Check for Price", async function() {
    let requestId = 2;
    let mockValue = 1000;
    await tellorOracle.submitValue(requestId, mockValue);
    expect(await usingTellor.readTellorValue(requestId)).to.equal(mockValue);
  });
});
