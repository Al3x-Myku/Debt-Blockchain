// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// NFT-ul de chitanta, ca sa stii cine are de primit
contract DebtReceipt is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    // aici tinem minte cine are voie sa arda NFT-uri
    mapping(address => bool) public authorizedBurners;

    constructor() ERC721("Debt Receipt", "DREC") {}

    // dai voie la cineva (gen contract) sa arda NFT-uri
    function authorizeBurner(address burner) public onlyOwner {
        authorizedBurners[burner] = true;
    }

    // daca vrei sa nu mai aiba voie cineva sa arda
    function revokeBurner(address burner) public onlyOwner {
        authorizedBurners[burner] = false;
    }

    // mintam NFT-ul, doar ownerul poate
    function safeMint(address to, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }

    // functia asta arde NFT-ul, doar cine e autorizat sau ownerul
    function burnByManager(uint256 tokenId) public {
        require(_exists(tokenId), "ERC721: burn of nonexistent token");
        require(authorizedBurners[msg.sender] || msg.sender == owner(), "Nu ai voie sa arzi");
        _burn(tokenId);
    }
    
    // astea de jos sunt ca sa nu se supere compilatorul, suprascriem ce trebuie
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}