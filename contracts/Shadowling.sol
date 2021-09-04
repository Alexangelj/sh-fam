// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./libraries/ShadowlingMetadata.sol";

contract Shadowling is ShadowlingMetadata, ERC1155, ReentrancyGuard {
    constructor() ERC1155("") {}

    /// @notice Mints Shadowlings to `msg.sender`
    function claim(uint256 tokenId) external nonReentrant {
        require(tokenId > 8000 && tokenId < 8021, "Token ID invalid");
        _mint(_msgSender(), tokenId, 1, new bytes(0));
    }

    /// @notice Transfers the erc721 bag from your account to the contract and then
    /// opens it. Use it if you have already approved the transfer, else consider
    /// just transferring directly to the contract and letting the `onERC721Received`
    /// do its part
    function open(uint256 tokenId) external {
        safeTransferFrom(msg.sender, address(this), tokenId, 1, new bytes(0));
    }

    /// @notice Opens your Loot bag and mints you 8 ERC-1155 tokens for each item
    /// in that bag
    function open(address who, uint256 tokenId) private {
        // NB: We patched ERC1155 to expose `_balances` so
        // that we can manually mint to a user, and manually emit a `TransferBatch`
        // event. If that's unsafe, we can fallback to using _mint
        uint256[] memory ids = new uint256[](11);
        uint256[] memory amounts = new uint256[](11);
        ids[0] = itemId(tokenId, creatureComponents, CREATURE);
        ids[1] = itemId(tokenId, flawComponents, FLAW);
        ids[2] = itemId(tokenId, birthplaceComponents, BIRTHPLACE);
        ids[3] = itemId(tokenId, bloodlineComponents, BLOODLINE);
        ids[4] = itemId(tokenId, eyeComponents, EYES);
        ids[5] = itemId(tokenId, nameComponents, NAME);
        ids[6] = statId(tokenId, STRENGTH, "STRENGTH");
        ids[7] = statId(tokenId, DEXTERITY, "DEXTERITY");
        ids[8] = statId(tokenId, CONSTITUTION, "CONSTITUTION");
        ids[9] = statId(tokenId, INTELLIGENCE, "INTELLIGENCE");
        ids[10] = statId(tokenId, WISDOM, "WISDOM");
        ids[11] = statId(tokenId, CHARISMA, "CHARISMA");
        for (uint256 i = 0; i < ids.length; i++) {
            amounts[i] = 1;
            // +21k per call / unavoidable - requires patching OZ
            //_balances[ids[i]][who] += 1;
        }

        emit TransferBatch(_msgSender(), address(0), who, ids, amounts);
    }

    /// @notice Re-assembles the original Loot bag by burning all the ERC1155 tokens
    /// which were inside of it. Because ERC1155 tokens are fungible, you can give it
    /// any token that matches the one that was originally in it (i.e. you don't need to
    /// give it the exact e.g. Divine Robe that was created during minting.
    function reassemble(uint256 tokenId) external {
        // 1. burn the items
        burnItem(tokenId, creatureComponents, CREATURE);
        burnItem(tokenId, flawComponents, FLAW);
        burnItem(tokenId, birthplaceComponents, BIRTHPLACE);
        burnItem(tokenId, bloodlineComponents, BLOODLINE);
        burnItem(tokenId, eyeComponents, EYES);
        burnItem(tokenId, nameComponents, NAME);
        burnStat(tokenId, STRENGTH, "STRENGTH");
        burnStat(tokenId, DEXTERITY, "DEXTERITY");
        burnStat(tokenId, CONSTITUTION, "CONSTITUTION");
        burnStat(tokenId, INTELLIGENCE, "INTELLIGENCE");
        burnStat(tokenId, WISDOM, "WISDOM");
        burnStat(tokenId, CHARISMA, "CHARISMA");

        // 2. give back the bag
        safeTransferFrom(address(this), msg.sender, tokenId, 1, new bytes(0));
    }

    function itemId(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        uint256 itemType
    ) private view returns (uint256) {
        uint256[5] memory components = componentsFn(tokenId);
        return TokenId.toId(components, itemType);
    }

    function statId(
        uint256 tokenId,
        uint256 itemType,
        string memory keyPrefix
    ) private view returns (uint256) {
        uint256[5] memory components = statComponent(tokenId, keyPrefix);
        return TokenId.toId(components, itemType);
    }

    /// @notice Extracts the components associated with the ERC721 Loot bag using
    /// dhof's LootComponents utils and proceeds to burn a token for the corresponding
    /// item from the msg.sender.
    function burnItem(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        uint256 itemType
    ) private {
        uint256[5] memory components = componentsFn(tokenId);
        uint256 id = TokenId.toId(components, itemType);
        _burn(msg.sender, id, 1);
    }

    function burnStat(
        uint256 tokenId,
        uint256 itemType,
        string memory keyPrefix
    ) private {
        uint256[5] memory components = statComponent(tokenId, keyPrefix);
        uint256 id = TokenId.toId(components, itemType);
        _burn(msg.sender, id, 1);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return tokenURI(tokenId);
    }
}
