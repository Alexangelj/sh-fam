//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Components.sol";
import "../TokenId.sol";
import { Base64, toString } from "../MetadataUtils.sol";

/// @title Helper contract for generating ERC-1155 token ids and descriptions for
/// the individual items inside a Shadowling.
/// @author Georgios Konstantopoulos
/// @dev Inherit from this contract and use it to generate metadata for your tokens
contract Attributes is Components {
    uint256 internal constant CREATURE = 0x0;
    uint256 internal constant FLAW = 0x1;
    uint256 internal constant ORIGIN = 0x2;
    uint256 internal constant BLOODLINE = 0x3;
    uint256 internal constant EYES = 0x4;
    uint256 internal constant NAME = 0x5;

    string[] internal itemTypes = [
        "Creature",
        "Flaw",
        "Origin",
        "Bloodline",
        "Eyes",
        "Name"
    ];

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
    function getImage(uint256 tokenId, string memory last)
        public
        view
        returns (string memory)
    {
        ItemProperties memory props = itemProperties(tokenId);

        string[13] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = props.creature;

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = props.flaw;

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = props.origin;

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = props.bloodline;

        parts[8] = '</text><text x="10" y="120" class="base">';

        parts[9] = props.eyes;

        parts[10] = '</text><text x="10" y="140" class="base">';

        parts[11] = props.name;

        parts[12] = '</text><text x="10" y="160" class="base">';

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
    function getAttributes(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        ItemIds memory attr = ids(tokenId);
        ItemProperties memory items = itemProperties(tokenId);

        string memory output;

        // should we also use components[0] which contains the item name?
        string memory res = string(
            abi.encodePacked("[", trait(itemTypes[0], items.creature))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(itemTypes[1], items.flaw))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(itemTypes[2], items.origin))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(itemTypes[3], items.bloodline))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(itemTypes[4], items.eyes))
        );

        res = string(
            abi.encodePacked(res, ", ", trait(itemTypes[5], items.name))
        );

        res = string(abi.encodePacked(res, "]"));

        output = string(abi.encodePacked('"attributes": ', res, "}"));
        return output;
    }

    /// @notice Returns the attributes associated with this item.
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function attributes(uint256 id) public view returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        // should we also use components[0] which contains the item name?
        string memory slot = itemTypes[itemType];
        string memory res = string(abi.encodePacked("[", trait("Slot", slot)));

        string memory item = baseItem(itemType, components[0]);
        res = string(abi.encodePacked(res, ", ", trait("Item", item)));

        if (components[1] > 0) {
            string memory data = suffixes[components[1] - 1];
            res = string(abi.encodePacked(res, ", ", trait("Suffix", data)));
        }

        if (components[2] > 0) {
            string memory data = namePrefixes[components[2] - 1];
            res = string(
                abi.encodePacked(res, ", ", trait("Name Prefix", data))
            );
        }

        if (components[3] > 0) {
            string memory data = nameSuffixes[components[3] - 1];
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
    function tokenProperty(uint256 id) public view returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        return componentsToString(components, itemType);
    }

    // Returns the "vanilla" item name w/o any prefix/suffixes or augmentations
    function baseItem(uint256 itemType, uint256 idx)
        public
        pure
        returns (string memory)
    {
        string memory arr;
        if (itemType == CREATURE) {
            arr = creatures;
        } else if (itemType == FLAW) {
            arr = flaws;
        } else if (itemType == ORIGIN) {
            arr = birthplaces;
        } else if (itemType == BLOODLINE) {
            arr = bloodlines;
        } else if (itemType == EYES) {
            arr = eyes;
        } else if (itemType == NAME) {
            arr = names;
        } else {
            revert("Too shadowy");
        }

        return getItemFromCSV(arr, idx);
    }

    // Creates the token description given its components and what type it is
    function componentsToString(uint256[5] memory components, uint256 itemType)
        public
        view
        returns (string memory)
    {
        // item type: what slot to get
        // components[0] the index in the array
        string memory item = baseItem(itemType, components[0]);

        // We need to do -1 because the 'no description' is not part of loot copmonents

        // add the suffix
        if (components[1] > 0) {
            item = string(
                abi.encodePacked(item, " ", suffixes[components[1] - 1])
            );
        }

        // add the name prefix / suffix
        if (components[2] > 0) {
            // prefix
            string memory namePrefixSuffix = string(
                abi.encodePacked("'", namePrefixes[components[2] - 1])
            );
            if (components[3] > 0) {
                namePrefixSuffix = string(
                    abi.encodePacked(
                        namePrefixSuffix,
                        " ",
                        nameSuffixes[components[3] - 1]
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
    function creatureId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(creatureComponents(tokenId), CREATURE);
    }

    function flawId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(flawComponents(tokenId), FLAW);
    }

    function birthplaceId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(birthplaceComponents(tokenId), ORIGIN);
    }

    function bloodlineId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(bloodlineComponents(tokenId), BLOODLINE);
    }

    function eyesId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(eyeComponents(tokenId), EYES);
    }

    function nameId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(nameComponents(tokenId), NAME);
    }

    // Given an erc721 bag, returns the erc1155 token ids of the items in the bag
    function ids(uint256 tokenId) public pure returns (ItemIds memory) {
        return
            ItemIds({
                creature: creatureId(tokenId),
                flaw: flawId(tokenId),
                origin: birthplaceId(tokenId),
                bloodline: bloodlineId(tokenId),
                eyes: eyesId(tokenId),
                name: nameId(tokenId)
            });
    }

    function idsMany(uint256[] memory tokenIds)
        public
        pure
        returns (ItemIds[] memory)
    {
        ItemIds[] memory itemids = new ItemIds[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            itemids[i] = ids(tokenIds[i]);
        }

        return itemids;
    }

    // Given an ERC721 bag, returns the names of the items in the bag
    function itemProperties(uint256 tokenId)
        public
        view
        returns (ItemProperties memory)
    {
        ItemIds memory items = ids(tokenId);
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

    function namesMany(uint256[] memory tokenNames)
        public
        view
        returns (ItemProperties[] memory)
    {
        ItemProperties[] memory allNames = new ItemProperties[](
            tokenNames.length
        );
        for (uint256 i = 0; i < tokenNames.length; i++) {
            allNames[i] = itemProperties(tokenNames[i]);
        }

        return allNames;
    }
}
