// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract PriceOracle {
    /// @dev base price decimals
    uint256 internal constant BASE = 10;

    /// @dev fee
    uint256 internal constant FEE = 5;

    constructor() {}

    function getStrikePrice(uint256 _avgPrice, uint256 _range)
        external
        pure
        returns (uint256)
    {
        return _avgPrice + (BASE * _range);
    }

    function getBuyPrice(
        bool _isPut,
        uint256 _basePrice,
        uint256 _strikePrice
    ) external pure returns (uint256 _buyPrice) {
        uint256 spreadPrice = _basePrice - _strikePrice;
        if (!_isPut) {
            if (spreadPrice >= 0) {
                return FEE + BASE * spreadPrice;
            } else {
                return FEE + spreadPrice <= 0 ? 1 : FEE + spreadPrice;
            }
        } else {
            if (spreadPrice <= 0) {
                return FEE - (BASE * spreadPrice);
            } else {
                return FEE - spreadPrice <= 0 ? 1 : FEE + spreadPrice;
            }
        }
    }
}
