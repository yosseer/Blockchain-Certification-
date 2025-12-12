// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CertificationManager
 * @notice Manages issuance and revocation of lab certificates for product batches.
 * @dev Only LAB_ROLE can issue, REGULATOR_ROLE/multisig can revoke.
 */
contract CertificationManager is AccessControl {
    bytes32 public constant LAB_ROLE = keccak256("LAB_ROLE");
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");

    struct Certificate {
        uint256 certId;
        uint256 batchId;
        address lab;
        bytes32 reportCID;
        uint256 issueDate;
        bool revoked;
        string revokeReason;
    }

    uint256 public nextCertId;
    mapping(uint256 => Certificate) public certificates; // certId => Certificate
    mapping(uint256 => uint256[]) public batchCertificates; // batchId => certIds

    event CertificateIssued(uint256 indexed certId, uint256 indexed batchId, address indexed lab, bytes32 reportCID, uint256 issueDate);
    event CertificateRevoked(uint256 indexed certId, string reason);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Issue a certificate for a product batch.
     * @param batchId Batch identifier.
     * @param reportCID IPFS CID hash of the lab report.
     */
    function issueCertificate(uint256 batchId, bytes32 reportCID) external onlyRole(LAB_ROLE) {
        require(reportCID != bytes32(0), "Invalid report CID");
        uint256 certId = ++nextCertId;
        certificates[certId] = Certificate({
            certId: certId,
            batchId: batchId,
            lab: msg.sender,
            reportCID: reportCID,
            issueDate: block.timestamp,
            revoked: false,
            revokeReason: ""
        });
        batchCertificates[batchId].push(certId);
        emit CertificateIssued(certId, batchId, msg.sender, reportCID, block.timestamp);
    }

    /**
     * @notice Revoke a certificate.
     * @param certId Certificate identifier.
     * @param reason Reason for revocation.
     */
    function revokeCertificate(uint256 certId, string memory reason) external onlyRole(REGULATOR_ROLE) {
        Certificate storage cert = certificates[certId];
        require(!cert.revoked, "Already revoked");
        cert.revoked = true;
        cert.revokeReason = reason;
        emit CertificateRevoked(certId, reason);
    }

    /**
     * @notice Verify a certificate's validity.
     * @param certId Certificate identifier.
     * @return valid True if not revoked.
     */
    function verifyCertificate(uint256 certId) external view returns (bool valid) {
        Certificate memory cert = certificates[certId];
        return !cert.revoked;
    }

    /**
     * @notice Get the latest certificate for a batch.
     * @param batchId Batch identifier.
     * @return certId Latest certificate ID.
     */
    function getLatestCertificate(uint256 batchId) external view returns (uint256 certId) {
        uint256[] memory certs = batchCertificates[batchId];
        require(certs.length > 0, "No certificates");
        return certs[certs.length - 1];
    }
}
