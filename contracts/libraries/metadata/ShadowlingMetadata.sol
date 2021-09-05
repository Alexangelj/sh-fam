//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Attributes.sol";
import "./Stats.sol";
import "../TokenId.sol";
import { Base64, toString } from "../MetadataUtils.sol";

/// @title Helper contract for generating ERC-1155 token ids and descriptions for
/// the individual items inside a Loot bag.
/// @author Georgios Konstantopoulos
/// @dev Inherit from this contract and use it to generate metadata for your tokens
contract ShadowlingMetadata {
    mapping(uint256 => Attributes.ItemIds) public propertiesOf;

    function name() external pure returns (string memory) {
        return "Shadowling";
    }

    function symbol() external pure returns (string memory) {
        return "SHDW";
    }

    /// @dev Opensea contract metadata: https://docs.opensea.io/docs/contract-level-metadata
    function contractURI() external pure returns (string memory) {
        string
            memory json = '{"name": "Shadowling", "description": "Shadowlings follow you in your journey across chainspace, the shadowchain, and beyond..."}';
        string memory encodedJson = Base64.encode(bytes(json));
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", encodedJson)
        );

        return output;
    }

    /// @notice Returns an SVG for the provided token id
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        Attributes.ItemStrings memory props = properties(tokenId);
        string memory stats = Stats.render(tokenId);
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        "Shadowling",
                        '", ',
                        '"description" : ',
                        '"Shadowlings follow you in your journey across chainspace, the shadowchain, and beyond...", ',
                        Attributes.render(props, stats),
                        Attributes.attributes(props)
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    /// @notice Returns the attributes properties of a `tokenId`
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function attributes(uint256 tokenId) public view returns (string memory) {
        return Attributes.attributes(properties(tokenId));
    }

    /// @notice Returns the attributes properties of a single item
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    /// @param  itemId A value in propertiesOf[tokenId]
    function attributesItem(uint256 itemId)
        public
        view
        returns (string memory)
    {
        return Scanner.attributes(itemId);
    }

    function properties(uint256 tokenId)
        public
        view
        returns (Attributes.ItemStrings memory)
    {
        return Attributes.props(propertiesOf[tokenId]);
    }
}
