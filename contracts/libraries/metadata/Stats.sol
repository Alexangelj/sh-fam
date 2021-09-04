//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./StatComponents.sol";
import { Base64, toString } from "../MetadataUtils.sol";

/// @title Helper contract for generating ERC-1155 token ids and descriptions for
/// the individual items inside a Loot bag.
/// @author Georgios Konstantopoulos
/// @dev Inherit from this contract and use it to generate metadata for your tokens
library Stats {
    uint256 internal constant STRENGTH = 0x6;
    uint256 internal constant DEXTERITY = 0x7;
    uint256 internal constant CONSTITUTION = 0x8;
    uint256 internal constant INTELLIGENCE = 0x9;
    uint256 internal constant WISDOM = 0x10;
    uint256 internal constant CHARISMA = 0x11;

    string internal constant itemStats =
        "Strength,Dexterity,Constitution,Intelligence,Wisdom,Charisma";

    struct ItemStats {
        uint256 strength;
        uint256 dexterity;
        uint256 constitution;
        uint256 intelligence;
        uint256 wisdom;
        uint256 charisma;
    }

    function getStats(ItemStats memory attr)
        internal
        pure
        returns (string memory)
    {
        string[11] memory stats;

        stats[0] = toString(attr.strength);
        stats[1] = '</text><text x="10" y="160" class="base">';
        stats[2] = toString(attr.dexterity);
        stats[3] = '</text><text x="10" y="180" class="base">';
        stats[4] = toString(attr.constitution);
        stats[5] = '</text><text x="10" y="200" class="base">';
        stats[6] = toString(attr.intelligence);
        stats[7] = '</text><text x="10" y="220" class="base">';
        stats[8] = toString(attr.wisdom);
        stats[9] = '</text><text x="10" y="240" class="base">';
        stats[10] = toString(attr.charisma);

        string memory output = string(
            abi.encodePacked(
                stats[0],
                stats[1],
                stats[2],
                stats[3],
                stats[4],
                stats[5],
                stats[6],
                stats[7],
                stats[8]
            )
        );

        output = string(abi.encodePacked(output, stats[9], stats[10]));
        return output;
    }

    function strStat(uint256 tokenId) internal pure returns (uint256) {
        return StatComponents.statComponent(tokenId, "STRENGTH");
    }

    function dexStat(uint256 tokenId) internal pure returns (uint256) {
        return StatComponents.statComponent(tokenId, "DEXTERITY");
    }

    function conStat(uint256 tokenId) internal pure returns (uint256) {
        return StatComponents.statComponent(tokenId, "CONSTITUTION");
    }

    function intStat(uint256 tokenId) internal pure returns (uint256) {
        return StatComponents.statComponent(tokenId, "INTELLIGENCE");
    }

    function wisStat(uint256 tokenId) internal pure returns (uint256) {
        return StatComponents.statComponent(tokenId, "WISDOM");
    }

    function chaStat(uint256 tokenId) internal pure returns (uint256) {
        return StatComponents.statComponent(tokenId, "CHARISMA");
    }

    function statsOf(uint256 tokenId) internal pure returns (ItemStats memory) {
        return
            ItemStats({
                strength: strStat(tokenId),
                dexterity: dexStat(tokenId),
                constitution: conStat(tokenId),
                intelligence: intStat(tokenId),
                wisdom: wisStat(tokenId),
                charisma: chaStat(tokenId)
            });
    }
}
