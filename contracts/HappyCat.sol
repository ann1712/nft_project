// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract HappyCat is ERC721{
    using Strings for uint256;

    string public uri = "ipfs/HappyCatUri/";

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {

    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(_exists(tokenId), "Token ID is not available");
        if(bytes(uri).length > 0){
            return string(abi.encodePacked(uri, tokenId.toString()));
        } else {
            return "";
        }
    }

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}