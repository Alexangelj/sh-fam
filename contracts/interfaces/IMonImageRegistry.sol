// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.6.8;

interface IMonImageRegistry {
    /// @notice 0xmon id linked to the tx hash with its metadata calldata with animation
    function monDataWithAnimation(uint256 id) external returns (bytes memory);

    /// @notice 0xmon id linked to the tx hash with its metadata calldata
    function monDataWithStatic(uint256 id) external returns (bytes memory);

    /// @notice Owner function to prevent the `registerMon` function to be called on id
    function isLocked(uint256 id) external returns (bool);

    /// @notice Fee stored in the MonImageRegistry
    function fee() external returns (uint256);

    /// @notice 0xmon ERC721 address
    function mon() external returns (address);

    /// @notice 0xmon ERC20 address, utility token for 0xmon ecosystem
    function xmonToken() external returns (address);
}
