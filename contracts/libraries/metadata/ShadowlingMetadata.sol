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
        Attributes.ItemStrings memory props = properties(tokenId);
        string memory svg = string(
            abi.encodePacked(Attributes.render(props), Stats.render(tokenId))
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        "Shadowlings",
                        '", ',
                        '"description" : ',
                        '"Shadowlings follow you in your journey across chainspace, the shadowchain, and beyond...", ',
                        render(svg),
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

    function render(string memory attr) public view returns (string memory) {
        string[4] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350" width="350" height="350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="#000026" />';

        parts[1] = attr;
        parts[2] = renderSymbols();

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

    function renderSymbols() internal view returns (string memory) {
        string[11] memory parts;

        parts[0] = '<g transform="scale(0.01) translate(5000, 17000)" >';
        parts[1] = Symbols.OUTER1();
        parts[2] = '</g><g transform="scale(0.01) translate(16000, 2000)" >';
        parts[3] = Symbols.OUTER2();
        parts[4] = '</g><g transform="scale(0.01) translate(27000, 17000)" >';
        parts[5] = Symbols.OUTER3();
        parts[6] = '</g><g transform="scale(0.01) translate(16000, 30000)" >';
        parts[7] = Symbols.OUTER4();
        parts[8] = '</g><g transform="scale(0.1) translate(500, 500)" >';
        parts[9] = Symbols.CENTRAL1();
        parts[10] = "</g>";

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(abi.encodePacked(output, parts[9], parts[10]));

        /* parts[0] = '<g transform="scale(0.1) translate(150, 150)" >';
        parts[9] = Symbols.CENTRAL1();
        parts[10] = "</g>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[9], parts[10])
        ); */
        return output;
    }
}
