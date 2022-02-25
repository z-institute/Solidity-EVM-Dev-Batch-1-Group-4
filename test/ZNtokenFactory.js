const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const provider = waffle.provider;

describe("ZNtokenFactory", function () {
  it("Should return the ", async function () {
    //getSigners
    const [owner, acc1, acc2] = await ethers.getSigners();
    console.log("ownerAddress:", owner.address);
    console.log("owner balance:%s ether:", await provider.getBalance(owner.address) / (10 ** 18));

    //deploy
    const ZNtokenFactory = await ethers.getContractFactory("ZNtokenFactory");
    const znTokenFactory = await ZNtokenFactory.deploy();
    await znTokenFactory.deployed();

    const Liquidate = await ethers.getContractFactory("Liquidate");
    const liquidate = await Liquidate.deploy();
    await liquidate.deployed();

    //update price
    const updatePrice = await znTokenFactory.updatePrice(20220222, 40);
    const updatePrice2 = await znTokenFactory.updatePrice(20220223, 70);
    //const updatePrice = await znTokenFactory.updatePrice(20220222, 47);

    //create token
    const createToken = await znTokenFactory.createZNtoken("Azuki", "ether", 20220224, 0);
    //const createToken1 = await znTokenFactory.createZNtoken("Azuki", "ether", 20220224, 1);
    const tokenAddress = await znTokenFactory.getTokenAddress(20220224, 0, 50);
    console.log("TokenAddress:", tokenAddress);

    //acc1 buyop
    const token = await (await ethers.getContractFactory("ZNtoken")).attach(tokenAddress)
    await console.log("token balance of owner:", await token.balanceOf(znTokenFactory.address));
    const buyOP = await znTokenFactory.connect(acc1).buyOP(20220224, 0, 50, acc1.address, 500);
    await console.log("token balance of acc1:", await token.balanceOf(acc1.address));
    await console.log("token balance of owner:", await token.balanceOf(znTokenFactory.address));

    //send ether to liquidate Contract
    console.log("Liquidate Contract balance:%s ether", await provider.getBalance(liquidate.address) / (10 ** 18))
    const transactionHash = await owner.sendTransaction({
      to: liquidate.address,
      value: ethers.utils.parseEther("1000.0"),
    });
    console.log("Liquidate Contract balance::%s ether", await provider.getBalance(liquidate.address) / (10 ** 18))
    console.log("owner balance:%s ether:", await provider.getBalance(owner.address) / (10 ** 18));

    //updateTokenFactory
    console.log("zfAddress:%s", znTokenFactory.address)
    const updateTokenFactory = await liquidate.updateTokenFactory(znTokenFactory.address);
    console.log("zfAddress:%s", await liquidate.zf())

    //acc1 getReward
    // const getReward = await liquidate.connect(acc1).getReward(20220224, 0, 50, 500);
    // console.log("owner balance:%s ether:", await provider.getBalance(owner.address) / (10 ** 18));
    // console.log("acc1 balance:%s ether:", await provider.getBalance(acc1.address) / (10 ** 18));
  });
});
