// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IVoid {
    function mint(address to, uint256 value) external;

    function burn(address to, uint256 value) external;

    function owner() external view returns (address);
}
