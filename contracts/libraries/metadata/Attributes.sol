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
        string[13] memory parts;
        parts[0] = '<text x="10" y="20" class="base">';

        parts[1] = item.creature;

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = item.item;

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = item.origin;

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = item.bloodline;

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = item.perk;

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = item.name;

        parts[12] = "</text>";

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
            abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12])
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
        string memory res = trait(Scanner.getItemType(0), items.creature);

        res = string(
            abi.encodePacked(
                res,
                ", ",
                trait(Scanner.getItemType(1), items.item)
            )
        );

        res = string(
            abi.encodePacked(
                res,
                ", ",
                trait(Scanner.getItemType(2), items.origin)
            )
        );

        res = string(
            abi.encodePacked(
                res,
                ", ",
                trait(Scanner.getItemType(3), items.bloodline)
            )
        );

        res = string(
            abi.encodePacked(
                res,
                ", ",
                trait(Scanner.getItemType(4), items.perk)
            )
        );

        res = string(
            abi.encodePacked(
                res,
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
