// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AuthorizationManager {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    mapping(bytes32 => bool) public usedAuthorizations;

    address public immutable authority;

    event AuthorizationConsumed(bytes32 indexed authorizationId);

    constructor(address _authority) {
        require(_authority != address(0), "Invalid authority");
        authority = _authority;
    }

    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        bytes32 authorizationId,
        bytes calldata signature
    ) external returns (bool) {
        require(!usedAuthorizations[authorizationId], "Authorization already used");

        bytes32 messageHash = keccak256(
            abi.encode(
                vault,
                block.chainid,
                recipient,
                amount,
                authorizationId
            )
        );

        bytes32 ethSignedHash = messageHash.toEthSignedMessageHash();
        address recoveredSigner = ethSignedHash.recover(signature);

        require(recoveredSigner == authority, "Invalid authorization signature");

        // Effects before interaction
        usedAuthorizations[authorizationId] = true;

        emit AuthorizationConsumed(authorizationId);

        return true;
    }
}
