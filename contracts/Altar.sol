// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IVoid.sol";

/// @notice Mints VOID in exchange for whitelisted NFTs
contract Altar is Ownable, ReentrancyGuard, IERC1155Receiver, IERC721Receiver {
    /// @notice Cost of the NFT with `address`, denominated in VOID tokens
    mapping(address => uint256) public cost;
    /// @notice Additional premium cost of an NFT with `id`, denominated in VOID tokens
    mapping(address => mapping(uint256 => uint256)) public premium;
    /// @notice Void Token to mint
    address public void;

    /// @notice Emitted on upating the `cost` mapping
    event Registered(
        address indexed from,
        address indexed token,
        uint256 indexed base,
        uint256 extra
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

    /// @notice Thrown on attempting to burn a non-whitelisted asset
    error RegisteredError();
    /// @notice Thrown on passing a zero value as a parameter, you're welcome
    error ZeroError();

    modifier onlyWhitelisted(address token) {
        if (cost[token] == 0) revert RegisteredError();
        _;
    }

    /// @notice Update an `address` to be whitelisted or not
    /// @param  token Address to update the cost value of
    /// @param  base Amount of VOID minted per `token` burned
    /// @param  extra Amount of VOID minted in addition to the base cost, for `token` with `id
    function register(
        address token,
        uint256 id,
        uint256 base,
        uint256 extra
    ) external onlyOwner {
        if (base == 0) revert ZeroError();
        cost[token] = base;
        if (extra > 0) premium[token][id] = extra;
        emit Registered(msg.sender, token, base, extra);
    }

    /// @notice Sacrifices `token` with `id` to the Shadowpakt, and receives VOID
    /// @dev    Sacrifice function for ERC721, must be approved beforehand
    /// @param  token Asset to sacrifice
    /// @param  id    Specific asset to sacrifice
    function sacrifice(address token, uint256 id)
        external
        nonReentrant
        onlyWhitelisted(token)
    {
        address caller = _msgSender();
        uint256 value = valueOf(token, id);
        IERC721(token).safeTransferFrom(
            caller,
            address(this),
            id,
            new bytes(0)
        );

        IVoid(void).mint(caller, value);
        emit Sacrificed(msg.sender, token, id, value);
    }

    /// @notice Sacrifices `amount` of `token` with `id` to the Shadowpakt, and receives VOID
    /// @dev    Sacrifice function for ERC1155
    /// @param  token Asset to sacrifice
    /// @param  id    Specific asset to sacrifice
    function sacrifice(
        address token,
        uint256 id,
        uint256 amount
    ) external nonReentrant onlyWhitelisted(token) {
        if (amount == 0) revert ZeroError();
        address caller = _msgSender();
        uint256 value = valueOf(token, id);
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

    /// @return Amount of VOID minted from sacrificing `token` with `id
    function valueOf(address token, uint256 id) public view returns (uint256) {
        return cost[token] + premium[token][id];
    }

    /// @notice Owner function to pull ERC1155 tokens from this contract for nefarious purposes
    function take(
        address token,
        uint256 id,
        uint256 amount
    ) external onlyOwner nonReentrant {
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

    /// @notice Owner function to pull ERC721 tokens from this contract for nefarious purposes
    function take(address token, uint256 id) external onlyOwner nonReentrant {
        IERC721(token).safeTransferFrom(address(this), owner(), id);
        emit Taken(msg.sender, token, id, 1);
    }

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

    constructor() {}
}
