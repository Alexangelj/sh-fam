// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../MetadataUtils.sol";

library StatComponents {
    function roll(string memory input) internal pure returns (uint256) {
        return (uint256(keccak256(abi.encodePacked(input))) % 6) + 1;
    }

    function statComponent(uint256 tokenId, string memory keyPrefix)
        internal
        pure
        returns (uint256)
    {
        return pluckStat(tokenId, keyPrefix);
    }

    function pluckStat(uint256 tokenId, string memory keyPrefix)
        internal
        pure
        returns (uint256)
    {
        uint256 roll1 = roll(
            string(abi.encodePacked(keyPrefix, toString(tokenId), "1"))
        );
        uint256 min = roll1;
        uint256 roll2 = roll(
            string(abi.encodePacked(keyPrefix, toString(tokenId), "2"))
        );
        min = min > roll2 ? roll2 : min;
        uint256 roll3 = roll(
            string(abi.encodePacked(keyPrefix, toString(tokenId), "3"))
        );
        min = min > roll3 ? roll3 : min;
        uint256 roll4 = roll(
            string(abi.encodePacked(keyPrefix, toString(tokenId), "4"))
        );
        min = min > roll4 ? roll4 : min;

        // get 3 highest dice rolls
        uint256 stat = roll1 + roll2 + roll3 + roll4 - min;
        return stat;
        /* string memory output = string(
            abi.encodePacked(keyPrefix, ": ", toString(stat))
        );

        return output; */
    }
}
