// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Governance
 * @notice Manages roles, multisig admin, and policy updates for the certification system.
 * @dev Only multisig (DEFAULT_ADMIN_ROLE) can add/remove members and update policies.
 */
contract Governance is AccessControl {
    event MemberAdded(address indexed account, bytes32 role);
    event MemberRemoved(address indexed account, bytes32 role);
    event PolicyUpdated(bytes32 policyHash);

    /**
     * @notice Add a member to a role.
     * @param account Address to add.
     * @param role Role to assign.
     */
    function addMember(address account, bytes32 role) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(role, account);
        emit MemberAdded(account, role);
    }

    /**
     * @notice Remove a member from a role.
     * @param account Address to remove.
     */
    function removeMember(address account, bytes32 role) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(role, account);
        emit MemberRemoved(account, role);
    }

    /**
     * @notice Set or update a policy hash.
     * @param policyHash Hash of the policy document (IPFS CID or hash).
     */
    function setPolicy(bytes32 policyHash) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit PolicyUpdated(policyHash);
    }
}
