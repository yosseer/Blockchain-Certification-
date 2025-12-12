// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title RetailSale
 * @notice Records retail sales and product recalls for batches, emitting events for off-chain indexing.
 * @dev Only RETAILER_ROLE can record sales, REGULATOR_ROLE can flag recalls.
 */
contract RetailSale is AccessControl {
    bytes32 public constant RETAILER_ROLE = keccak256("RETAILER_ROLE");
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");

    event SaleRecorded(uint256 indexed batchId, address indexed retailer, string saleMeta, uint256 timestamp);
    event ProductRecalled(uint256 indexed batchId, string reason, uint256 timestamp);

    /**
     * @notice Record a retail sale for a batch.
     * @param batchId Batch identifier.
     * @param saleMeta Sale metadata (e.g., location, receipt hash).
     */
    function recordSale(uint256 batchId, string memory saleMeta) external onlyRole(RETAILER_ROLE) {
        emit SaleRecorded(batchId, msg.sender, saleMeta, block.timestamp);
    }

    /**
     * @notice Flag a product batch for recall.
     * @param batchId Batch identifier.
     * @param reason Reason for recall.
     */
    function flagRecall(uint256 batchId, string memory reason) external onlyRole(REGULATOR_ROLE) {
        emit ProductRecalled(batchId, reason, block.timestamp);
    }
}
