// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./interfaces/ZNtokenInterface.sol";
import "./interfaces/ZNtokenFactoryInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract Liquidate is Ownable {
    /// @notice address of zntokenFactory
    address public zf;
    ZNtokenFactoryInterface internal znTokenFactory;
    ZNtokenInterface internal zntoken;

    constructor() {}

    function getReward(
        uint256 _expiryDay,
        bool _isPut,
        uint256 _strikePrice,
        uint256 _amount
    ) external returns (bool _isGetRewardSuccess) {
        znTokenFactory = ZNtokenFactoryInterface(zf);
        address token = znTokenFactory.getTokenAddress(
            _expiryDay,
            _isPut,
            _strikePrice
        );
        console.log(token);
        zntoken = ZNtokenInterface(token);
        uint256 avgPrice = znTokenFactory.getAvgPriceByDay(_expiryDay - 1);
        require(avgPrice > 0, "Liquidate: Price need more than zero");
        zntoken.approve(owner(), _amount);
        require(
            zntoken.transferFrom(msg.sender, owner(), _amount),
            "Liquidate:Not enought token to transfer"
        );
        int256 reward = int256(avgPrice) - int256(zntoken.strikePrice());
        if (zntoken.isPut() && zntoken.strikePrice() > avgPrice) {
            //int256 reward = reward.mul(-1) * _amount * (10**zntoken.decimals());
            //payable(address(this)).transfer();
        }
        if (!zntoken.isPut() && avgPrice > zntoken.strikePrice()) {
            //int256 reward = reward.mul(-1) * _amount * (10**zntoken.decimals());
            //payable(address(this)).transfer();
        }
    }

    function updateTokenFactory(address _zntokenFactory) external onlyOwner {
        zf = _zntokenFactory;
    }

    receive() external payable {}
}
