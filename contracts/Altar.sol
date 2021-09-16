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
import "./Shadowpakt.sol";

/// @notice Summons Shadowlings from the Shadowchain
contract Altar is
    IAltar,
    Shadowpakt,
    Ownable,
    ReentrancyGuard,
    IERC1155Receiver,
    IERC721Receiver
{
    using SafeERC20 for IERC20;

    /// @inheritdoc IAltar
    uint256 public constant override SHADOWLING_COST = 10000e18;
    /// @inheritdoc IAltar
    address public override void;
    /// @inheritdoc IAltar
    address public override shadowling;
    /// @inheritdoc IAltar
    mapping(address => uint256) public override cost;
    /// @inheritdoc IAltar
    mapping(uint256 => uint256) public override currencyCost;
    /// @inheritdoc IAltar
    mapping(address => mapping(uint256 => uint256)) public override premium;

    modifier onlyWhitelisted(address token) {
        if (cost[token] == 0) revert ListedError();
        _;
    }

    modifier onlyShadows(uint256 tokenId) {
        if (tokenId < Currency.START_INDEX) revert TokenError();
        _;
    }

    modifier onlyCurrency(uint256 currencyId) {
        if (currencyId > Currency.START_INDEX - 1 || currencyId < 1)
            revert CurrencyError();
        _;
    }

    // === Initialization ===

    /// @inheritdoc IAltar
    function initialize(address void_, address shadowling_)
        external
        override
        onlyOwner
    {
        if (void != address(0)) revert InitializedError();
        if (IVoid(void_).owner() == address(this)) void = void_;

        if (shadowling != address(0)) revert InitializedError();
        if (IVoid(shadowling_).owner() == address(this))
            shadowling = shadowling_;
    }

    // ===== User Actions =====

    /// @inheritdoc IAltar
    function sacrifice721(
        address token,
        uint256 tokenId,
        uint256 shadowlingId
    ) external override nonReentrant onlyWhitelisted(token) {
        address caller = _msgSender();
        uint256 value = totalCost(token, tokenId);

        if (shadowlingId > Currency.START_INDEX) {
            uint256 seed = uint256(
                keccak256(
                    abi.encodePacked(address(this), shadowlingId, tokenId)
                )
            );
            IShadowling(shadowling).claim(shadowlingId, caller, seed);
            value -= SHADOWLING_COST;
        }

        IVoid(void).mint(caller, value);

        IERC721(token).safeTransferFrom(
            caller,
            address(this),
            tokenId,
            new bytes(0)
        );
        emit Sacrificed(caller, token, tokenId, 1, value, shadowlingId);
    }

    /// @inheritdoc IAltar
    function sacrifice1155(
        address token,
        uint256 tokenId,
        uint256 amount,
        uint256 shadowlingId
    ) external override nonReentrant onlyWhitelisted(token) {
        if (amount == 0) revert ZeroError();
        address caller = _msgSender();
        uint256 value = totalCost(token, tokenId);
        if (amount > 1) value = (amount * value) / 1e18; // void token has 18 decimals

        if (shadowlingId > Currency.START_INDEX) {
            uint256 seed = uint256(
                keccak256(
                    abi.encodePacked(address(this), shadowlingId, tokenId)
                )
            );
            IShadowling(shadowling).claim(shadowlingId, caller, seed);
            value -= SHADOWLING_COST;
        }

        IVoid(void).mint(caller, value);

        IERC1155(token).safeTransferFrom(
            caller,
            address(this),
            tokenId,
            amount,
            new bytes(0)
        );
        emit Sacrificed(caller, token, tokenId, amount, value, shadowlingId);
    }

    /// @inheritdoc IAltar
    function claim(uint256 tokenId, bytes32 revealHash)
        external
        override
        nonReentrant
        onlyShadows(tokenId)
    {
        burn(SHADOWLING_COST);
        uint256 seed = revealKey(revealHash);
        address caller = _msgSender();
        IShadowling(shadowling).claim(tokenId, caller, seed);
        emit Claimed(caller, tokenId);
    }

    /// @inheritdoc IAltar
    function modify(
        uint256 tokenId,
        uint256 currencyId,
        bytes32 revealHash
    ) external override nonReentrant onlyShadows(tokenId) {
        uint256 value = currencyCost[currencyId];
        burn(value); // send the currency back to the shadowchain
        uint256 seed = revealKey(revealHash);
        IShadowling(shadowling).modify(tokenId, currencyId, seed);
        emit Modified(msg.sender, tokenId, currencyId);
    }

    function burn(uint256 value) private {
        if (value == 0) revert ZeroError();
        IVoid(void).burn(msg.sender, value);
    }

    // ===== Owner Actions =====

    /// @inheritdoc IAltar
    function setBaseCost(address token, uint256 amount)
        external
        override
        onlyOwner
    {
        cost[token] = amount;
        emit SetBaseCost(_msgSender(), token, amount);
    }

    /// @inheritdoc IAltar
    function setPremiumCost(
        address token,
        uint256 tokenId,
        uint256 amount
    ) external override onlyOwner {
        premium[token][tokenId] = amount;
        emit SetPremiumCost(_msgSender(), token, tokenId, amount);
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
        uint256 tokenId,
        uint256 amount
    ) external override onlyOwner nonReentrant {
        if (amount == 0) revert ZeroError();
        IERC1155(token).safeTransferFrom(
            address(this),
            owner(),
            tokenId,
            amount,
            new bytes(0)
        );
        emit Taken(_msgSender(), token, tokenId, amount);
    }

    /// @inheritdoc IAltar
    function takeSingle(address token, uint256 tokenId)
        external
        override
        onlyOwner
        nonReentrant
    {
        IERC721(token).safeTransferFrom(address(this), owner(), tokenId);
        emit Taken(_msgSender(), token, tokenId, 1);
    }

    // ===== Callbacks =====

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override(IERC721Receiver) returns (bytes4) {
        return Altar.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes calldata
    ) external override(IERC1155Receiver) returns (bytes4) {
        return Altar.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata
    ) external override(IERC1155Receiver) returns (bytes4) {
        return Altar.onERC1155BatchReceived.selector;
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
    function totalCost(address token, uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return cost[token] + premium[token][tokenId];
    }

    constructor() {}
}
