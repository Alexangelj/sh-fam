// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MockERC1155 is ERC1155("") {
    uint256 public id;

    function mint() public {
        _mint(msg.sender, id, 1, new bytes(0));
        id++;
    }

    function mintId(uint256 tokenId) public {
        _mint(msg.sender, tokenId, 1, new bytes(0));
    }
}
