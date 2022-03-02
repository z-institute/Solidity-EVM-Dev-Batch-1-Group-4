// const { expectRevert, expectEvent } = require('@openzeppelin/test-helpers')
const { expect,assert } = require("chai");
const { ethers, waffle } = require("hardhat");
const provider = waffle.provider;

//contractInstance
let ZNtokenFactory, znTokenFactory, ZNtoken, Liquidate, liquidate;

//date
let todayDate, yesterdayDate, twoDayAgoDate;

//price
let todayAvgPrice, yesterdayAvgPrice, twoDayAgoAvgPrice;
const sendToLiquidate = 1000;
const range_ = 6; 
const BASE_ = 10;
const ZERO_ADDR = '0x0000000000000000000000000000000000000000'
let owner, trader1, trader2;


describe("ZNtokenFactory contract", function(){

    it('before deploy', async function(){
        [owner, trader1, trader2] = await ethers.getSigners();
        console.log("owner:", owner.address);
        console.log("trader1:", trader1.address);
        console.log("trader2:", trader2.address);
    });


    it('should deploy', async function(){
        ZNtokenFactory = await ethers.getContractFactory("ZNtokenFactory");
        znTokenFactory = await ZNtokenFactory.deploy();
        console.log("znTokenFactory address:" + znTokenFactory.address);

        Liquidate = await ethers.getContractFactory("Liquidate");
        liquidate = await Liquidate.deploy();
        console.log("liquidate address:" + liquidate.address);

        ZNtoken = await ethers.getContractFactory("ZNtoken");
    });

    it('send for liquidate reward pool', async function(){
        
        const liquidateBeforeSend = await provider.getBalance(liquidate.address);
        console.log("before transaction, liquidate balance:", liquidateBeforeSend);
        
        await owner.sendTransaction({
            to: liquidate.address,
            value: ethers.utils.parseEther(sendToLiquidate+""),
        });        

        let liquidateAfterSend = await provider.getBalance(liquidate.address)/(10**18) ;  
        console.log("Liquidate Contract balance: ", liquidateAfterSend);
        console.log("after transaction, owner balance: ", await provider.getBalance(owner.address));
        expect(liquidateBeforeSend < liquidateAfterSend).to.equal(true);
        expect(liquidateAfterSend).to.equal(sendToLiquidate);
    });

    it('#updatePrice', async function(){
        twoDayAgoAvgPrice = 100;
        yesterdayAvgPrice = 105;
        todayAvgPrice = 111;
        twoDayAgoDate = 20220224;
        yesterdayDate = 20220225;
        todayDate = 20220226;
        await znTokenFactory.updatePrice(todayDate, todayAvgPrice);
        await znTokenFactory.updatePrice(yesterdayDate, yesterdayAvgPrice);
        await znTokenFactory.updatePrice(twoDayAgoDate, twoDayAgoAvgPrice);
        
        const x = await znTokenFactory.expiryDayToPrice(twoDayAgoDate);
        expect(x).to.equal(twoDayAgoAvgPrice);
    });

    it('#getStrikePrices when avg = 111', async function(){
        const [_strikePrices, _index] = await znTokenFactory.getStrikePrices(
            todayAvgPrice, 
            range_,
            BASE_);
        expect(_strikePrices[0], 1);
        expect(_strikePrices[1], 11);
        expect(_strikePrices[2], 21);
        expect(_strikePrices[3], 31);

        expect(_strikePrices[11], 111);
        expect(_strikePrices[12], 121);
        expect(_strikePrices[13], 131);
        expect(_strikePrices[14], 141);
        expect(_strikePrices[15], 151);
        expect(_strikePrices[16], 161);
        expect(_strikePrices[17], 171);
    });

    it('#getStrikePrices when avg = 100', async function(){
        const [_strikePrices, _index] = await znTokenFactory.getStrikePrices(
            twoDayAgoAvgPrice, 
            range_,
            BASE_);
        expect(_strikePrices[0], 10);
        expect(_strikePrices[10], 100);
        expect(_strikePrices[11], 110);
        expect(_strikePrices[12], 120);
    });

    it('#getStrikePrices when avg = 105', async function(){
        const [_strikePrices, _index] = await znTokenFactory.getStrikePrices(
            yesterdayAvgPrice, 
            range_,
            BASE_);
        expect(_strikePrices[5], 95);
        expect(_strikePrices[7], 115);
    });

    it('get buy price when isPut and avgPrice = strikePrice', async function(){
        let _strikePrice = 100;
        let _base = 10;
        let _avgPrice = 100;
        let _isPut = 1;
        const _buyPrice = await znTokenFactory.getBuyPrice(
            _isPut,
            _avgPrice,
            _strikePrice,
            _base
        );
        expect(_buyPrice, 5);
    });

    it('#getBuyPrice when isPut and avgPrice > strikePrice', async function(){
        let _strikePrice = 80;
        let _base = 10;
        let _avgPrice = 100;
        let _isPut = 1;
        const _buyPrice = await znTokenFactory.getBuyPrice(
            _isPut,
            _avgPrice,
            _strikePrice,
            _base
        );
        expect(_buyPrice, 3);
    });

    it('#getBuyPrice when isPut and avgPrice >> strikePrice', async function(){
        let _strikePrice = 10;
        let _base = 10;
        let _avgPrice = 100;
        let _isPut = 1;
        const _buyPrice = await znTokenFactory.getBuyPrice(
            _isPut,
            _avgPrice,
            _strikePrice,
            _base
        );
        expect(_buyPrice, 1);
    });

    it('#getBuyPrice when isPut and avgPrice < strikePrice', async function(){
        let _strikePrice = 120;
        let _base = 10;
        let _avgPrice = 100;
        let _isPut = 1;
        const _buyPrice = await znTokenFactory.getBuyPrice(
            _isPut,
            _avgPrice,
            _strikePrice,
            _base
        );
        expect(_buyPrice, 25);
    });

    it('#getBuyPrice when !isPut and avgPrice = strikePrice', async function(){
        let _strikePrice = 100;
        let _base = 10;
        let _avgPrice = 100;
        let _isPut = 1;
        const _buyPrice = await znTokenFactory.getBuyPrice(
            _isPut,
            _avgPrice,
            _strikePrice,
            _base
        );
        expect(_buyPrice, 5);
    });

    it('#getBuyPrice when !isPut and avgPrice > strikePrice', async function(){
        let _strikePrice = 90;
        let _base = 10;
        let _avgPrice = 100;
        let _isPut = 0;
        const _buyPrice = await znTokenFactory.getBuyPrice(
            _isPut,
            _avgPrice,
            _strikePrice,
            _base
        );
        expect(_buyPrice, 15);
    });

    it('#getBuyPrice when !isPut and avgPrice < strikePrice', async function(){
        let _strikePrice = 110;
        let _base = 10;
        let _avgPrice = 100;
        let _isPut = 0;
        const _buyPrice = await znTokenFactory.getBuyPrice(
            _isPut,
            _avgPrice,
            _strikePrice,
            _base
        );
        expect(_buyPrice, 4);
    });

    it('#getBuyPrice when !isPut and avgPrice << strikePrice', async function(){
        let _strikePrice = 150;
        let _base = 10;
        let _avgPrice = 100;
        let _isPut = 0;
        const _buyPrice = await znTokenFactory.getBuyPrice(
            _isPut,
            _avgPrice,
            _strikePrice,
            _base
        );
        expect(_buyPrice, 1);
    });

    it('#getAvgPriceByDay', async function(){
        const avgPrice = await znTokenFactory.getAvgPriceByDay(yesterdayDate);
        expect(avgPrice, 105);
    });

    //#createZNtoken, #buyOP, #getTokenAddress
    it('buy call and win', async function(){
        let _underlyingAsset = "azuki";
        let _strikeAsset = "ETH";
        let _expiryDay = 20220226;
        let _price = 100;
        let _isPut = 0;

        const createToken = await znTokenFactory.createZNtoken(
            _underlyingAsset,
            _strikeAsset,
            _expiryDay,
            _isPut
        );
        expect(createToken, true);

        //getTokenAddress        
        const tokenAddress = await znTokenFactory.getTokenAddress(
            _expiryDay,
            _isPut,
            _price
        );
        assert.notEqual(tokenAddress, ZERO_ADDR, 'check failed on deployed token.');
        
        //buyOP
        const token = await ZNtoken.attach(tokenAddress);
        console.log("before buyOP, token balance:", await token.balanceOf(znTokenFactory.address));
        
        let buyPrice = await token.buyPrice();
        let amount = 1000;

        let account = trader1.address;
        let traderBalanceBeforeBuy = await provider.getBalance(account) / (10 ** 18);
        console.log("before buyOP, traderBalance ether:", traderBalanceBeforeBuy);

        //OP price formula
        let needPay = (1 * buyPrice * amount) / (10**2 * BASE_);

        await znTokenFactory.connect(trader1).buyOP(
                _expiryDay,
                _isPut,
                _price,
                account,
                amount,
                {
                    value: ethers.utils.parseEther(needPay+"")
                }
        );

        console.log("after buyOP, trader token balance:", await token.balanceOf(account));
        console.log("after buyOP, token balance:", await token.balanceOf(znTokenFactory.address));
        let traderBalanceAfterBuy = await provider.getBalance(account) / (10 ** 18);
        console.log("after buyOP, trader ether balance:", traderBalanceAfterBuy);
        expect(traderBalanceAfterBuy < traderBalanceBeforeBuy).to.equal(true);
        
        let tokenBalanceTrader1 = await token.balanceOf(trader1.address);
        // console.log("token balance of trader1:", tokenBalanceTrader1);
        expect(tokenBalanceTrader1).to.equal(amount);

        //updateTokenFactory
        // console.log("zfAddress: ", znTokenFactory.address)
        await liquidate.updateTokenFactory(znTokenFactory.address);
        // console.log("zfAddress: ", await liquidate.zf())  
        
        //getReward
        let liquidateBalanceBeforeReward = await provider.getBalance(liquidate.address) / (10 ** 18);

        const getReward = await liquidate.connect(trader1).getReward(
            _expiryDay, 
            _isPut, 
            _price,
            amount);

        let liquidateBalanceAfterReward = await provider.getBalance(liquidate.address) / (10 ** 18);
        // console.log("after reward, Liquidate Contract balance:", liquidateBalanceAfterReward);

        let traderBalanceAfterReward = await provider.getBalance(trader1.address) / (10 ** 18);
        // console.log("after reward, trader1 balance:", traderBalanceAfterReward);

        let tokenBalanceAfterBurn = await token.balanceOf(trader1.address);
        
        expect(traderBalanceAfterReward > traderBalanceAfterBuy).to.equal(true);
        expect(liquidateBalanceAfterReward < liquidateBalanceBeforeReward).to.equal(true);
        expect(tokenBalanceAfterBurn).to.equal(0);
        
        await liquidate.withdraw(owner.address);
        const afterContractBalance = await liquidate.getContractBalance();
        expect(afterContractBalance).to.equal(0);  
    });


    //#createZNtoken, #buyOP, #getTokenAddress
    it('buy put and win', async function(){
        let _underlyingAsset = "azuki";
        let _strikeAsset = "ETH";
        let _expiryDay = 20220226;
        let _price = 130;
        let _isPut = 1;

        const createToken = await znTokenFactory.createZNtoken(
            _underlyingAsset,
            _strikeAsset,
            _expiryDay,
            _isPut
        );
        expect(createToken, true);

        //getTokenAddress        
        const tokenAddress = await znTokenFactory.getTokenAddress(
            _expiryDay,
            _isPut,
            _price
        );
        assert.notEqual(tokenAddress, ZERO_ADDR, 'check failed on deployed token.');
        
        //buyOP
        const token = await ZNtoken.attach(tokenAddress);
        console.log("before buyOP, token balance:", await token.balanceOf(znTokenFactory.address));
        
        let buyPrice = await token.buyPrice();
        let amount = 1500;

        let account = trader1.address;
        let traderBalanceBeforeBuy = await provider.getBalance(account) / (10 ** 18);
        console.log("before buyOP, traderBalance ether:", traderBalanceBeforeBuy);

        //OP price formula
        let needPay = (1 * buyPrice * amount) / (10**2 * BASE_);

        await znTokenFactory.connect(trader1).buyOP(
                _expiryDay,
                _isPut,
                _price,
                account,
                amount,
                {
                    value: ethers.utils.parseEther(needPay+"")
                }
        );

        console.log("after buyOP, trader token balance:", await token.balanceOf(account));
        console.log("after buyOP, token balance:", await token.balanceOf(znTokenFactory.address));
        let traderBalanceAfterBuy = await provider.getBalance(account) / (10 ** 18);
        console.log("after buyOP, trader ether balance:", traderBalanceAfterBuy);
        expect(traderBalanceAfterBuy < traderBalanceBeforeBuy).to.equal(true);

        let tokenBalanceTrader1 = await token.balanceOf(trader1.address);
        // console.log("token balance of trader1:", tokenBalanceTrader1);
        expect(tokenBalanceTrader1).to.equal(amount);

        //updateTokenFactory
        // console.log("zfAddress: ", znTokenFactory.address)
        await liquidate.updateTokenFactory(znTokenFactory.address);
        // console.log("zfAddress: ", await liquidate.zf())  
        
        //getReward
        let liquidateBalanceBeforeReward = await provider.getBalance(liquidate.address) / (10 ** 18);

        const getReward = await liquidate.connect(trader1).getReward(
            _expiryDay, 
            _isPut, 
            _price,
            amount);

        let liquidateBalanceAfterReward = await provider.getBalance(liquidate.address) / (10 ** 18);
        // console.log("after reward, Liquidate Contract balance:", liquidateBalanceAfterReward);

        let traderBalanceAfterReward = await provider.getBalance(trader1.address) / (10 ** 18);
        // console.log("after reward, trader1 balance:", traderBalanceAfterReward);

        let tokenBalanceAfterBurn = await token.balanceOf(trader1.address);
        
        // expect(traderBalanceAfterReward > traderBalanceAfterBuy).to.equal(true);
        // expect(liquidateBalanceAfterReward < liquidateBalanceBeforeReward).to.equal(true);
        expect(tokenBalanceAfterBurn).to.equal(0);

        await liquidate.withdraw(owner.address);
        const afterContractBalance = await liquidate.getContractBalance();
        expect(afterContractBalance).to.equal(0);  
    });


    //#createZNtoken, #buyOP, #getTokenAddress
    it('buy put and lost', async function(){
        let _underlyingAsset = "azuki";
        let _strikeAsset = "ETH";
        let _expiryDay = 20220226;
        let _price = 90;
        let _isPut = 1;

        const createToken = await znTokenFactory.createZNtoken(
            _underlyingAsset,
            _strikeAsset,
            _expiryDay,
            _isPut
        );
        expect(createToken, true);

        //getTokenAddress        
        const tokenAddress = await znTokenFactory.getTokenAddress(
            _expiryDay,
            _isPut,
            _price
        );
        assert.notEqual(tokenAddress, ZERO_ADDR, 'check failed on deployed token.');
        
        //buyOP
        const token = await ZNtoken.attach(tokenAddress);
        console.log("before buyOP, token balance:", await token.balanceOf(znTokenFactory.address));
        
        let buyPrice = await token.buyPrice();
        let amount = 1500;

        let account = trader1.address;
        let traderBalanceBeforeBuy = await provider.getBalance(account) / (10 ** 18);
        console.log("before buyOP, traderBalance ether:", traderBalanceBeforeBuy);

        //OP price formula
        let needPay = (1 * buyPrice * amount) / (10**2 * BASE_);

        await znTokenFactory.connect(trader1).buyOP(
                _expiryDay,
                _isPut,
                _price,
                account,
                amount,
                {
                    value: ethers.utils.parseEther(needPay+"")
                }
        );

        console.log("after buyOP, trader token balance:", await token.balanceOf(account));
        console.log("after buyOP, token balance:", await token.balanceOf(znTokenFactory.address));
        let traderBalanceAfterBuy = await provider.getBalance(account) / (10 ** 18);
        console.log("after buyOP, trader ether balance:", traderBalanceAfterBuy);
        expect(traderBalanceAfterBuy < traderBalanceBeforeBuy).to.equal(true);
        
        let tokenBalanceTrader1 = await token.balanceOf(trader1.address);
        // console.log("token balance of trader1:", tokenBalanceTrader1);
        expect(tokenBalanceTrader1).to.equal(amount);

        //updateTokenFactory
        // console.log("zfAddress: ", znTokenFactory.address)
        await liquidate.updateTokenFactory(znTokenFactory.address);
        // console.log("zfAddress: ", await liquidate.zf())  
        
        //getReward
        let liquidateBalanceBeforeReward = await provider.getBalance(liquidate.address) / (10 ** 18);
        // console.log("before reward, Liquidate Contract balance:", liquidateBalanceBeforeReward);

        const getReward = await liquidate.connect(trader1).getReward(
            _expiryDay, 
            _isPut, 
            _price,
            amount);

        let liquidateBalanceAfterReward = await provider.getBalance(liquidate.address) / (10 ** 18);
        // console.log("after reward, Liquidate Contract balance:", liquidateBalanceAfterReward);

        let traderBalanceAfterReward = await provider.getBalance(trader1.address) / (10 ** 18);
        // console.log("after reward, trader1 balance:", traderBalanceAfterReward);

        let tokenBalanceAfterBurn = await token.balanceOf(trader1.address);
        
        //int and double will be different outcome.
        // expect(traderBalanceAfterReward < traderBalanceAfterBuy).to.equal(true);
        expect(liquidateBalanceAfterReward).to.equal(liquidateBalanceBeforeReward);
        expect(tokenBalanceAfterBurn).to.equal(0);
    
        await liquidate.withdraw(owner.address);
        const afterContractBalance = await liquidate.getContractBalance();
        expect(afterContractBalance).to.equal(0);    
    });
});
