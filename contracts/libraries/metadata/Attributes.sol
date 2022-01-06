// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Components.sol";
import "./Scanner.sol";
import "../TokenId.sol";
import { Base64, toString, trait } from "../MetadataUtils.sol";

/// @title Helper contract for generating ERC-1155 token ids.
/// @author Georgios Konstantopoulos
/// @dev Inherit from this contract and use it to generate metadata for your tokens
/// Flow:
/// 1. tokenId from top level NFT
/// 2. tokenId -> encodedId per attribute
/// 3. Scanner(encodedId) -> individual attributes of each item
/// 4. return all attributes of NFT
library Attributes {
    using Components for uint256;

    // ====== Attribute Storage =====

    /// @notice Item Attribute Identifiers
    struct ItemIds {
        uint256 creature;
        uint256 item;
        uint256 origin;
        uint256 bloodline;
        uint256 perk;
        uint256 name;
    }

    /// @notice Item Attributes Raw
    struct ItemStrings {
        string creature;
        string item;
        string origin;
        string bloodline;
        string perk;
        string name;
    }

    // ===== Encoding Ids =====

    /// @notice Given an item id, returns its name by decoding and parsing the id
    function encodedIdToString(uint256 id)
        internal
        pure
        returns (string memory)
    {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        return Scanner.componentsToString(components, itemType);
    }

    // ===== SVG Rendering =====

    /// @notice Returns an SVG for the provided token id
    /// @param  item Attributes of an item as strings
    /// @return SVG string that renders the Attributes as text
    function render(ItemStrings memory item)
        internal
        pure
        returns (string memory)
    {
        string[12] memory parts;

        parts[0] = item.creature;

        parts[1] = ' \u06DE ';

        parts[2] = item.item;

        parts[3] = ' \u06DE ';

        parts[4] = item.origin;

        parts[5] = ' \u06DE ';

        parts[6] = item.bloodline;

        parts[7] = ' \u06DE ';

        parts[8] = item.perk;

        parts[9] = ' \u06DE ';

        parts[10] = item.name;

        parts[11] = " \u06DE ";

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );

        output = string(
            abi.encodePacked(
                output,
                parts[9],
                parts[10],
                parts[11]
            )
        );

        output = string(
            abi.encodePacked(
                '<path id="text-path" fill="none" d="M250 250 m-180,0 a 180 180 0 1 1 360 0 a 180,180 0 1,1 -360,0"/><text text-rendering="optimizeSpeed" class="base"><textPath startOffset="0%" textLength="1120" method="stretch" href="#text-path">',
                output,
                '<animate additive="sum" attributeName="startOffset" from="100%" to="0%" begin="0s" dur="45s" repeatCount="indefinite"/></textPath><textPath startOffset="-100%" textLength="1120" method="stretch" href="#text-path">',
                output,
                '<animate additive="sum" attributeName="startOffset" from="100%" to="0%" begin="0s" dur="45s" repeatCount="indefinite" /></textPath></text>'
            )
        );
        return output;
    }

    // ====== Attributes of NFT =====

    /// @notice Returns the attributes of a `tokenId`
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function attributes(ItemStrings memory items)
        internal
        pure
        returns (string memory)
    {
        string memory res = string(
            abi.encodePacked(
                trait(Scanner.getItemType(0), items.creature),
                ", ",
                trait(Scanner.getItemType(1), items.item),
                ", ",
                trait(Scanner.getItemType(2), items.origin),
                ", ",
                trait(Scanner.getItemType(3), items.bloodline),
                ", ",
                trait(Scanner.getItemType(4), items.perk),
                ", ",
                trait(Scanner.getItemType(5), items.name)
            )
        );
        return res;
    }

    // ===== Encode Individual Item Ids =====

    // View helpers for getting the item ID that corresponds to a bag's items
    function creatureId(uint256 seed) internal pure returns (uint256) {
        return TokenId.toId(seed.creatureComponents(), Scanner.CREATURE);
    }

    function itemId(uint256 seed) internal pure returns (uint256) {
        return TokenId.toId(seed.itemComponents(), Scanner.ITEM);
    }

    function originId(uint256 seed, bool shadowChain)
        internal
        pure
        returns (uint256)
    {
        return TokenId.toId(seed.originComponents(shadowChain), Scanner.ORIGIN);
    }

    function bloodlineId(uint256 seed) internal pure returns (uint256) {
        return TokenId.toId(seed.bloodlineComponents(), Scanner.BLOODLINE);
    }

    function perkId(uint256 seed) internal pure returns (uint256) {
        return TokenId.toId(seed.perkComponents(), Scanner.PERK);
    }

    function nameId(uint256 seed) internal pure returns (uint256) {
        return TokenId.toId(seed.nameComponents(), Scanner.NAME);
    }

    // ===== Utility =====

    /// @notice Uses a seed to get 6 items, each with their own encoded Ids
    /// @param seed Pseudorandom number hopefully generated from a commit-reveal scheme
    /// @return Item attributes as ids
    function ids(uint256 seed) internal pure returns (ItemIds memory) {
        return
            ItemIds({
                creature: Attributes.creatureId(seed),
                item: Attributes.itemId(seed),
                origin: Attributes.originId(seed, false),
                bloodline: Attributes.bloodlineId(seed),
                perk: Attributes.perkId(seed),
                name: Attributes.nameId(seed)
            });
    }

    /// @notice Converts an Item's attribute identifiers into strings
    /// @return Item attributes as strings
    function props(ItemIds memory items)
        internal
        pure
        returns (ItemStrings memory)
    {
        return
            ItemStrings({
                creature: encodedIdToString(items.creature),
                item: encodedIdToString(items.item),
                origin: encodedIdToString(items.origin),
                bloodline: encodedIdToString(items.bloodline),
                perk: encodedIdToString(items.perk),
                name: encodedIdToString(items.name)
            });
    }
}
