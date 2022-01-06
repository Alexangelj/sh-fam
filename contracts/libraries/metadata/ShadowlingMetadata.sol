//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Attributes.sol";
import "./Stats.sol";
import "./Symbols.sol";
import "../TokenId.sol";
import { Base64, toString } from "../MetadataUtils.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/// @title Helper contract for generating ERC-1155 token ids and descriptions for
/// the individual items inside a Loot bag.
/// @author Georgios Konstantopoulos
/// @dev Inherit from this contract and use it to generate metadata for your tokens
contract ShadowlingMetadata is ERC721Enumerable {
    mapping(uint256 => Attributes.ItemIds) public propertiesOf;

    constructor() ERC721("Shadowlings", "SHDW") {}

    /// @notice Returns the attributes properties of a `tokenId`
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function attributes(uint256 tokenId) public view returns (string memory) {
        string memory output;

        string memory res = string(
            abi.encodePacked(
                "[",
                Attributes.attributes(properties(tokenId)),
                ", ",
                Stats.attributes(tokenId),
                "]"
            )
        );

        output = string(abi.encodePacked('"attributes": ', res, "}"));
        return output;
    }

    /// @dev Opensea contract metadata: https://docs.opensea.io/docs/contract-level-metadata
    function contractURI() external pure returns (string memory) {
        string
            memory json = '{"name": "Shadowlings", "description": "Shadowlings follow you in your journey across chainspace, the shadowchain, and beyond..."}';
        string memory encodedJson = Base64.encode(bytes(json));
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", encodedJson)
        );

        return output;
    }

    /// @notice Returns an SVG for the provided token id
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        "Shadowlings",
                        '", ',
                        '"description" : ',
                        '"Shadowlings follow you in your journey across chainspace, the shadowchain, and beyond...", ',
                        render(tokenId),
                        attributes(tokenId)
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    /// @param  itemId A value in propertiesOf[tokenId]
    /// @return Attributes properties of a single item
    function attributesItem(uint256 itemId)
        public
        pure
        returns (string memory)
    {
        return Scanner.attributes(itemId);
    }

    /// @return Each item as a string from a Shadowling with `tokenId`
    function properties(uint256 tokenId)
        public
        view
        returns (Attributes.ItemStrings memory)
    {
        return Attributes.props(propertiesOf[tokenId]);
    }

    // Symbol Rendering

    function render(uint256 tokenId) public view returns (string memory) {
        string[4] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 500 500" width="500" height="500"><style>.base { fill: #AAA; font-family: "Gill Sans", sans-serif; font-size: 11px; }</style><rect width="100%" height="100%" fill="#000026" />';

        Attributes.ItemStrings memory props = properties(tokenId);
        // string memory svg = string(
        //     abi.encodePacked(Attributes.render(props), Stats.render(tokenId))
        // );

        parts[1] = Attributes.render(props);
        parts[2] = Symbols.render(props);

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2])
        );

        output = string(abi.encodePacked(output, "</svg>"));

        output = string(
            abi.encodePacked(
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(output)),
                '", '
            )
        );

        return output;
    }
}
