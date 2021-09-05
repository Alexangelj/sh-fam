pragma solidity 0.8.6;

import "../strings.sol";

/// @notice Formats, parses, and generates the DNA of our shadowy friends
library DNA {
    using strings for string;
    using strings for strings.slice;

    string internal constant A = "A";
    string internal constant G = "G";
    string internal constant D = "D";
    string internal constant T = "T";
    uint256 internal constant fragmentLength = 3;
    uint256 internal constant sequenceLength = 3 * 3;

    struct Fragment {
        string c0;
        string c1;
        string c2;
    }
    struct Sequence {
        Fragment f0;
        Fragment f1;
        Fragment f2;
        string seq;
    }

    /// @notice Builds a sequence from a seed
    function sequence(uint256 seed) internal returns (Sequence memory) {
        /// using the seed, build the first fragment
        string memory f0;
        Fragment memory frag0 = Fragment({
            c0: seed % 100 > 50 ? G : A,
            c1: seed % 500 > 195 ? G : T,
            c2: seed % 2000 > 1667 ? T : A
        });
        f0 = packFragment(frag0);

        /// using the first fragment, build the second fragment
        string memory f1;
        /// check the first component and of the first fragment
        Fragment memory frag1 = frag0; /* Fragment({
            c0: compare(frag0.c0, G) && compare(frag0.c0, G) ? A : G,
            c1: compare(frag0.c2, A) ? T : G,
            c2: compare(frag0.c1, T) && seed % 2000 > 1667 ? G : A
        }); */

        f1 = packFragment(frag1);

        /// using the second fragment, build the third fragment
        string memory f2;
        /// check the first component and of the first fragment
        Fragment memory frag2 = frag1; /* Fragment({
            c0: compare(frag0.c0, G) && compare(frag0.c0, A) ? A : G,
            c1: compare(frag0.c2, G) ? T : G,
            c2: compare(frag0.c1, A) && seed % 2000 < 1667 ? T : A
        }); */

        f2 = packFragment(frag2);

        // bundle the sequence
        Sequence memory seq = Sequence({
            f0: frag0,
            f1: frag1,
            f2: frag2,
            seq: string(abi.encodePacked(f0, f1, f2))
        });

        return seq;
    }

    function compare(string memory a, string memory b)
        public
        view
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function packFragment(Fragment memory frag)
        internal
        returns (string memory)
    {
        return string(abi.encodePacked(frag.c0, frag.c1, frag.c2));
    }

    function getSeed(uint256 tokenId) internal view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encode(
                    keccak256(
                        abi.encodePacked(
                            msg.sender,
                            tx.origin,
                            gasleft(),
                            tokenId,
                            block.timestamp,
                            block.number,
                            blockhash(block.number),
                            blockhash(block.number - 100)
                        )
                    )
                )
            )
        );
        return seed;
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
