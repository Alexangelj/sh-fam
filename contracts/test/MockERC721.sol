pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721("NFT", "NFT") {
    uint256 public id;

    function mint() public {
        _safeMint(msg.sender, id);
        id++;
    }
}
