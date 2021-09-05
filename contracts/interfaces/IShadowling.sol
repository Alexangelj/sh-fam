// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IShadowling {
    function claim(uint256 tokenId, address recipient) external;

    function summon(uint256 tokenId, address recipient) external;

    function modify(uint256 tokenId, uint256 currencyId) external;

    function propertiesOf(uint256 tokenId)
        external
        view
        returns (
            uint256 creature,
            uint256 flaw,
            uint256 origin,
            uint256 bloodline,
            uint256 eyes,
            uint256 name
        );
}
