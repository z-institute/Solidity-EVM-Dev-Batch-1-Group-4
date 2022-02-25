// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZNtoken is ERC20, Ownable {
    /// @notice asset that the option references
    string public underlyingAsset;

    /// @notice asset that the strike price is denominated in
    string public strikeAsset;

    /// @notice strike price with decimals = 2
    uint256 public strikePrice;

    /// @notice suggest buyPrice
    uint256 public buyPrice;

    /// @notice expiration timestamp of the option, represented as a unix timestamp
    uint256 public expiryDay;

    /// @notice True if a put option, False if a call option
    bool public isPut;

    uint256 private constant STRIKE_PRICE_SCALE = 1e2;
    uint256 private constant STRIKE_PRICE_DIGITS = 2;

    constructor(
        string memory _underlyingAsset,
        string memory _strikeAsset,
        uint256 _strikePrice,
        uint256 _buyPrice,
        uint256 _expiryDay,
        bool _isPut,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        underlyingAsset = _underlyingAsset; //錨定資產
        strikeAsset = _strikeAsset; //價格顯示資產
        strikePrice = _strikePrice; //價格
        buyPrice = _buyPrice; //建議價格
        expiryDay = _expiryDay; //到期日
        isPut = _isPut;
        _mint(owner(), 10000000000);
    }

    function getZNtokenDetails()
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        return (
            underlyingAsset,
            strikeAsset,
            strikePrice,
            buyPrice,
            expiryDay,
            isPut
        );
    }

    function decimals() public pure override returns (uint8) {
        return 2;
    }

    function mintZNtoken(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burnZNtoken(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    function transferZNtoken(address account, uint256 amount)
        external
        returns (bool _isTransfer)
    {
        _isTransfer = false;
        transfer(account, amount);
        _isTransfer = true;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
