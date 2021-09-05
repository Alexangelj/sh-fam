pragma solidity 0.8.6;

/// @notice Formats, parses, and generates the DNA of our shadowy friends
/// @dev    Reads from the `block` in `getSeed`
library Random {
    uint256 private constant A = 0;
    uint256 private constant G = 1;
    uint256 private constant D = 2;
    uint256 private constant T = 3;

    /// @notice Builds a sequence from a seed
    function sequence(uint256 seed) internal returns (string memory) {
        uint256[9] memory values;

        values[0] = seed % 100 > 50 ? G : A;
        values[1] = seed % 500 > 195 ? G : D;
        values[2] = seed % 2000 > 1667 ? D : A;
        values[3] = (values[0] == G) && (values[0] == G) ? A : G;
        values[4] = (values[1] == A) ? T : G;
        values[5] = (values[1] == T) && seed % 2000 > 1667 ? G : A;
        values[6] = (values[0] == G) && (values[0] == A) ? A : G;
        values[7] = (values[2] == G) ? T : G;
        values[8] = (values[3] == G) ? A : G;

        string memory sequence = string(
            abi.encodePacked(
                values[0],
                values[1],
                values[2],
                values[3],
                values[4],
                values[5],
                values[6],
                values[7],
                values[8]
            )
        );
        return sequence;
    }

    function getSeed(uint256 tokenId) internal view returns (uint256) {
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
                            tokenId,
                            blockhash(block.number),
                            blockhash(block.number - 69)
                        )
                    )
                )
            )
        );
        return seed;
    }

    function roll(string memory input) internal pure returns (uint256) {
        return (random(input) % 6) + 1;
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function slot(
        string memory prefix,
        uint256 seed,
        uint256 mod
    ) internal pure returns (uint256) {
        return random(string(abi.encodePacked(prefix, seed))) % mod;
    }

    function getBloodSeed(uint256 tokenId, string memory imageHash)
        internal
        view
        returns (uint256)
    {
        uint256 seed = uint256(
            keccak256(
                abi.encode(
                    keccak256(abi.encodePacked(getSeed(tokenId), imageHash))
                )
            )
        );
        return seed;
    }
}
