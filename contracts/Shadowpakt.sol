// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IShadowpakt.sol";

/// @author Clement Lakhal
contract Shadowpakt is IShadowpakt, Ownable {
    struct Commit {
        bytes32 commit;
        uint64 blockNumber;
        bool revealed;
    }

    /// STORAGE PROPERTIES ///

    mapping(address => Commit) public commits;

    /// @inheritdoc IShadowpakt
    mapping(address => bool) public override isWhitelisted;

    /// @inheritdoc IShadowpakt
    mapping(bytes32 => bool) public override isHashedKey;

    /// MODIFIERS ///

    /// @notice Restricts the call to a whitelisted sender
    modifier onlyWhitelisted() {
        require(isWhitelisted[msg.sender] == true, "Caller not whitelisted");

        _;
    }

    constructor() {}

    /// @inheritdoc IShadowpakt
    function addKeys(bytes32[] memory hashes) external override onlyOwner {
        for (uint256 i = 0; i < hashes.length; i += 1) {
            isHashedKey[hashes[i]] = true;
        }
    }

    error CommitError();

    function commitKey(bytes32 hashedKey) public {
        if (!isHashedKey[hashedKey]) revert CommitError();
        commits[msg.sender] = Commit({
            commit: hashedKey,
            blockNumber: uint64(block.number),
            revealed: false
        });
    }

    error RevealedError();
    error HashError();
    error BlockError();

    function revealKey(bytes32 revealHash) public {
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
    }

    function getHash(bytes32 keyHash) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), keyHash));
    }

    /// @inheritdoc IShadowpakt
    function useKey(string memory key, address user) public virtual override {
        require(isWhitelisted[user] == false, "Already whitelisted");
        bytes32 hash = keccak256(abi.encodePacked(key));
        require(isHashedKey[hash] == true, "Invalid key");
        isWhitelisted[user] = true;
        isHashedKey[hash] = false;
        emit Whitelisted(user);
    }

    /// @inheritdoc IShadowpakt
    function blacklist(address user) external override onlyOwner {
        isWhitelisted[user] = false;
        emit Blacklisted(user);
    }

    /// VIEW FUNCTIONS ///

    /// @inheritdoc IShadowpakt
    function isKeyValid(string memory key)
        external
        view
        override
        returns (bool)
    {
        bytes32 hash = keccak256(abi.encodePacked(key));
        return isHashedKey[hash];
    }
}
