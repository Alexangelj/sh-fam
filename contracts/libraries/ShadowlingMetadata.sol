//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Components.sol";
import "./TokenId.sol";
import { Base64, toString } from "./MetadataUtils.sol";

/// @title Helper contract for generating ERC-1155 token ids and descriptions for
/// the individual items inside a Loot bag.
/// @author Georgios Konstantopoulos
/// @dev Inherit from this contract and use it to generate metadata for your tokens
contract ShadowlingMetadata is Components {
    uint256 internal constant CREATURE = 0x0;
    uint256 internal constant FLAW = 0x1;
    uint256 internal constant BIRTHPLACE = 0x2;
    uint256 internal constant BLOODLINE = 0x3;
    uint256 internal constant EYES = 0x4;
    uint256 internal constant NAME = 0x5;
    uint256 internal constant STRENGTH = 0x6;
    uint256 internal constant DEXTERITY = 0x7;
    uint256 internal constant CONSTITUTION = 0x8;
    uint256 internal constant INTELLIGENCE = 0x9;
    uint256 internal constant WISDOM = 0x10;
    uint256 internal constant CHARISMA = 0x11;

    string[] internal itemTypes = [
        "Creature",
        "Flaw",
        "Birthplace",
        "Bloodline",
        "Eyes",
        "Name",
        "Strength",
        "Dexterity",
        "Constitution",
        "Intelligence",
        "Wisdom",
        "Charisma"
    ];

    struct ItemIds {
        uint256 creature;
        uint256 flaw;
        uint256 birthplace;
        uint256 bloodline;
        uint256 eyes;
        uint256 name;
        uint256 strength;
        uint256 dexterity;
        uint256 constitution;
        uint256 intelligence;
        uint256 wisdom;
        uint256 charisma;
    }
    struct ItemNames {
        string creature;
        string flaw;
        string birthplace;
        string bloodline;
        string eyes;
        string name;
        string strength;
        string dexterity;
        string constitution;
        string intelligence;
        string wisdom;
        string charisma;
    }

    function name() external pure returns (string memory) {
        return "Shadowling";
    }

    function symbol() external pure returns (string memory) {
        return "SHDW";
    }

    /// @dev Opensea contract metadata: https://docs.opensea.io/docs/contract-level-metadata
    function contractURI() external pure returns (string memory) {
        string
            memory json = '{"name": "Shadowling", "description": "Shadowlings follow you in your journey across chainspace, the shadowchain, and beyond..."}';
        string memory encodedJson = Base64.encode(bytes(json));
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", encodedJson)
        );

        return output;
    }

    /// @notice Returns an SVG for the provided token id
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        string[4] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = tokenName(tokenId);

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2], parts[3])
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        tokenName(tokenId),
                        '", ',
                        '"description" : ',
                        '"Shadowlings follow you in your journey across chainspace, the shadowchain, and beyond...", ',
                        '"image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '", '
                        '"attributes": ',
                        attributes(tokenId),
                        "}"
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    /// @notice Returns the attributes associated with this item.
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function attributes(uint256 id) public view returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        // should we also use components[0] which contains the item name?
        string memory slot = itemTypes[itemType];
        string memory res = string(abi.encodePacked("[", trait("Slot", slot)));

        string memory item = itemName(itemType, components[0]);
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
    function tokenName(uint256 id) public view returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        return componentsToString(components, itemType);
    }

    // Returns the "vanilla" item name w/o any prefix/suffixes or augmentations
    function itemName(uint256 itemType, uint256 idx)
        public
        view
        returns (string memory)
    {
        string memory arr;
        if (itemType == CREATURE) {
            arr = creatures;
        } else if (itemType == FLAW) {
            arr = flaws;
        } else if (itemType == BIRTHPLACE) {
            arr = birthplaces;
        } else if (itemType == BLOODLINE) {
            arr = bloodlines;
        } else if (itemType == EYES) {
            arr = eyes;
        } else if (itemType == NAME) {
            arr = names;
        } else if (itemType == STRENGTH) {
            arr = stats;
        } else if (itemType == DEXTERITY) {
            arr = stats;
        } else if (itemType == CONSTITUTION) {
            arr = stats;
        } else if (itemType == INTELLIGENCE) {
            arr = stats;
        } else if (itemType == WISDOM) {
            arr = stats;
        } else if (itemType == CHARISMA) {
            arr = stats;
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
        string memory item = itemName(itemType, components[0]);

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
        return TokenId.toId(birthplaceComponents(tokenId), BIRTHPLACE);
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

    function strengthId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(statComponent(tokenId, "STRENGTH"), STRENGTH);
    }

    function dexterityId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(statComponent(tokenId, "DEXTERITY"), DEXTERITY);
    }

    function constitutionId(uint256 tokenId) public pure returns (uint256) {
        return
            TokenId.toId(statComponent(tokenId, "CONSTITUTION"), CONSTITUTION);
    }

    function intelligenceId(uint256 tokenId) public pure returns (uint256) {
        return
            TokenId.toId(statComponent(tokenId, "INTELLIGENCE"), INTELLIGENCE);
    }

    function wisdomId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(statComponent(tokenId, "WISDOM"), WISDOM);
    }

    function charismaId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(statComponent(tokenId, "CHARISMA"), CHARISMA);
    }

    // Given an erc721 bag, returns the erc1155 token ids of the items in the bag
    function ids(uint256 tokenId) public pure returns (ItemIds memory) {
        return
            ItemIds({
                creature: creatureId(tokenId),
                flaw: flawId(tokenId),
                birthplace: birthplaceId(tokenId),
                bloodline: bloodlineId(tokenId),
                eyes: eyesId(tokenId),
                name: nameId(tokenId),
                strength: strengthId(tokenId),
                dexterity: dexterityId(tokenId),
                constitution: constitutionId(tokenId),
                intelligence: intelligenceId(tokenId),
                wisdom: wisdomId(tokenId),
                charisma: charismaId(tokenId)
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
    function itemNames(uint256 tokenId) public view returns (ItemNames memory) {
        ItemIds memory items = ids(tokenId);
        return
            ItemNames({
                creature: tokenName(items.creature),
                flaw: tokenName(items.flaw),
                birthplace: tokenName(items.birthplace),
                bloodline: tokenName(items.bloodline),
                eyes: tokenName(items.eyes),
                name: tokenName(items.name),
                strength: tokenName(items.strength),
                dexterity: tokenName(items.dexterity),
                constitution: tokenName(items.constitution),
                intelligence: tokenName(items.intelligence),
                wisdom: tokenName(items.wisdom),
                charisma: tokenName(items.charisma)
            });
    }

    function namesMany(uint256[] memory tokenNames)
        public
        view
        returns (ItemNames[] memory)
    {
        ItemNames[] memory allNames = new ItemNames[](tokenNames.length);
        for (uint256 i = 0; i < tokenNames.length; i++) {
            allNames[i] = itemNames(tokenNames[i]);
        }

        return allNames;
    }
}
