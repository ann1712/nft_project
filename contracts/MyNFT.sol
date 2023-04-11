// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    bool publicMintOpen = false;
    bool whiteListMintOpen = false;
    uint256 maxSupply = 2;
    mapping (address => bool) public whiteList;

    constructor() ERC721("MyNFT", "MNFT") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://uri.nftio/";
    }

    //OG round
    function whiteListMint(address _addr) public payable {
        require(whiteListMintOpen, "WhiteList Mint is closed!");
        require(whiteList[_addr], "You'r not in WhiteList!");
        require(totalSupply() < maxSupply, "All NFTs are Sold out !");
        require(msg.value == 0.01 ether, "Not enough Funds");
        _mint();

    } 

    // Public round
    function publicMint() public payable {
        require(publicMintOpen, "Public Mint is closed!");
        require(totalSupply() < maxSupply, "All NFTs are Sold out !");
        require(msg.value == 0.01 ether, "Not enough Funds");
        _mint();
    }

    // Mint
    function _mint() internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    //Modify round
    function editRound(bool _publicMintOpen, bool _whiteListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        whiteListMintOpen = _whiteListMintOpen;
    }

    // Populate WhiteList
    function setWhiteList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i< addresses.length; i++){
            whiteList[addresses[i]] = true;
        }
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}