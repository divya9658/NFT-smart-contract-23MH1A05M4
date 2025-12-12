// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Use a recent Solidity version

// Import the required OpenZeppelin standards and utilities
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
//import "@openzeppelin/contracts/utils/Counters/Counters.sol";


// NftCollection inherits ERC721URIStorage (for core ERC721 + metadata), 
// Ownable (for admin control), and Pausable (for pausing operations).
contract NftCollection is ERC721URIStorage, Ownable, Pausable {
    
    // --- State Variables (Step 2) ---
    
    // Use Counters to safely track and generate new token IDs
    // using Counters for Counters.Counter;
    // Counters.Counter private _tokenIdCounter;
    uint256 private _nextTokenId;

    // Define the immutable maximum number of tokens
    uint256 public immutable MAX_SUPPLY;
    
    // Base URI for metadata (e.g., ipfs://.../ or https://api.collection.com/)
    string private _baseTokenURI;


    // --- Constructor (Initial Setup) ---

    // The contract owner (admin) is set to msg.sender by Ownable.
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint256 maxSupply_
    )
        // ERC721 initializer: sets the name and symbol
        ERC721(name_, symbol_)
        // Ownable initializer: sets the deployer as the contract owner (admin)
        Ownable(msg.sender)
    {
        // Require a positive max supply
        require(maxSupply_ > 0, "Max supply must be greater than zero");
        MAX_SUPPLY = maxSupply_;
        _baseTokenURI = baseURI_;
    }


    // --- Access Control and Configuration (Step 3) ---

    // Function to update the base URI (Admin-only)
    // This allows the admin to change where the metadata points.
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    // Function to pause minting/transfers (Admin-only)
    function pause() public onlyOwner {
        _pause();
    }

    // Function to unpause minting/transfers (Admin-only)
    function unpause() public onlyOwner {
        _unpause();
    }


    // --- Minting Logic ---
    
    // safeMint is an admin-only function to create new tokens.
    // The `whenNotPaused` modifier, inherited from Pausable, ensures 
    // this function can't run if the contract is paused.
    function safeMint(address to) public onlyOwner whenNotPaused {
        uint256 currentId = _nextTokenId;
        
        // 🚨 Supply Constraint Check
        require(currentId < MAX_SUPPLY, "Max supply reached");

        //_tokenIdCounter.increment();
        _nextTokenId++;
        // _safeMint: mints the token and checks if 'to' is a contract that supports ERC721Receiver
        _safeMint(to, currentId);
    }


    // --- Metadata/Token URI Handling (Step 4) ---

    // Override the internal base URI function from ERC721URIStorage 
    // to allow tokenURI() to return the concatenated URI.
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // Override tokenURI to return the full metadata link: baseURI + tokenId.
    // If the token does not exist, ERC721URIStorage's implementation will revert.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorage)
        returns (string memory)
    {
        // This function will automatically use _baseURI() and convert the tokenId 
        // to a string. It also checks token existence, fulfilling Step 4's validation requirement.
        return super.tokenURI(tokenId);
    }
    
    // Helper to view current total supply
    function totalSupply() public view returns (uint256) {
        //return _tokenIdCounter.current();
        return _nextTokenId;
    }
}