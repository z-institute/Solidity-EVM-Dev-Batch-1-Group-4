// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

interface ZNtokenInterface {
    function underlyingAsset() external view returns (address);

    function strikeAsset() external view returns (address);

    function strikePrice() external view returns (uint256);

    function buyPrice() external view returns (uint256);

    function expiryTimestamp() external view returns (uint256);

    function isPut() external view returns (bool);

    function owner() external view returns (address);

    function decimals() external pure returns (uint8);

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

    function transferZNtoken(address account, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
