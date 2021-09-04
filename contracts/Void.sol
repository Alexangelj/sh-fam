// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Void is ERC20Votes, Ownable, ReentrancyGuard {
    /// @notice Minter contract for Void tokens
    address public portal;

    function mint(address to, uint256 value) external onlyOwner {
        _mint(to, value);
    }

    constructor(address portal_)
        ERC20Permit("Void Token")
        ERC20("VOID", "Void Token")
    {
        portal = portal_;
        transferOwnership(portal_);
    }
}