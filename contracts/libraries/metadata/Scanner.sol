//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Components.sol";
import "../TokenId.sol";
import { Base64, toString, trait } from "../MetadataUtils.sol";

/// @title Scans attributes of each component and parses them into traits
/// Flow:
/// 1. encodedId -> components[5] using TokenId.fromId()
/// 2. components[5] -> individual traits of each component
library Scanner {
    using Components for uint256;

    // ===== Attribute Slots =====

    uint256 internal constant CREATURE = 0x0;
    uint256 internal constant ITEM = 0x1;
    uint256 internal constant ORIGIN = 0x2;
    uint256 internal constant BLOODLINE = 0x3;
    uint256 internal constant PERK = 0x4;
    uint256 internal constant NAME = 0x5;

    string internal constant itemTypes =
        "Creature,Item,Origin,Bloodline,Perk,Name";

    // ====== Item Slot Fetcher =====

    /// @return Item at `index` of `itemTypes` csv, i.e. index = 0, item = Creature
    function getItemType(uint256 index) internal pure returns (string memory) {
        return Components.getItemFromCSV(itemTypes, index);
    }

    // ===== Attributes of Item of NFT =====

    /// @notice Parses encodedIds into an array of components, which is stringified
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    /// @return Attributes of each component of the item string
    function attributes(uint256 id) internal pure returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        // should we also use components[0] which contains the item name?
        string memory slot = getItemType(itemType);
        string memory res = string(abi.encodePacked("[", trait("Slot", slot)));

        string memory item = base(itemType, components[0]);
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

    // ===== Gets the Attribute Slot =====

    // Returns the "vanilla" item name w/o any prefix/suffixes or augmentations
    function base(uint256 itemType, uint256 idx)
        internal
        pure
        returns (string memory)
    {
        string memory arr;
        if (itemType == CREATURE) {
            arr = Components.creatures;
        } else if (itemType == ITEM) {
            arr = Components.items;
        } else if (itemType == ORIGIN) {
            arr = Components.origins;
        } else if (itemType == BLOODLINE) {
            arr = Components.bloodlines;
        } else if (itemType == PERK) {
            arr = Components.perks;
        } else if (itemType == NAME) {
            arr = Components.names;
        } else {
            revert("Unexpected property");
        }

        return Components.getItemFromCSV(arr, idx);
    }

    // ===== Components -> Items as strings =====

    /// @notice Creates the token description given its components and what type it is
    function componentsToString(uint256[5] memory components, uint256 itemType)
        internal
        pure
        returns (string memory)
    {
        // item type: what slot to get
        // components[0] the index in the array
        string memory item = base(itemType, components[0]);

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
            item = string(abi.encodePacked(item, " +SE"));
        }

        return item;
    }
}
