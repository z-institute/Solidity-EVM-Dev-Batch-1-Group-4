// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./interfaces/ZNtokenInterface.sol";
import "./ZNtoken.sol";
import "./PriceOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract ZNtokenFactory is Ownable {
    /// @notice expireday-isput-price-tokenaddress
    mapping(uint256 => mapping(bool => mapping(uint256 => address)))
        public expiryToZNtoken;

    /// @notice price range
    uint256 public range = 6; //can update

    /// @dev base price decimals(price= 1 represent 0.1 ether)
    uint256 internal constant BASE = 10;

    /// @dev fee
    uint256 internal constant FEE = 5;

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

        //getStrikePrices
        (uint256[] memory strikePrices, uint256 index) = getStrikePrices(
            avgPrice,
            range,
            BASE
        );

        uint256 strikePrice = 0;
        uint256 buyPrice = 0;

        for (uint256 i = 0; i < index; i++) {
            //getBuyPrices
            strikePrice = strikePrices[i];
            buyPrice = getBuyPrice(_isPut, avgPrice, strikePrice, BASE);
            console.log("strikePrice:%s,buyPrice:%s", strikePrice, buyPrice);

            (string memory name, string memory symbol) = getNameAndSymbol(
                _underlyingAsset,
                strikePrice,
                _expiryDay,
                buyPrice,
                _isPut
            );
            console.log("name:%s,symbol:%s", name, symbol);

            zntoken = new ZNtoken(
                _underlyingAsset,
                _strikeAsset,
                strikePrice,
                buyPrice,
                _expiryDay,
                _isPut,
                name, //_name
                symbol //_symbol
            );
            expiryToZNtoken[_expiryDay][_isPut][strikePrice] = address(zntoken);
        }
        return true;
    }

    function updatePrice(uint256 _expiryDay, uint256 _price)
        external
        onlyOwner
    {
        expiryDayToPrice[_expiryDay] = _price;
        console.log("updatePrice:_expiryDay:%s,_price:%s", _expiryDay, _price);
    }

    function buyOP(
        uint256 _expiryDay,
        bool _isPut,
        uint256 _price,
        address account,
        uint256 amount
    ) public payable {
        address op = expiryToZNtoken[_expiryDay][_isPut][_price];
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

    function getTokenAddress(
        uint256 _expiryDay,
        bool _isPut,
        uint256 _price
    ) external view returns (address) {
        return expiryToZNtoken[_expiryDay][_isPut][_price];
    }

    function getAvgPriceByDay(uint256 _expiryDay)
        external
        view
        returns (uint256)
    {
        return expiryDayToPrice[_expiryDay];
    }

    function getStrikePrices(
        uint256 _avgPrice,
        uint256 _range,
        uint256 _base
    ) public pure returns (uint256[] memory strikePrices, uint256 index) {
        strikePrices = new uint256[](20);
        //downRange
        uint256 downRange = _avgPrice / _base;
        for (uint256 i = downRange; i >= 1; i--) {
            //console.log("i*base", i * _base);
            if (_avgPrice > i * _base) {
                strikePrices[index] = _avgPrice - i * _base;
                //console.log("strikePrices:", strikePrices[index]);
                index++;
            }
        }
        //upRange
        for (uint256 i = 0; i <= _range; i++) {
            strikePrices[index] = _avgPrice + i * _base;
            //console.log("strikePrices2:", strikePrices[index]);
            index++;
        }
        //console.log("index:", index);
    }

    function getBuyPrice(
        bool _isPut,
        uint256 _avgPrice,
        uint256 _strikePrice,
        uint256 _base
    ) public pure returns (uint256) {
        //TODO:need short the code
        uint256 spreadPrice = 0;
        uint256 outOfPrice = 0;
        if (!_isPut) {
            if (_avgPrice >= _strikePrice) {
                spreadPrice = _avgPrice - _strikePrice;
                return FEE + spreadPrice;
            } else {
                spreadPrice = _strikePrice - _avgPrice;
                outOfPrice = spreadPrice / _base;
                if (FEE > spreadPrice / _base) {
                    return FEE - spreadPrice / _base;
                } else {
                    return 1; //lowest price is 0.1
                }
            }
        } else {
            if (_avgPrice >= _strikePrice) {
                spreadPrice = _avgPrice - _strikePrice;
                outOfPrice = spreadPrice / _base;
                if (FEE > spreadPrice / _base) {
                    return FEE - spreadPrice / _base;
                } else {
                    return 1; //lowest price is 0.1
                }
            } else {
                spreadPrice = _strikePrice - _avgPrice;
                return FEE + spreadPrice;
            }
        }
    }

    function getNameAndSymbol(
        string memory _underlyingAsset,
        uint256 _strikePrice,
        uint256 _expiryDay,
        uint256 _buyPrice,
        bool _isPut
    ) internal pure returns (string memory, string memory) {
        return (
            string(
                abi.encodePacked(
                    _underlyingAsset,
                    "_",
                    _isPut ? "PUT" : "CALL",
                    "_",
                    Strings.toString(_strikePrice),
                    "_",
                    Strings.toString(_expiryDay),
                    "_",
                    Strings.toString(_buyPrice)
                )
            ),
            string(
                abi.encodePacked(
                    "UnderlyingAsset:",
                    _underlyingAsset,
                    ",Category:",
                    _isPut ? "PUT" : "CALL",
                    ",Strike Price:",
                    Strings.toString(_strikePrice / BASE),
                    ".",
                    Strings.toString(_strikePrice % BASE),
                    ",ExpiryDay:",
                    Strings.toString(_expiryDay),
                    ",BuyPrice:",
                    Strings.toString(_buyPrice / BASE),
                    ".",
                    Strings.toString(_buyPrice % BASE)
                )
            )
        );
    }
}
