// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libraries/metadata/ShadowlingMetadata.sol";
import "./libraries/Random.sol";
import "./libraries/MetadataUtils.sol";
import "./libraries/Currency.sol";

contract Shadowling is ShadowlingMetadata, Ownable, ReentrancyGuard {
    /// @notice Mints Shadowlings to `msg.sender`, cannot mint 0 tokenId
    /// @param  tokenId Token with `id` to mint. Maps id to individual item ids in ItemIds
    function claim(uint256 tokenId, address recipient)
        external
        nonReentrant
        onlyOwner
    {
        propertiesOf[tokenId] = Attributes.ids(tokenId);
        _safeMint(recipient, tokenId);
    }

    /// @notice Mints Shadowchain Origin Shadowlings to shadowpakt members, cannot mint 0 tokenId
    function summon(uint256 tokenId, address recipient)
        external
        nonReentrant
        onlyOwner
    {
        Attributes.ItemIds memory state = Attributes.ids(tokenId);
        state.origin = Attributes.originId(tokenId, true);
        propertiesOf[tokenId] = state;
        _safeMint(recipient, tokenId);
    }

    function modify(uint256 tokenId, uint256 currencyId)
        external
        nonReentrant
        onlyOwner
    {
        Attributes.ItemIds memory cache = propertiesOf[tokenId]; // cache the shadowling props

        string memory bloodline = Attributes.encodedIdToString(cache.bloodline);
        uint256 startSeed = Random.getBloodSeed(tokenId, bloodline);
        string memory sequence = Random.sequence(startSeed);
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked("MODIFY", toString(currencyId), sequence)
            )
        );

        uint256[4] memory values;
        values[0] = cache.creature;
        values[1] = cache.flaw;
        values[2] = cache.ability;
        values[3] = cache.name;

        values = Currency.modify(currencyId, values, seed);

        cache.creature = values[0] > 0 ? Attributes.creatureId(values[0]) : 0;
        cache.flaw = values[1] > 0 ? Attributes.flawId(values[1]) : 0;
        cache.ability = values[2] > 0 ? Attributes.abilityId(values[2]) : 0;
        cache.name = values[3] > 0 ? Attributes.nameId(values[3]) : 0;

        propertiesOf[tokenId] = cache;
    }

    constructor(address altar) {
        transferOwnership(altar);
    }
}
