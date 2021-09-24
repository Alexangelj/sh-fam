// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

/// @notice Is this really random?
library Random {
    /// @notice Uses a commit-reveal scheme to get randomness from miners and users, separately
    /// @param schemeHash Hash of the blockhash at the commit block.number, and their reveal hash
    /// @return pseudorandom uint value to use as randomness
    function random(string memory schemeHash) internal view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encode(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.number,
                            tx.origin,
                            msg.sender,
                            gasleft(),
                            schemeHash,
                            blockhash(block.number),
                            blockhash(block.number - 69)
                        )
                    )
                )
            )
        );
        return seed;
    }

    /// @param input Hash of roll number, tokenId
    /// @return pseudorandom number between 1 and 6
    function roll(string memory input) internal pure returns (uint256) {
        return (uint256(keccak256(abi.encodePacked(input))) % 6) + 1;
    }
}
