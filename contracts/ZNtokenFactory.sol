// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./interfaces/ZNtokenInterface.sol";
import "./ZNtoken.sol";
import "./PriceOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract ZNtokenFactory is Ownable {
    /// @notice expireday - (price -address)
    mapping(uint256 => mapping(uint256 => address)) public expiryToZNtoken;

    /// @notice price range
    uint256 public range = 2; //can update

    /// @dev base price decimals
    uint256 internal constant BASE = 10;

    /// @notice product price
    mapping(uint256 => uint256) public expiryDayToPrice;

    /// @notice mint token from others ERC20 contract
    ZNtoken internal zntoken;

    /// @notice priceOracle
    PriceOracle internal _priceOracle;

    struct StrikePriceToContractAddress {
        uint256 strikePrice;
        uint256 contractAdress;
    }

    constructor() {}

    function createZNtoken(
        string memory _underlyingAsset,
        string memory _strikeAsset,
        uint256 _expiryDay,
        bool _isPut
    ) external onlyOwner returns (bool) {
        require(
            expiryDayToPrice[_expiryDay - 2] > 0,
            "ZNtokenFactory: price is empty"
        );
        uint256 avgPrice = expiryDayToPrice[_expiryDay - 2];
        uint256 strikePrice = 0;
        uint256 buyPrice = 0;

        for (uint256 i = 0 - range; i <= range; i++) {
            strikePrice = _priceOracle.getStrikePrice(avgPrice, i);
            if (strikePrice < BASE) {
                continue; //price need more than the 1 ether
            }
            buyPrice = _priceOracle.getBuyPrice(_isPut, avgPrice, strikePrice);

            string memory name = string(
                abi.encodePacked(
                    _underlyingAsset,
                    "-",
                    strikePrice,
                    "-",
                    _expiryDay
                )
            );

            zntoken = new ZNtoken(
                _underlyingAsset,
                _strikeAsset,
                strikePrice,
                buyPrice,
                _expiryDay,
                _isPut,
                name, //_name
                name //_symbol
            );
            expiryToZNtoken[_expiryDay][strikePrice] = address(zntoken);
        }
        return true;
    }

    function updatePrice(uint256 _expiryDay, uint256 _price)
        external
        onlyOwner
    {
        expiryDayToPrice[_expiryDay] = _price;
    }

    function buyOP(
        uint256 _expiryDay,
        uint256 _price,
        address account,
        uint256 amount
    ) public payable {
        address op = expiryToZNtoken[_expiryDay][_price];
        ZNtokenInterface optoken = ZNtokenInterface(op);
        optoken.mintZNtoken(account, amount);
    }

    function withdraw(address payable _recipient)
        external
        onlyOwner
        returns (bool)
    {
        _recipient.transfer(address(this).balance);
        return true;
    }

    function getTokenAddress(uint256 _expiryDay, uint256 _price)
        external
        view
        returns (address)
    {
        return expiryToZNtoken[_expiryDay][_price];
    }

    function getAvgPriceByDay(uint256 _expiryDay)
        external
        view
        returns (uint256)
    {
        return expiryDayToPrice[_expiryDay];
    }
}
