// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./interfaces/IShadowpakt.sol";

contract Shadowpakt is IShadowpakt {
    // @dev Storage for commits
    struct Commit {
        bytes32 commit;
        uint64 blockNumber;
        bool revealed;
    }

    /// @inheritdoc IShadowpakt
    mapping(address => Commit) public override commits;

    /// @inheritdoc IShadowpakt
    function commitKey(bytes32 hashedKey) public override {
        commits[msg.sender] = Commit({
            commit: hashedKey,
            blockNumber: uint64(block.number),
            revealed: false
        });
    }

    /// @inheritdoc IShadowpakt
    function revealKey(bytes32 revealHash) public override returns (uint256) {
        Commit storage commit = commits[msg.sender];
        if (commit.revealed) revert RevealedError();
        commit.revealed = true;
        if (getHash(revealHash) != commit.commit) revert HashError();
        if (uint64(block.number) <= commit.blockNumber) revert BlockError();
        if (uint64(block.number) > commit.blockNumber + 250)
            revert BlockError();
        bytes32 blockHash = blockhash(commit.blockNumber);
        uint256 random = uint256(
            keccak256(abi.encodePacked(blockHash, revealHash))
        );

        emit RevealHash(msg.sender, revealHash, random);
        return random;
    }

    // ===== View =====

    /// @inheritdoc IShadowpakt
    function getHash(bytes32 keyHash) public view override returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), keyHash));
    }

    constructor() {}
}
