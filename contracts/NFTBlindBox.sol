// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTBlindBox is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    uint8 public maxAmount = 10;
    Counters.Counter private _tokenIds;

    uint256 public nftPrice = 0.01 ether;

    bool public revealed = false;
    string public revealedURI; 
    string public unrevealedURI;
    string constant baseExtension = ".json";

    constructor() ERC721("LosAngelCat", "LAC") {}

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = "";
        if(revealed) {
            baseURI = revealedURI;
            return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension)) : "";
        } else {
            baseURI = unrevealedURI;
            return baseURI;
        }
    }

    function setUnrevealedUrl(string memory unrevealedURI_) public onlyOwner{
        require(bytes(unrevealedURI_).length > 0, "Input URI is empty string");
        unrevealedURI = unrevealedURI_;
    }

    function setRevealedUrl(string memory revealedURI_) public onlyOwner{
        require(bytes(revealedURI_).length > 0, "Input URI is empty string");
        revealedURI = revealedURI_;
    }

    function switchRevealed() public onlyOwner {
        revealed = !revealed;
    }

    function mint() public payable {
        require(_tokenIds.current() < maxAmount, "only 10 NFT for sell");
        require(msg.value >= nftPrice, "Ether is not enough");
        _safeMint(msg.sender, _tokenIds.current());
        _tokenIds.increment();

        // refund
        if (msg.value > nftPrice) {
            uint256 refund = msg.value - nftPrice;
            (bool sent, ) = msg.sender.call{value: refund}("");
            require(sent, "Failed to send Ether");
        }
    }

    function withdraw () external onlyOwner {
        (bool sent, ) = address(msg.sender).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}