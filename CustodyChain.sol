// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CustodyChain
 * @notice Records custody transfers for product batches, emitting events for off-chain indexing.
 * @dev Only DISTRIBUTOR_ROLE or MANUFACTURER_ROLE can record transfers.
 */
contract CustodyChain is AccessControl {
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");

    event TransferRecorded(uint256 indexed batchId, address indexed from, address indexed to, string location, uint256 timestamp);

    /**
     * @notice Record a custody transfer for a batch.
     * @param batchId Batch identifier.
     * @param to Recipient address.
     * @param location Location string.
     */
    function recordTransfer(uint256 batchId, address to, string memory location) external {
        require(hasRole(DISTRIBUTOR_ROLE, msg.sender) || hasRole(MANUFACTURER_ROLE, msg.sender), "Not authorized");
        emit TransferRecorded(batchId, msg.sender, to, location, block.timestamp);
    }

    /**
     * @notice Approve a transfer (optional two-step).
     * @param batchId Batch identifier.
     */
    function approveTransfer(uint256 batchId) external {
        // Optional: implement off-chain proof or approval logic if needed
        // For now, just emit event for off-chain tracking
        emit TransferRecorded(batchId, address(0), msg.sender, "Approved", block.timestamp);
    }
}
