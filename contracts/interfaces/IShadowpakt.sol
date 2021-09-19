// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IShadowpakt {
    /// @notice Thrown if attempting to reveal in same block or 250 blocks too late
    error BlockError();
    /// @notice Thrown if a commit has already been revealed
    error CommitError();
    /// @notice Thrown if a hashed revealHash does not match the commit
    error HashError();
    /// @notice Thrown on revealing a committed hash
    error RevealedError();

    /// @notice Emitted on revealing a committed hash key
    event RevealHash(address indexed from, bytes32 revealHash, uint256 random);

    /// @notice Storage for commits
    function commits(address user)
        external
        view
        returns (
            bytes32 commit,
            uint64 blockNumber,
            bool revealed
        );

    /// @notice Commits a hashed key to be revealed later
    /// @dev    Miner cannot guess key, user cannot get block hash (thats the idea)
    function commitKey(bytes32 hashedKey) external;

    /// @notice Reveals the key by submitting `revealHash`
    /// @dev    Uses block hash and reveal hash for randomness
    function revealKey(bytes32 revealHash) external returns (uint256);

    // ===== View =====

    /// @notice Keccak256 hash of this contract's address and `keyHash`
    function getHash(bytes32 keyHash) external view returns (bytes32);
}
