// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "./libraries/metadata/ShadowlingMetadata.sol";
import "./libraries/metadata/DNA.sol";
import "./libraries/MetadataUtils.sol";
import "./libraries/Currency.sol";

import "hardhat/console.sol";

contract Shadowling is
    ShadowlingMetadata,
    ERC1155,
    IERC1155Receiver,
    ReentrancyGuard
{
    constructor() ERC1155("") {}

    error CurrencyError();
    error TokenError();

    uint256[] public minted;

    modifier onlyShadows(uint256 tokenId) {
        if (tokenId < Currency.START_INDEX || tokenId < 1) revert TokenError();
        _;
    }

    modifier onlyCurrency(uint256 tokenId) {
        if (tokenId > Currency.START_INDEX - 1 || tokenId < 1)
            revert CurrencyError();
        _;
    }

    function mint(uint256 tokenId, uint256 amount)
        external
        nonReentrant
        onlyCurrency(tokenId)
    {
        _mint(_msgSender(), tokenId, amount, new bytes(0));
    }

    /// @notice Mints Shadowlings to `msg.sender`, cannot mint 0 tokenId
    function claim(uint256 tokenId) external nonReentrant onlyShadows(tokenId) {
        Attributes.ItemIds memory state = getAll(tokenId);

        propertiesOf[tokenId] = state;
        minted.push(tokenId);
        _mint(_msgSender(), tokenId, 1, new bytes(0));
    }

    /// @notice Mints Shadowchain Origin Shadowlings to shadowpakt members, cannot mint 0 tokenId
    function summon(uint256 tokenId)
        external
        nonReentrant
        onlyShadows(tokenId)
    {
        Attributes.ItemIds memory state = getAll(tokenId);
        state.origin = Attributes.originId(tokenId, true);

        propertiesOf[tokenId] = state;
        minted.push(tokenId);
        _mint(_msgSender(), tokenId, 1, new bytes(0));
    }

    function getAll(uint256 tokenId)
        internal
        returns (Attributes.ItemIds memory)
    {
        return
            Attributes.ItemIds({
                creature: Attributes.creatureId(tokenId),
                flaw: Attributes.flawId(tokenId),
                origin: Attributes.originId(tokenId, false),
                bloodline: Attributes.bloodlineId(tokenId),
                eyes: Attributes.eyesId(tokenId),
                name: Attributes.nameId(tokenId)
            });
    }

    function modify(uint256 tokenId, uint256 currencyId)
        external
        nonReentrant
        onlyShadows(tokenId)
        onlyCurrency(currencyId)
    {
        _burn(_msgSender(), currencyId, 1); // send the currency back to the shadowchain
        Attributes.ItemIds memory cache = propertiesOf[tokenId]; // cache the shadowling props

        string memory bloodline = Attributes.tokenProperty(cache.bloodline);
        uint256 startSeed = DNA.getBloodSeed(tokenId, bloodline);
        string memory sequence = DNA.sequence(startSeed).seq;
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

    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256,
        bytes calldata
    )
        external
        override(IERC1155Receiver)
        onlyShadows(tokenId)
        returns (bytes4)
    {
        // only supports callback from this contract
        require(msg.sender == address(this));
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override(IERC1155Receiver) returns (bytes4) {}

    function uri(uint256 tokenId) public view override returns (string memory) {
        return tokenURI(tokenId);
    }
}
