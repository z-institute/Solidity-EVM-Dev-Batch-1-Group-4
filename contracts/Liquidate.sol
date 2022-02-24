// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./interfaces/ZNtokenInterface.sol";
import "./interfaces/ZNtokenFactoryInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Liquidate is Ownable {
    /// @notice address of zntokenFactory
    address public zntokenFactory;
    ZNtokenFactoryInterface internal znTokenFactory;
    ZNtokenInterface internal zntoken;

    constructor() {}

    function getReward(
        uint256 _expiryDay,
        uint256 _strikePrice,
        uint256 _amount
    ) external returns (bool _isGetRewardSuccess) {
        znTokenFactory = ZNtokenFactoryInterface(zntokenFactory);
        address token = znTokenFactory.getTokenAddress(
            _expiryDay,
            _strikePrice
        );
        zntoken = ZNtokenInterface(token);
        uint256 avgPrice = znTokenFactory.getAvgPriceByDay(_expiryDay);
        require(avgPrice > 0, "Liquidate: Price need more than zero");
        require(
            zntoken.transferZNtoken(owner(), _amount),
            "Liquidate:Not enought token to transfer"
        );
        int256 reward = int256(avgPrice) - int256(zntoken.strikePrice());
        if (zntoken.isPut() && reward < 0) {
            //int256 reward = reward.mul(-1) * _amount * (10**zntoken.decimals());
            //payable(address(this)).transfer();
        }
        if (!zntoken.isPut() && reward > 0) {}
    }

    function updateTokenFactory(address _zntokenFactory) external onlyOwner {
        zntokenFactory = _zntokenFactory;
    }

    receive() external payable {}
}
