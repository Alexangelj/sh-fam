// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./libraries/metadata/ShadowlingMetadata.sol";
import "./libraries/Random.sol";
import "./libraries/MetadataUtils.sol";
import "./libraries/Currency.sol";
import "./Shadowpakt.sol";

import "hardhat/console.sol";

contract Shadowling is Shadowpakt, ShadowlingMetadata, ReentrancyGuard {
    using SafeERC20 for IERC20;
    error CurrencyError();
    error TokenError();

    event SetCost(uint256 indexed currencyId, uint256 indexed cost);

    /// @return Address of the void token contract
    address public void;
    /// @notice Maps currencyIds to their respective Void token cost
    mapping(uint256 => uint256) public costOf;

    modifier onlyShadows(uint256 tokenId) {
        if (tokenId < Currency.START_INDEX || tokenId < 1) revert TokenError();
        _;
    }

    modifier onlyCurrency(uint256 tokenId) {
        if (tokenId > Currency.START_INDEX - 1 || tokenId < 1)
            revert CurrencyError();
        _;
    }

    /// @notice Mints Shadowlings to `msg.sender`, cannot mint 0 tokenId
    /// @param  tokenId Token with `id` to mint. Maps id to individual item ids in ItemIds
    function claim(uint256 tokenId) external nonReentrant onlyShadows(tokenId) {
        Attributes.ItemIds memory state = Attributes.ids(tokenId);

        propertiesOf[tokenId] = state;
        _safeMint(_msgSender(), tokenId);
    }

    /// @notice Mints Shadowchain Origin Shadowlings to shadowpakt members, cannot mint 0 tokenId
    function summon(uint256 tokenId)
        external
        nonReentrant
        onlyShadows(tokenId)
    {
        Attributes.ItemIds memory state = Attributes.ids(tokenId);
        state.origin = Attributes.originId(tokenId, true);

        propertiesOf[tokenId] = state;
        _safeMint(_msgSender(), tokenId);
    }

    function modify(uint256 tokenId, uint256 currencyId)
        external
        nonReentrant
        onlyShadows(tokenId)
        onlyCurrency(currencyId)
    {
        burnCurrency(currencyId); // send the currency back to the shadowchain

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
        values[2] = cache.eyes;
        values[3] = cache.name;

        values = Currency.modify(currencyId, values, seed);

        console.log(tokenId);
        console.log(values[0], values[1], values[2], values[3]);

        cache.creature = values[0] > 0 ? Attributes.creatureId(values[0]) : 0;
        cache.flaw = values[1] > 0 ? Attributes.flawId(values[1]) : 0;
        cache.eyes = values[2] > 0 ? Attributes.eyesId(values[2]) : 0;
        cache.name = values[3] > 0 ? Attributes.nameId(values[3]) : 0;

        propertiesOf[tokenId] = cache;
    }

    function burnCurrency(uint256 currencyId) private {
        uint256 cost = costOf[currencyId];
        IERC20(void).safeTransferFrom(_msgSender(), address(this), cost);
    }

    function setCost(uint256 currencyId, uint256 newCost)
        external
        onlyOwner
        onlyCurrency(currencyId)
    {
        costOf[currencyId] = newCost;
        emit SetCost(currencyId, newCost);
    }

    constructor() {}
}
