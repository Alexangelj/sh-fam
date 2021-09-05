//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../Random.sol";
import { Base64, toString } from "../MetadataUtils.sol";

/// @notice Inspired by Andy
library Stats {
    // ===== Stats in SVG =====

    function render(uint256 tokenId) internal pure returns (string memory) {
        string[11] memory stats;

        stats[0] = strStat(tokenId);
        stats[1] = '</text><text x="10" y="160" class="base">';
        stats[2] = dexStat(tokenId);
        stats[3] = '</text><text x="10" y="180" class="base">';
        stats[4] = conStat(tokenId);
        stats[5] = '</text><text x="10" y="200" class="base">';
        stats[6] = intStat(tokenId);
        stats[7] = '</text><text x="10" y="220" class="base">';
        stats[8] = wisStat(tokenId);
        stats[9] = '</text><text x="10" y="240" class="base">';
        stats[10] = chaStat(tokenId);

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

    // ===== Individual Stats =====

    function strStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "STRENGTH");
    }

    function dexStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "DEXTERITY");
    }

    function conStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "CONSTITUTION");
    }

    function intStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "INTELLIGENCE");
    }

    function wisStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "WISDOM");
    }

    function chaStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "CHARISMA");
    }

    // ===== Roll Stat =====

    function pluckStat(uint256 tokenId, string memory keyPrefix)
        internal
        pure
        returns (string memory)
    {
        uint256 roll1 = Random.roll(
            string(abi.encodePacked(keyPrefix, toString(tokenId), "1"))
        );
        uint256 min = roll1;
        uint256 roll2 = Random.roll(
            string(abi.encodePacked(keyPrefix, toString(tokenId), "2"))
        );
        min = min > roll2 ? roll2 : min;
        uint256 roll3 = Random.roll(
            string(abi.encodePacked(keyPrefix, toString(tokenId), "3"))
        );
        min = min > roll3 ? roll3 : min;
        uint256 roll4 = Random.roll(
            string(abi.encodePacked(keyPrefix, toString(tokenId), "4"))
        );
        min = min > roll4 ? roll4 : min;

        // get 3 highest dice rolls
        uint256 stat = roll1 + roll2 + roll3 + roll4 - min;
        string memory output = string(
            abi.encodePacked(keyPrefix, ": ", toString(stat))
        );

        return output;
    }
}
