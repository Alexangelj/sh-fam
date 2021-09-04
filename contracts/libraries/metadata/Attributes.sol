//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Components.sol";
import "../TokenId.sol";
import { Base64, toString } from "../MetadataUtils.sol";

/// @title Helper contract for generating ERC-1155 token ids and descriptions for
/// the individual items inside a Shadowling.
/// @author Georgios Konstantopoulos
/// @dev Inherit from this contract and use it to generate metadata for your tokens
library Attributes {
    using Components for uint256;
    uint256 internal constant CREATURE = 0x0;
    uint256 internal constant FLAW = 0x1;
    uint256 internal constant ORIGIN = 0x2;
    uint256 internal constant BLOODLINE = 0x3;
    uint256 internal constant EYES = 0x4;
    uint256 internal constant NAME = 0x5;

    string internal constant itemTypes =
        "Creature,Flaw,Origin,Bloodline,Eyes,Name";

    struct ItemIds {
        uint256 creature;
        uint256 flaw;
        uint256 origin;
        uint256 bloodline;
        uint256 eyes;
        uint256 name;
    }

    struct ItemProperties {
        string creature;
        string flaw;
        string origin;
        string bloodline;
        string eyes;
        string name;
    }

    /// @notice Returns an SVG for the provided token id
    function getImage(ItemProperties memory item, string memory last)
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

        parts[9] = item.eyes;

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

    /// @notice Returns the attributes properties of a `tokenId`
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function attributes(ItemProperties memory items)
        internal
        pure
        returns (string memory)
    {
        string memory output;

        // should we also use components[0] which contains the item name?
        string memory res = string(
            abi.encodePacked("[", trait(getItemTypes(0), items.creature))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(getItemTypes(1), items.flaw))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(getItemTypes(2), items.origin))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(getItemTypes(3), items.bloodline))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(getItemTypes(4), items.eyes))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(getItemTypes(5), items.name))
        );

        res = string(abi.encodePacked(res, "]"));

        output = string(abi.encodePacked('"attributes": ', res, "}"));
        return output;
    }

    /// @notice Returns the attributes associated with this item.
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function _attributes(uint256 id) internal pure returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        // should we also use components[0] which contains the item name?
        string memory slot = getItemTypes(itemType);
        string memory res = string(abi.encodePacked("[", trait("Slot", slot)));

        string memory item = baseItem(itemType, components[0]);
        res = string(abi.encodePacked(res, ", ", trait("Item", item)));

        if (components[1] > 0) {
            string memory data = Components.getSuffixes(components[1] - 1);
            res = string(abi.encodePacked(res, ", ", trait("Suffix", data)));
        }

        if (components[2] > 0) {
            string memory data = Components.getNamePrefixes(components[2] - 1);
            res = string(
                abi.encodePacked(res, ", ", trait("Name Prefix", data))
            );
        }

        if (components[3] > 0) {
            string memory data = Components.getNameSuffixes(components[3] - 1);
            res = string(
                abi.encodePacked(res, ", ", trait("Name Suffix", data))
            );
        }

        if (components[4] > 0) {
            res = string(
                abi.encodePacked(res, ", ", trait("Augmentation", "Yes"))
            );
        }

        res = string(abi.encodePacked(res, "]"));

        return res;
    }

    // Helper for encoding as json w/ trait_type / value from opensea
    function trait(string memory _traitType, string memory _value)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "{",
                    '"trait_type": "',
                    _traitType,
                    '", ',
                    '"value": "',
                    _value,
                    '"',
                    "}"
                )
            );
    }

    // @notice Given an ERC1155 token id, it returns its name by decoding and parsing
    // the id
    function tokenProperty(uint256 id) internal pure returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        return componentsToString(components, itemType);
    }

    // Returns the "vanilla" item name w/o any prefix/suffixes or augmentations
    function baseItem(uint256 itemType, uint256 idx)
        internal
        pure
        returns (string memory)
    {
        string memory arr;
        if (itemType == CREATURE) {
            arr = Components.creatures;
        } else if (itemType == FLAW) {
            arr = Components.flaws;
        } else if (itemType == ORIGIN) {
            arr = Components.origins;
        } else if (itemType == BLOODLINE) {
            arr = Components.bloodlines;
        } else if (itemType == EYES) {
            arr = Components.eyes;
        } else if (itemType == NAME) {
            arr = Components.names;
        } else {
            revert("Unexpected property");
        }

        return Components.getItemFromCSV(arr, idx);
    }

    // Creates the token description given its components and what type it is
    function componentsToString(uint256[5] memory components, uint256 itemType)
        internal
        pure
        returns (string memory)
    {
        // item type: what slot to get
        // components[0] the index in the array
        string memory item = baseItem(itemType, components[0]);

        // We need to do -1 because the 'no description' is not part of loot copmonents

        // add the suffix
        if (components[1] > 0) {
            item = string(
                abi.encodePacked(
                    item,
                    " ",
                    Components.getItemFromCSV(
                        Components.suffixes,
                        components[1] - 1
                    )
                )
            );
        }

        // add the name prefix / suffix
        if (components[2] > 0) {
            // prefix
            string memory namePrefixSuffix = string(
                abi.encodePacked(
                    "'",
                    Components.getNamePrefixes(components[2] - 1)
                )
            );
            if (components[3] > 0) {
                namePrefixSuffix = string(
                    abi.encodePacked(
                        namePrefixSuffix,
                        " ",
                        Components.getNameSuffixes(components[3] - 1)
                    )
                );
            }

            namePrefixSuffix = string(abi.encodePacked(namePrefixSuffix, "' "));

            item = string(abi.encodePacked(namePrefixSuffix, item));
        }

        // add the augmentation
        if (components[4] > 0) {
            item = string(abi.encodePacked(item, " +1"));
        }

        return item;
    }

    // View helpers for getting the item ID that corresponds to a bag's items
    function creatureId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.creatureComponents(), CREATURE);
    }

    function flawId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.flawComponents(), FLAW);
    }

    function originId(uint256 tokenId, bool shadowChain)
        internal
        pure
        returns (uint256)
    {
        return TokenId.toId(tokenId.originComponents(shadowChain), ORIGIN);
    }

    function bloodlineId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.bloodlineComponents(), BLOODLINE);
    }

    function eyesId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.eyeComponents(), EYES);
    }

    function nameId(uint256 tokenId) internal pure returns (uint256) {
        return TokenId.toId(tokenId.nameComponents(), NAME);
    }

    // Given an ERC721 bag, returns the names of the items in the bag
    function props(ItemIds memory items)
        internal
        pure
        returns (ItemProperties memory)
    {
        return
            ItemProperties({
                creature: tokenProperty(items.creature),
                flaw: tokenProperty(items.flaw),
                origin: tokenProperty(items.origin),
                bloodline: tokenProperty(items.bloodline),
                eyes: tokenProperty(items.eyes),
                name: tokenProperty(items.name)
            });
    }

    function getItemTypes(uint256 index) internal pure returns (string memory) {
        return Components.getItemFromCSV(itemTypes, index);
    }
}
