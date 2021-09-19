// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libraries/metadata/ShadowlingMetadata.sol";
import "./libraries/Random.sol";
import "./libraries/MetadataUtils.sol";
import "./libraries/Currency.sol";

contract Shadowlings is ShadowlingMetadata, Ownable, ReentrancyGuard {
    /// @notice Mints Shadowlings to `msg.sender`, cannot mint 0 tokenId
    /// @param  tokenId Token with `id` to mint. Maps id to individual item ids in ItemIds
    /// @param  recipient Address which is minted a Shadowling
    /// @param  seed Psuedorandom number hopefully generated from commit-reveal scheme
    function claim(
        uint256 tokenId,
        address recipient,
        uint256 seed
    ) external nonReentrant onlyOwner {
        propertiesOf[tokenId] = Attributes.ids(seed);
        _safeMint(recipient, tokenId);
    }

    /// @notice Modifies the attributes of Shadowling with `tokenId` using the type of currency
    /// @param tokenId Shadowling tokenId to modify
    /// @param currencyId Type of currency to use
    /// @param seed Pseudorandom value hopefully generated from a commit-reveal scheme
    function modify(
        uint256 tokenId,
        uint256 currencyId,
        uint256 seed
    ) external nonReentrant onlyOwner {
        Attributes.ItemIds memory cache = propertiesOf[tokenId]; // cache the shadowling props

        uint256[4] memory values;
        values[0] = cache.creature;
        values[1] = cache.item;
        values[2] = cache.perk;
        values[3] = cache.name;

        values = Currency.modify(currencyId, values, seed); // Most important fn

        cache.creature = values[0] > 0 ? Attributes.creatureId(values[0]) : 0;
        cache.item = values[1] > 0 ? Attributes.itemId(values[1]) : 0;
        cache.perk = values[2] > 0 ? Attributes.perkId(values[2]) : 0;
        cache.name = values[3] > 0 ? Attributes.nameId(values[3]) : 0;

        propertiesOf[tokenId] = cache;
    }

    constructor(address altar) {
        transferOwnership(altar);
    }
}
