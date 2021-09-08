// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

interface IAltar {
    // ===== Events =====

    /// @notice Emitted on upating the base amount of void received from burning an nft
    event SetBaseCost(
        address indexed from,
        address indexed token,
        uint256 indexed base
    );

    /// @notice Emitted on updating the premium amount of void received from burning an nft
    event SetPremiumCost(
        address indexed from,
        address indexed token,
        uint256 indexed tokenId,
        uint256 premium
    );

    /// @notice Emitted on sacrifice and minting of VOID
    event Sacrificed(
        address indexed from,
        address indexed token,
        uint256 indexed tokenId,
        uint256 value
    );

    /// @notice Emitted when an owner removes tokens
    event Taken(
        address indexed from,
        address indexed token,
        uint256 indexed tokenId,
        uint256 amount
    );

    /// @notice Emitted on modifying a Shadowling's attributes
    event Modified(
        address indexed from,
        uint256 indexed tokenId,
        uint256 indexed currencyId
    );

    /// @notice Emitted on burning void tokens to claim a Shadowling
    event Claimed(address indexed from, uint256 indexed tokenId);

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

    /// @notice Void burned for conjuring a Shadowling
    function shadowlingCost() external view returns (uint256);

    /// @notice Cost of the NFT with `address`, denominated in VOID tokens
    function cost(address token) external view returns (uint256);

    /// @notice Maps currencyIds to their respective Void token cost
    function currencyCost(uint256 currencyId) external view returns (uint256);

    /// @notice Additional premium cost of an NFT with `tokenId`, denominated in VOID tokens
    function premium(address token, uint256 tokenId)
        external
        view
        returns (uint256);

    /// @return Amount of VOID minted from sacrificing `token` with `tokenId
    function totalCost(address token, uint256 tokenId)
        external
        view
        returns (uint256);

    // ===== User =====

    /// @notice Mints Shadowlings to `msg.sender`, cannot mint 0 tokenId
    /// @param  tokenId Token with `tokenId` to mint. Maps tokenId to individual item ids in ItemIds
    function claim(uint256 tokenId) external;

    /// @notice Mints Shadowchain Origin Shadowlings to shadowpakt members, cannot mint 0 tokenId
    function summon(uint256 tokenId) external;

    /// @notice Modifies a Shadowling using with the `currencyId`, changing its attributes
    function modify(uint256 tokenId, uint256 currencyId) external;

    /// @notice Sacrifices `token` with `tokenId` to the Shadowpakt, and receives VOID
    /// @dev    Sacrifice function for ERC721, must be approved beforehand
    /// @param  token Asset to sacrifice
    /// @param  tokenId    Specific asset to sacrifice
    /// @param  forShadowling If true, mints a Shadowling using the void that was minted
    function sacrifice721(
        address token,
        uint256 tokenId,
        bool forShadowling
    ) external;

    /// @notice Sacrifices `amount` of `token` with `tokenId` to the Shadowpakt, and receives VOID
    /// @dev    Sacrifice function for ERC1155
    /// @param  token Asset to sacrifice
    /// @param  tokenId    Specific asset to sacrifice
    /// @param  forShadowling If true, mints a Shadowling using the void that was minted
    function sacrifice1155(
        address token,
        uint256 tokenId,
        uint256 amount,
        bool forShadowling
    ) external;

    // ===== Owner =====

    /// @notice Sets the void token and shadowling contract addresses
    /// @dev One time use, these contracts must have their `owner` set to this address
    /// @param void_ Void token contract
    /// @param shadowling_ Shadowlings ERC721 contract
    function initialize(address void_, address shadowling_) external;

    /// @notice Sets the cost of minting a shdowling in void tokens
    function setShadowlingCost(uint256 price) external;

    /// @notice Sets the cost of using this currency, denominated in void tokens
    function setCurrencyCost(uint256 currencyId, uint256 newCost) external;

    /// @notice Update an `address` of an nft to be whitelisted to receive void on burn
    /// @param  token Address to update the cost value of
    /// @param  amount Amount of void minted per `token` burned
    function setBaseCost(address token, uint256 amount) external;

    /// @notice Sets an extra amount of void received from burning an nft with `tokenId`
    /// @param  token Address to update the cost value of
    /// @param  tokenId  Specific tokenId to delist
    /// @param  amount Extra amount of void tokens received
    function setPremiumCost(
        address token,
        uint256 tokenId,
        uint256 amount
    ) external;

    /// @notice Owner function to pull ERC1155 tokens from this contract for nefarious purposes
    function takeMany(
        address token,
        uint256 tokenId,
        uint256 amount
    ) external;

    /// @notice Owner function to pull ERC721 tokens from this contract for nefarious purposes
    function takeSingle(address token, uint256 tokenId) external;
}
