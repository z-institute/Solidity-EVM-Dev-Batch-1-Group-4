// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./ZNtokenInterface.sol";
import "./ZNtoken.sol";
import "hardhat/console.sol";

contract ZNtokenFactory {
    /// @notice expireday - (price -address)
    mapping(uint256 => mapping(uint256 => address)) public expiryToZNtoken;

    /// @dev max expiry that BokkyPooBahsDateTimeLibrary can handle. (2345/12/31)
    uint256 private constant MAX_EXPIRY = 11865398400;

    /// @notice price range
    uint256 public range = 2;

    /// @notice price interval
    uint256 public interval = 1;

    /// @notice product price
    mapping(uint256 => uint256) public expiryDayToPrice;

    ZNtoken public zntoken;

    constructor() {}

    function createZNtoken(
        string memory _underlyingAsset,
        string memory _strikeAsset,
        uint256 _strikePrice,
        uint256 _expiryTimestamp,
        bool _isPut,
        string memory _name,
        string memory _symbol,
        uint256 _expiryDay
    ) external returns (bool) {
        require(
            _expiryTimestamp > block.timestamp,
            "ZNtokenFactory: Can't create expired option"
        );
        require(
            _expiryTimestamp < MAX_EXPIRY,
            "ZNtokenFactory: Can't create option with expiry > 2345/12/31"
        );
        require(
            expiryDayToPrice[_expiryDay - 1] > 0,
            "ZNtokenFactory: price is empty"
        );
        uint256 price = expiryDayToPrice[_expiryDay - 1];
        for (uint256 i = 0; i <= range; i++) {
            zntoken = new ZNtoken(
                _underlyingAsset,
                _strikeAsset,
                _strikePrice,
                _expiryTimestamp,
                _isPut,
                _name,
                _symbol
            );
            expiryToZNtoken[_expiryDay][price + i] = address(zntoken);
            console.log(
                "_expiryDay:%,price:%,address:%",
                _expiryDay,
                price + i,
                address(zntoken)
            );
        }
        return true;
    }

    function updatePrice(uint256 _expiryDay, uint256 _price) external {
        expiryDayToPrice[_expiryDay] = _price;
    }

    function buyOP(
        uint256 _expiryDay,
        uint256 _price,
        address account,
        uint256 amount
    ) external payable {
        address op = expiryToZNtoken[_expiryDay][_price];
        ZNtokenInterface optoken = ZNtokenInterface(op);
        optoken.mintZNtoken(account, amount);
    }

    function getLiquidateData(uint256 expiryDay) external view returns (bool) {
        expiryToZNtoken[expiryDay];
        return true;
    }
}
