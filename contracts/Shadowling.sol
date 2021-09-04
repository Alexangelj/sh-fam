// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "./libraries/metadata/ShadowlingMetadata.sol";
import "./libraries/MetadataUtils.sol";

contract Shadowling is
    ShadowlingMetadata,
    ERC1155,
    IERC1155Receiver,
    ReentrancyGuard
{
    constructor() ERC1155("") {}

    mapping(uint256 => Attributes.ItemIds) public propertiesOf;
    mapping(address => mapping(uint256 => bool)) public deposited;

    /// @notice Mints Shadowlings to `msg.sender`, cannot mint 0 tokenId
    function claim(uint256 tokenId) external nonReentrant {
        require(tokenId > 0 && tokenId < 8021, "Token ID invalid");
        string memory number = toString(StatComponents.roll("35434553"));

        Attributes.ItemIds memory props = Attributes.ItemIds({
            creature: Components.random(number),
            flaw: Components.random(number),
            origin: Components.random(number),
            bloodline: Components.random(number),
            eyes: Components.random(number),
            name: Components.random(number)
        });
        propertiesOf[tokenId] = props;
        _mint(_msgSender(), tokenId, 1, new bytes(0));
    }

    /// @notice Transfers the erc721 bag from your account to the contract and then
    /// opens it. Use it if you have already approved the transfer, else consider
    /// just transferring directly to the contract and letting the `onERC721Received`
    /// do its part
    function open(uint256 tokenId) external {
        require(tokenId > 0 && tokenId < 8021, "Token ID invalid");
        safeTransferFrom(msg.sender, address(this), tokenId, 1, new bytes(0));
        open(msg.sender, tokenId);
        deposited[msg.sender][tokenId] = true;
    }

    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256,
        bytes calldata
    ) external override(IERC1155Receiver) returns (bytes4) {
        // only supports callback from this contract
        require(msg.sender == address(this));
        open(from, tokenId);
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override(IERC1155Receiver) returns (bytes4) {}

    /// @notice Opens your Loot bag and mints you 8 ERC-1155 tokens for each item
    /// in that bag
    function open(address who, uint256 tokenId) private {
        // get the properties of the item, only given props if tokenId > 0
        Attributes.ItemIds memory props = propertiesOf[tokenId];
        // NB: We patched ERC1155 to expose `_balances` so
        // that we can manually mint to a user, and manually emit a `TransferBatch`
        // event. If that's unsafe, we can fallback to using _mint
        uint256[] memory ids = new uint256[](6);
        uint256[] memory amounts = new uint256[](6);
        ids[0] = itemId(
            props.creature,
            Components.creatureComponents,
            Attributes.CREATURE
        );
        ids[1] = itemId(props.flaw, Components.flawComponents, Attributes.FLAW);
        ids[2] = itemId(
            props.origin,
            Components.birthplaceComponents,
            Attributes.ORIGIN
        );
        ids[3] = itemId(
            props.bloodline,
            Components.bloodlineComponents,
            Attributes.BLOODLINE
        );
        ids[4] = itemId(props.eyes, Components.eyeComponents, Attributes.EYES);
        ids[5] = itemId(props.name, Components.nameComponents, Attributes.NAME);
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
    function reassemble(uint256 tokenId, uint256[6] calldata tokenIds)
        external
    {
        Attributes.ItemIds memory props = propertiesOf[tokenId];
        Attributes.ItemIds memory next = Attributes.ItemIds({
            creature: tokenIds[0],
            flaw: tokenIds[1],
            origin: tokenIds[2],
            bloodline: tokenIds[3],
            eyes: tokenIds[4],
            name: tokenIds[5]
        });
        // 1. burn the items, only burned if tokenId > 0
        burnItem(
            next.creature,
            Components.creatureComponents,
            Attributes.CREATURE
        );
        burnItem(next.flaw, Components.flawComponents, Attributes.FLAW);
        burnItem(
            next.origin,
            Components.birthplaceComponents,
            Attributes.ORIGIN
        );
        burnItem(
            next.bloodline,
            Components.bloodlineComponents,
            Attributes.BLOODLINE
        );
        burnItem(next.eyes, Components.eyeComponents, Attributes.EYES);
        burnItem(next.name, Components.nameComponents, Attributes.NAME);

        // 2. set the new propertiesOf
        propertiesOf[tokenId] = next;
        deposited[msg.sender][tokenId] = false;

        // 3. give back the bag
        safeTransferFrom(address(this), msg.sender, tokenId, 1, new bytes(0));
    }

    function itemId(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        uint256 itemType
    ) private view returns (uint256) {
        if (tokenId == 0) return 0;
        uint256[5] memory components = componentsFn(tokenId);
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
        if (tokenId == 0) return;
        uint256[5] memory components = componentsFn(tokenId);
        uint256 id = TokenId.toId(components, itemType);
        _burn(msg.sender, id, 1);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return tokenURI(tokenId);
    }
}
