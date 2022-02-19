// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.10;

interface ZNtokenInterface {
    function underlyingAsset() external view returns(address);

    function strikeAsset() external view returns(address);

    function strikePrice() external view returns(uint256);

    function expiryTimestamp() external view returns(uint256);

    function isPut() external view returns(bool);

    function owner() external view returns(address);

    function constructor(
        string _underlyingAsset,
        string _strikeAsset,
        uint256 _strikePrice,
        uint256 _expiryTimestamp,
        bool _isPut,
        string name,
        string symbol,
    );

    function getOtokenDetails()
    external
    view
    returns(
        string,
        string,
        uint256,
        uint256,
        bool
    );

    function mintOtoken(address account, uint256 amount) external;

    function burnOtoken(address account, uint256 amount) external;
}