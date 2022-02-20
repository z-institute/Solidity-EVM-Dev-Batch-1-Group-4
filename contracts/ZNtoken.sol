// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ZNtoken is ERC20 {
    /// @notice asset that the option references
    string public underlyingAsset;

    /// @notice asset that the strike price is denominated in
    string public strikeAsset;

    /// @notice strike price with decimals = 8
    uint256 public strikePrice;

    /// @notice expiration timestamp of the option, represented as a unix timestamp
    uint256 public expiryTimestamp;

    /// @notice True if a put option, False if a call option
    bool public isPut;

    uint256 private constant STRIKE_PRICE_SCALE = 1e8;
    uint256 private constant STRIKE_PRICE_DIGITS = 8;

    /// @notice owner
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(
        string memory _underlyingAsset,
        string memory _strikeAsset,
        uint256 _strikePrice,
        uint256 _expiryTimestamp,
        bool _isPut,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        owner = msg.sender;
        underlyingAsset = _underlyingAsset; //錨定資產
        strikeAsset = _strikeAsset; //價格顯示資產
        strikePrice = _strikePrice; //價格
        expiryTimestamp = _expiryTimestamp; //到期日
        isPut = _isPut;
    }

    function getZNtokenDetails()
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        return (
            underlyingAsset,
            strikeAsset,
            strikePrice,
            expiryTimestamp,
            isPut
        );
    }

    function mintZNtoken(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burnOtoken(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
