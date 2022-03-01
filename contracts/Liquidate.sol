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

    /// @dev base price decimals(price= 1 represent 0.1 ether)
    uint256 internal constant BASE = 10;

    /// @dev token decimal
    uint256 internal constant TOKENDECIMAL = 100;

    bool internal isCanBeTransfer = false;

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
        zntoken = ZNtokenInterface(token);
        uint256 avgPrice = znTokenFactory.getAvgPriceByDay(_expiryDay - 1);

        require(avgPrice > 0, "Liquidate: Price need more than zero");
        require(
            zntoken.balanceOf(msg.sender) >= _amount,
            "Liquidate:Not enought token to transfer"
        );
        //zntoken.approve(address(this), _amount);
        zntoken.burnZNtoken(msg.sender, _amount);

        //win put
        if (zntoken.isPut() && zntoken.strikePrice() > avgPrice) {
            uint256 reward = zntoken.strikePrice() - avgPrice;
            console.log("win put reward:", reward);
            isCanBeTransfer = true;
            this.transferCall(
                payable(msg.sender),
                ((reward * (10**18)) / BASE / TOKENDECIMAL) * _amount
            );
        }
        //win call
        if (!zntoken.isPut() && avgPrice > zntoken.strikePrice()) {
            uint256 reward = avgPrice - zntoken.strikePrice();
            console.log("win call reward:", reward);
            isCanBeTransfer = true;
            this.transferCall(
                payable(msg.sender),
                ((reward * (10**18)) / BASE / TOKENDECIMAL) * _amount
            );
        }
        _isGetRewardSuccess = true;
    }

    function updateTokenFactory(address _zntokenFactory) external onlyOwner {
        zf = _zntokenFactory;
    }

    function transferCall(address payable _to, uint256 _amount)
        public
        payable
        returns (bool)
    {
        require(isCanBeTransfer, "Can't transfer now");
        isCanBeTransfer = false;

        (bool sent, bytes memory data) = address(_to).call{
            value: _amount,
            gas: 35000
        }("");
        //_to.transfer(_amount); //not recommend
        return sent;
    }

    receive() external payable {}

    function withdraw(address payable _recipient)
        external
        onlyOwner
        returns (bool)
    {
        _recipient.transfer(address(this).balance);
        return true;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
