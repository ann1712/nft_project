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
    uint256 maxSupply = 3;
    mapping (address => bool) public whiteList;
    uint256[2] mintPrice = [0.01 ether, 0.02 ether];
    uint256[2] maxRound = [1, 2]; // for dev
    uint256[2] startTime = [1681233120, 1681319520];
    uint public mintInterval = 1 days;
    uint256[2] roundSold;

    constructor(uint256 _maxSupply, uint256[2] memory _maxRound) 
        ERC721("MyNFT", "MNFT") {
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://uri.nftio/";
    }

    //OG round
    function whiteListMint() public payable {
        uint256 round = _getCurrentRound();
        require(round == 0, "WhiteList Mint is not available!");
        require(whiteList[msg.sender], "You'r not in WhiteList!");
        require(roundSold[round] < maxRound[round], "All NFTs are Sold out !");
        require(msg.value == mintPrice[round], "Not enough Funds");
        _mint();
        roundSold[round]++;

    } 

    // Public round
    function publicMint() public payable {
        uint256 round = _getCurrentRound();
        require(round == 1, "Public Mint is is not available!");
        require(roundSold[round] < maxRound[round], "All NFTs are Sold out !");
        require(msg.value == 0.01 ether, "Not enough Funds");
        _mint();
        roundSold[round]++;
    }

    // Mint
    function _mint() internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        string memory _tokenURI = tokenURI(tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }

    // Get current Round
    function _getCurrentRound() private view returns (uint256){
        for(uint256 i = 0; i < 2; i++){
            if(block.timestamp >= startTime[i] && block.timestamp < startTime[i] + mintInterval) return i;
        }
        return 2;
    }

    // Populate WhiteList
    function setWhiteList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i< addresses.length; i++){
            whiteList[addresses[i]] = true;
        }
    }

    function withdraw(address _addr) external onlyOwner {
        //get balance of contract
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
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