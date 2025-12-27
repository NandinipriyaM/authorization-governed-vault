// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorizationManager {
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        bytes32 authorizationId,
        bytes calldata signature
    ) external returns (bool);
}

contract SecureVault {
    IAuthorizationManager public immutable authorizationManager;

    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount, bytes32 authorizationId);

    constructor(address _authorizationManager) {
        require(_authorizationManager != address(0), "Invalid authorization manager");
        authorizationManager = IAuthorizationManager(_authorizationManager);
    }

    /// @notice Accept ETH deposits from anyone
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw ETH with valid authorization
     */
    function withdraw(
        address payable recipient,
        uint256 amount,
        bytes32 authorizationId,
        bytes calldata signature
    ) external {
        require(address(this).balance >= amount, "Insufficient vault balance");

        // 🔐 Authorization check (external)
        bool authorized = authorizationManager.verifyAuthorization(
            address(this),
            recipient,
            amount,
            authorizationId,
            signature
        );

        require(authorized, "Authorization failed");

        // 💸 Interaction LAST
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawal(recipient, amount, authorizationId);
    }
}
