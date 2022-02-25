// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "hardhat/console.sol";

/*
use other contract call will face error
=> Error: Transaction reverted: function returned an unexpected amount of data
 */
contract PriceOracle {
    /// @dev fee
    uint256 internal constant FEE = 5;

    /// @dev initial array size
    uint256 internal constant ARRAYSIZE = 20;

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
}
