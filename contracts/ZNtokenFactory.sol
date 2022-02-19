// SPDX-License-Identifier: MIT
pragma solidity > 0.6.10;
import {Create2} from "../Create2.sol";

contract ZNtokenFactory is ERC20 {

    /// @notice expireday - (id -address)
    mapping(uint256 => mapping(uint8 => address)) public expiryToZNtoken;
    
    /// @dev max expiry that BokkyPooBahsDateTimeLibrary can handle. (2345/12/31)
    uint256 private constant MAX_EXPIRY = 11865398400;

    constructor() public {

    }

    function createZNtoken(
        string _underlyingAsset,
        string _strikeAsset,
        uint256 _strikePrice,
        uint256 _expiryTimestamp,
        bool _isPut
    ) external returns (address) {
        require(_expiryTimestamp > now, "ZNtokenFactory: Can't create expired option");
        require(_expiryTimestamp < MAX_EXPIRY, "ZNtokenFactory: Can't create option with expiry > 2345/12/31");
        
        Create2.deploy(0, 0x00, initcode);
    }

    function getLiquidateData(uint256 expiryDay) external returns(address){
        return expiryToZNtoken[expiryDay];
    }
}