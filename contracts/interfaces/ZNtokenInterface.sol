// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

interface ZNtokenInterface {
    function underlyingAsset() external view returns (address);

    function strikeAsset() external view returns (address);

    function strikePrice() external view returns (uint256);

    function expiryTimestamp() external view returns (uint256);

    function isPut() external view returns (bool);

    function owner() external view returns (address);

    function getOtokenDetails()
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        );

    function mintZNtoken(address account, uint256 amount) external;

    function burnZNtoken(address account, uint256 amount) external;
}
