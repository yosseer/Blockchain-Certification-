// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title ProductRegistry
 * @notice ERC-1155 based registry for cosmetic product batches with traceability and certification linkage.
 * @dev Only MANUFACTURER_ROLE can register and mint products. Batch-level tokens, metadataURI is IPFS CID.
 */
contract ProductRegistry is ERC1155, AccessControl, ReentrancyGuard {
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");

    struct Product {
        bytes32 dnaHash; // Unique DNA hash for batch
        string metadataURI; // IPFS CID for batch metadata
        bool exists;
    }

    // batchId => Product
    mapping(uint256 => Product) private products;

    event ProductRegistered(uint256 indexed batchId, bytes32 dnaHash, string metadataURI, uint256 amount, address indexed manufacturer);
    event ProductTransferred(uint256 indexed batchId, address indexed from, address indexed to, uint256 amount);
    event ProductBurned(uint256 indexed batchId, address indexed operator, uint256 amount);

    /**
     * @dev Modifier to check product existence.
     */
    modifier onlyExistingProduct(uint256 batchId) {
        require(products[batchId].exists, "Product does not exist");
        _;
    }

    constructor(string memory _uri) ERC1155(_uri) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Resolve multiple inheritance for supportsInterface.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Register a new product batch and mint tokens.
     * @param batchId Unique batch identifier.
     * @param dnaHash Unique DNA hash for batch.
     * @param metadataURI IPFS CID for batch metadata.
     * @param amount Number of tokens to mint.
     */
    function registerProduct(uint256 batchId, bytes32 dnaHash, string memory metadataURI, uint256 amount) external onlyRole(MANUFACTURER_ROLE) nonReentrant {
        require(!products[batchId].exists, "Batch already registered");
        require(dnaHash != bytes32(0), "Invalid DNA hash");
        products[batchId] = Product({dnaHash: dnaHash, metadataURI: metadataURI, exists: true});
        _mint(msg.sender, batchId, amount, "");
        emit ProductRegistered(batchId, dnaHash, metadataURI, amount, msg.sender);
    }

    /**
     * @notice Mint additional tokens for an existing batch to a recipient.
     * @param batchId Batch identifier.
     * @param to Recipient address.
     * @param amount Number of tokens to mint.
     */
    function mintTo(uint256 batchId, address to, uint256 amount) external onlyRole(MANUFACTURER_ROLE) onlyExistingProduct(batchId) nonReentrant {
        _mint(to, batchId, amount, "");
        emit ProductTransferred(batchId, msg.sender, to, amount);
    }

    /**
     * @notice Burn tokens for a batch.
     * @param batchId Batch identifier.
     * @param amount Number of tokens to burn.
     */
    function burn(uint256 batchId, uint256 amount) external onlyExistingProduct(batchId) nonReentrant {
        _burn(msg.sender, batchId, amount);
        emit ProductBurned(batchId, msg.sender, amount);
    }

    /**
     * @notice Get product details for a batch.
     * @param batchId Batch identifier.
     * @return dnaHash DNA hash.
     * @return metadataURI IPFS CID.
     */
    function getProduct(uint256 batchId) external view onlyExistingProduct(batchId) returns (bytes32 dnaHash, string memory metadataURI) {
        Product memory p = products[batchId];
        return (p.dnaHash, p.metadataURI);
    }

    /**
     * @notice Override URI for batch metadata.
     * @param batchId Batch identifier.
     * @return URI string.
     */
    function uri(uint256 batchId) public view override returns (string memory) {
        return products[batchId].metadataURI;
    }
}
