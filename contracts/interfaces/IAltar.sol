// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IAltar {
    // ===== Events =====

    /// @notice Emitted on upating the `cost` mapping
    event Listed(
        address indexed from,
        address indexed token,
        uint256 indexed base,
        uint256 extra
    );

    /// @notice Emitted on deletion of entry
    event Delisted(
        address indexed from,
        address indexed token,
        uint256 indexed id
    );

    /// @notice Emitted on sacrifice and minting of VOID
    event Sacrificed(
        address indexed from,
        address indexed token,
        uint256 indexed id,
        uint256 value
    );

    /// @notice Emitted when an owner removes tokens
    event Taken(
        address indexed from,
        address indexed token,
        uint256 indexed id,
        uint256 amount
    );

    /// @notice Emitted on setting the price of a currency usage in void tokens
    event SetCurrencyCost(uint256 indexed currencyId, uint256 indexed cost);

    // ===== Errors =====

    /// @notice Thrown on attempting to burn a non-whitelisted asset
    error ListedError();
    /// @notice Thrown on passing a zero value as a parameter, you're welcome
    error ZeroError();
    /// @notice Thrown on attempting to set an already set `void`
    error InitializedError();
    /// @notice Thrown on attempting to use incorrect currencyId
    error CurrencyError();
    /// @notice Thrown on attempting to use inccorect tokenId
    error TokenError();

    // ===== View =====

    /// @notice Void Token to mint
    function void() external view returns (address);

    /// @notice Shadowling NFT
    function shadowling() external view returns (address);

    /// @notice Maps currencyIds to their respective Void token cost
    function currencyCost(uint256 currencyId) external view returns (uint256);

    /// @notice Cost of the NFT with `address`, denominated in VOID tokens
    function cost(address token) external view returns (uint256);

    /// @notice Additional premium cost of an NFT with `id`, denominated in VOID tokens
    function premium(address token, uint256 id) external view returns (uint256);

    /// @return Amount of VOID minted from sacrificing `token` with `id
    function totalCost(address token, uint256 id)
        external
        view
        returns (uint256);

    // ===== Users =====

    /// @notice Mints Shadowlings to `msg.sender`, cannot mint 0 tokenId
    /// @param  tokenId Token with `id` to mint. Maps id to individual item ids in ItemIds
    function claim(uint256 tokenId) external;

    /// @notice Mints Shadowchain Origin Shadowlings to shadowpakt members, cannot mint 0 tokenId
    function summon(uint256 tokenId) external;

    /// @notice Modifies a Shadowling using with the `currencyId`, changing its attributes
    function modify(uint256 tokenId, uint256 currencyId) external;

    /// @notice Sacrifices `token` with `id` to the Shadowpakt, and receives VOID
    /// @dev    Sacrifice function for ERC721, must be approved beforehand
    /// @param  token Asset to sacrifice
    /// @param  id    Specific asset to sacrifice
    function offering(address token, uint256 id) external;

    /// @notice Sacrifices `amount` of `token` with `id` to the Shadowpakt, and receives VOID
    /// @dev    Sacrifice function for ERC1155
    /// @param  token Asset to sacrifice
    /// @param  id    Specific asset to sacrifice
    function sacrificeMany(
        address token,
        uint256 id,
        uint256 amount
    ) external;

    // ===== Access =====

    /// @notice Sets the void token to this contract
    function setVoid(address void_) external;

    /// @notice Sets the shadowling contract
    function setShadowling(address shadowling_) external;

    /// @notice Sets the cost of using this currency, denominated in void tokens
    function setCurrencyCost(uint256 currencyId, uint256 newCost) external;

    /// @notice Update an `address` to be whitelisted or not
    /// @param  token Address to update the cost value of
    /// @param  id  Specific tokenId to delist
    function delist(address token, uint256 id) external;

    /// @notice Update an `address` to be whitelisted or not
    /// @param  token Address to update the cost value of
    /// @param  base Amount of VOID minted per `token` burned
    /// @param  extra Amount of VOID minted in addition to the base cost, for `token` with `id
    function list(
        address token,
        uint256 id,
        uint256 base,
        uint256 extra
    ) external;

    /// @notice Owner function to pull ERC1155 tokens from this contract for nefarious purposes
    function takeMany(
        address token,
        uint256 id,
        uint256 amount
    ) external;

    /// @notice Owner function to pull ERC721 tokens from this contract for nefarious purposes
    function takeSingle(address token, uint256 id) external;
}
