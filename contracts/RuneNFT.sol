// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RuneNFT is ERC721, ERC721Enumerable, Ownable, ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint256[2] MINT_PRICE = [0.01 ether, 0.02 ether];
    mapping(address => bool) whitelist;
    uint256[2] TIME_MINT = [1681344000, 1681430400];
    uint256[2] public MAX_SUPPLY_ROUND = [1, 2];
    uint256[2] public soldRound;

    string baseUri = "https://raw.githubusercontent.com/ann1712/nft_project/main/metadata/";
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        _tokenIdCounter.increment();
    }

    function getCurrentRound() internal view returns (uint256){
        for (uint256 i=0; i < TIME_MINT.length; i++){
            if(block.timestamp < TIME_MINT[i]) return i;
        }
        return 2;
    }  

    //Populate Whitelist
    function setWhitelist(address[] calldata _addr) external onlyOwner {
        
        for (uint256 i = 0; i < _addr.length; i++){
            whitelist[_addr[i]] = true;
        }
    }

    function mintAll() public payable {
        uint256 round = getCurrentRound();
        require(round > 0, "Mint're not opened!");
        if(round == 1){
            require(whitelist[msg.sender], "You'r not in the whitelist!");   
        }
        require(soldRound[round-1] < MAX_SUPPLY_ROUND[round-1], "NFT sold out!");
        require(msg.value >= MINT_PRICE[round-1], "Not enough money!");
        _mint();
        soldRound[round-1]++;
        
    }

    // Mint Internal
    function _mint() internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        string memory tokenUri = tokenURI(tokenId);
        _setTokenURI(tokenId, tokenUri);
    }

    //Withdraw
    function withdraw(address _addr) external onlyOwner(){
        // Get balance of contract
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721,ERC721URIStorage) returns (string memory){
        require(_exists(tokenId), "ERC721Metadata: Nonexistent Token Id");

        string memory buri = baseUri;
        return bytes(buri).length > 0 ? string(abi.encodePacked(buri, tokenId.toString(), ".json")) : '';
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable){
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId) public view override (ERC721, ERC721Enumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }

}