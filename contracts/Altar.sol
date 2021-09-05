// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IVoid.sol";
import "./interfaces/IAltar.sol";
import "./interfaces/IShadowling.sol";
import "./libraries/Currency.sol";

/// @notice Mints VOID in exchange for whitelisted NFTs
contract Altar is
    IAltar,
    Ownable,
    ReentrancyGuard,
    IERC1155Receiver,
    IERC721Receiver
{
    using SafeERC20 for IERC20;

    /// @inheritdoc IAltar
    address public override void;
    /// @inheritdoc IAltar
    address public override shadowling;
    /// @inheritdoc IAltar
    mapping(uint256 => uint256) public override currencyCost;
    /// @inheritdoc IAltar
    mapping(address => uint256) public override cost;
    /// @inheritdoc IAltar
    mapping(address => mapping(uint256 => uint256)) public override premium;

    modifier onlyWhitelisted(address token) {
        if (cost[token] == 0) revert ListedError();
        _;
    }

    modifier onlyShadows(uint256 tokenId) {
        if (tokenId < Currency.START_INDEX || tokenId < 1) revert TokenError();
        _;
    }

    modifier onlyCurrency(uint256 tokenId) {
        if (tokenId > Currency.START_INDEX - 1 || tokenId < 1)
            revert CurrencyError();
        _;
    }

    // ===== User Actions =====

    /// @inheritdoc IAltar
    function offering(address token, uint256 id)
        external
        override
        nonReentrant
        onlyWhitelisted(token)
    {
        address caller = _msgSender();
        uint256 value = totalCost(token, id);
        IERC721(token).safeTransferFrom(
            caller,
            address(this),
            id,
            new bytes(0)
        );

        IVoid(void).mint(caller, value);
        emit Sacrificed(msg.sender, token, id, value);
    }

    /// @inheritdoc IAltar
    function sacrificeMany(
        address token,
        uint256 id,
        uint256 amount
    ) external override nonReentrant onlyWhitelisted(token) {
        if (amount == 0) revert ZeroError();
        address caller = _msgSender();
        uint256 value = totalCost(token, id);
        IERC1155(token).safeTransferFrom(
            caller,
            address(this),
            id,
            amount,
            new bytes(0)
        );

        IVoid(void).mint(caller, value);
        emit Sacrificed(msg.sender, token, id, value);
    }

    /// @notice Mints a shadowling
    function claim(uint256 tokenId)
        external
        override
        nonReentrant
        onlyShadows(tokenId)
    {
        return IShadowling(shadowling).claim(tokenId, _msgSender());
    }

    /// @notice Summons a shadowling from the shadowchain
    function summon(uint256 tokenId)
        external
        override
        nonReentrant
        onlyShadows(tokenId)
    {
        return IShadowling(shadowling).summon(tokenId, _msgSender());
    }

    /// @notice Modifies a shadowling's attributes
    function modify(uint256 tokenId, uint256 currencyId)
        external
        override
        nonReentrant
        onlyShadows(tokenId)
    {
        burn(currencyId); // send the currency back to the shadowchain
        return IShadowling(shadowling).modify(tokenId, currencyId);
    }

    function burn(uint256 currencyId) private {
        uint256 value = currencyCost[currencyId];
        if (value == 0) revert CurrencyError();
        IVoid(void).burn(_msgSender(), value);
    }

    // ===== Owner Actions =====

    /// @inheritdoc IAltar
    function list(
        address token,
        uint256 id,
        uint256 base,
        uint256 extra
    ) external override onlyOwner {
        if (base == 0) revert ZeroError();
        cost[token] = base;
        if (extra > 0) premium[token][id] = extra;
        emit Listed(msg.sender, token, base, extra);
    }

    /// @inheritdoc IAltar
    function delist(address token, uint256 id) external override onlyOwner {
        delete cost[token];
        delete premium[token][id];
        emit Delisted(msg.sender, token, id);
    }

    /// @inheritdoc IAltar
    function setVoid(address void_) external override onlyOwner {
        if (void != address(0)) revert InitializedError();
        if (IVoid(void_).owner() == address(this)) void = void_;
    }

    /// @inheritdoc IAltar
    function setShadowling(address shadowling_) external override onlyOwner {
        if (shadowling != address(0)) revert InitializedError();
        if (IVoid(shadowling_).owner() == address(this))
            shadowling = shadowling_;
    }

    /// @inheritdoc IAltar
    function setCurrencyCost(uint256 currencyId, uint256 newCost)
        external
        override
        onlyOwner
        onlyCurrency(currencyId)
    {
        currencyCost[currencyId] = newCost;
        emit SetCurrencyCost(currencyId, newCost);
    }

    /// @inheritdoc IAltar
    function takeMany(
        address token,
        uint256 id,
        uint256 amount
    ) external override onlyOwner nonReentrant {
        if (amount == 0) revert ZeroError();
        IERC1155(token).safeTransferFrom(
            address(this),
            owner(),
            id,
            amount,
            new bytes(0)
        );
        emit Taken(msg.sender, token, id, amount);
    }

    /// @inheritdoc IAltar
    function takeSingle(address token, uint256 id)
        external
        override
        onlyOwner
        nonReentrant
    {
        IERC721(token).safeTransferFrom(address(this), owner(), id);
        emit Taken(msg.sender, token, id, 1);
    }

    // ===== Callbacks =====

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override(IERC721Receiver) returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes calldata
    ) external override(IERC1155Receiver) returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata
    ) external override(IERC1155Receiver) returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC1155).interfaceId;
    }

    // ===== View =====

    /// @inheritdoc IAltar
    function totalCost(address token, uint256 id)
        public
        view
        override
        returns (uint256)
    {
        return cost[token] + premium[token][id];
    }

    constructor() {}
}
