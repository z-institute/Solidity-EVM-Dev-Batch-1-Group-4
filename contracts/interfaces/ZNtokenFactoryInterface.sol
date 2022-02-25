// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

interface ZNtokenFactoryInterface {
    function getTokenAddress(
        uint256 _expiryDay,
        bool _isPut,
        uint256 _price
    ) external view returns (address);

    function getAvgPriceByDay(uint256 _expiryDay)
        external
        view
        returns (uint256);
}
