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
        uint256 flaw;
        uint256 origin;
        uint256 bloodline;
        uint256 ability;
        uint256 name;
    }

    /// @notice Item Attributes Raw
    struct ItemStrings {
        string creature;
        string flaw;
        string origin;
        string bloodline;
        string ability;
        string name;
    }

    // ===== Encoding Ids =====

    /// @notice Given an item id, returns its name by decoding and parsing the id
    function encodedIdToString(uint256 itemId)
        internal
        pure
        returns (string memory)
    {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(
            itemId
        );
        return Scanner.componentsToString(components, itemType);
    }

    // ===== SVG Rendering =====

    /// @notice Returns an SVG for the provided token id
    /// @param  item Attributes of an item as strings
    /// @param  last Additional data to append to SVG string
    /// @return SVG string
    function render(ItemStrings memory item, string memory last)
        internal
        pure
        returns (string memory)
    {
        string[13] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = item.creature;

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = item.flaw;

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = item.origin;

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = item.bloodline;

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = item.ability;

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = item.name;

        parts[12] = '</text><text x="10" y="140" class="base">';

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

        output = string(abi.encodePacked(output, last, "</text></svg>"));

        output = string(
            abi.encodePacked(
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(output)),
                '", '
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
        string memory output;

        // should we also use components[0] which contains the item name?
        string memory res = string(
            abi.encodePacked("[", trait(Scanner.getItemType(0), items.creature))
        );

        res = string(
            abi.encodePacked(
                res,
                ", ",
                trait(Scanner.getItemType(1), items.flaw)
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
                trait(Scanner.getItemType(4), items.ability)
            )
        );

        res = string(
            abi.encodePacked(
                res,
                ", ",
                trait(Scanner.getItemType(5), items.name)
            )
        );

        res = string(abi.encodePacked(res, "]"));

        output = string(abi.encodePacked('"attributes": ', res, "}"));
        return output;
    }

    // ===== Encode Individual Item Ids =====

    // View helpers for getting the item ID that corresponds to a bag's items
    function creatureId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.creatureComponents(), Scanner.CREATURE);
    }

    function flawId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.flawComponents(), Scanner.FLAW);
    }

    function originId(uint256 tokenId, bool shadowChain)
        internal
        pure
        returns (uint256)
    {
        return
            TokenId.toId(tokenId.originComponents(shadowChain), Scanner.ORIGIN);
    }

    function bloodlineId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.bloodlineComponents(), Scanner.BLOODLINE);
    }

    function abilityId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.abilityComponents(), Scanner.ABILITY);
    }

    function nameId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.nameComponents(), Scanner.NAME);
    }

    // ===== Utility =====

    /// @notice Converts a `tokenId` into an Item with ids
    /// @return Item attributes as ids
    function ids(uint256 tokenId) internal pure returns (ItemIds memory) {
        return
            ItemIds({
                creature: Attributes.creatureId(tokenId),
                flaw: Attributes.flawId(tokenId),
                origin: Attributes.originId(tokenId, false),
                bloodline: Attributes.bloodlineId(tokenId),
                ability: Attributes.abilityId(tokenId),
                name: Attributes.nameId(tokenId)
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
                flaw: encodedIdToString(items.flaw),
                origin: encodedIdToString(items.origin),
                bloodline: encodedIdToString(items.bloodline),
                ability: encodedIdToString(items.ability),
                name: encodedIdToString(items.name)
            });
    }
}
