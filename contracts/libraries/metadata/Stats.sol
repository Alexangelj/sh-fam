//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../Random.sol";
import { Base64, toString, trait } from "../MetadataUtils.sol";

/// @notice Inspired by Andy
library Stats {
    // ===== Stats in SVG =====

    /// @param tokenId Shadowling tokenId; stats are static to each tokenId
    /// @return SVG string that renders the stats as text
    function render(uint256 tokenId) internal pure returns (string memory) {
        string[13] memory stats;

        stats[0] = '<text x="10" y="140" class="base">';
        stats[1] = strStat(tokenId);
        stats[2] = '</text><text x="10" y="160" class="base">';
        stats[3] = dexStat(tokenId);
        stats[4] = '</text><text x="10" y="180" class="base">';
        stats[5] = conStat(tokenId);
        stats[6] = '</text><text x="10" y="200" class="base">';
        stats[7] = intStat(tokenId);
        stats[8] = '</text><text x="10" y="220" class="base">';
        stats[9] = wisStat(tokenId);
        stats[10] = '</text><text x="10" y="240" class="base">';
        stats[11] = chaStat(tokenId);
        stats[12] = "</text>";

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

        output = string(
            abi.encodePacked(output, stats[9], stats[10], stats[11], stats[12])
        );
        return output;
    }

    // ===== Attributes =====

    /// @notice Returns the attributes of a `tokenId`
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function attributes(uint256 tokenId) internal pure returns (string memory) {
        string memory output;

        // should we also use components[0] which contains the item name?
        string memory res = trait("Str", strStat(tokenId));

        res = string(
            abi.encodePacked(res, ", ", trait("Dex", dexStat(tokenId)))
        );

        res = string(
            abi.encodePacked(res, ", ", trait("Con", conStat(tokenId)))
        );

        res = string(
            abi.encodePacked(res, ", ", trait("Int", intStat(tokenId)))
        );

        res = string(
            abi.encodePacked(res, ", ", trait("Wis", wisStat(tokenId)))
        );

        res = string(
            abi.encodePacked(res, ", ", trait("Cha", chaStat(tokenId)))
        );

        return res;
    }

    // ===== Individual Stats =====

    function strStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "Str");
    }

    function dexStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "Dex");
    }

    function conStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "Con");
    }

    function intStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "Int");
    }

    function wisStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "Wis");
    }

    function chaStat(uint256 tokenId) internal pure returns (string memory) {
        return pluckStat(tokenId, "Cha");
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
