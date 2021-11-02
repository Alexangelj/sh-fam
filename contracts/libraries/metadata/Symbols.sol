// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import { toString } from "../MetadataUtils.sol";
import "./SymbolStoreCenter.sol";
import "./SymbolStoreOuter.sol";

library Symbols {
  struct Coordinates {
    uint32 x;
    uint32 y;
  }

  function render(uint256 tokenId)
    public 
    pure 
    returns (string memory) 
  {
    string[8] memory parts;
    uint256 count = Symbols.outerSymbolCount(tokenId);

    uint16[6] memory circle_x;
    uint16[6] memory circle_y;
    uint16[6] memory symbol_x;
    uint16[6] memory symbol_y;

    (circle_x, circle_y) = getCircleCoordinates(count);
    (symbol_x, symbol_y) = getSymbolCoordinates(count);

    parts[0] = '<filter id="displacementFilter"><feTurbulence id="turb" type="turbulence" baseFrequency="0.001" numOctaves="2" result="turbulence"/><feDisplacementMap in2="turbulence" in="SourceGraphic" scale="100" xChannelSelector="R" yChannelSelector="G"/></filter><animate href="#turb" id="ani-turb" attributeName="baseFrequency" values="0.001;0.002;0.001" keyTimes="0;0.5;1" dur="15s" repeatCount="indefinite"/><g stroke="#777" stroke-width="0.5" fill="#000026"><circle cx="250" cy="250" r="175"/><polygon points="';
    parts[1] = getPolygonCoordinates(count);
    parts[2] = '"/>';

    for (uint i = 0; i < count; i++) {
      parts[3] = string(
        abi.encodePacked(
          parts[3],
          '<circle cx="',
          toString(circle_x[i]),
          '" cy="',
          toString(circle_y[i]),
          '" r="30"/>'
        )
      );
    }

    for (uint i = 0; i < count; i++) {
      parts[4] = string(
        abi.encodePacked(
          parts[4],
          '<g fill="white"><g transform="translate(',
          toString(symbol_x[i]),
          ',',
          toString(symbol_y[i]),
          ') scale(0.03)">',
          pluckOuterSymbol(tokenId,i),
          '</g><animateTransform attributeName="transform" type="rotate" from="360 ',
          toString(circle_x[i]),
          ' ',
          toString(circle_y[i]),
          '" to="0 ',
          toString(circle_x[i]),
          ' ',
          toString(circle_y[i]),
          '" dur="10s" repeatCount="indefinite"/></g>'
        )
      );
    }

    parts[5] = '<animateTransform attributeName="transform" type="rotate" from="0 250 250" to="360 250 250" dur="60s" repeatCount="indefinite"/></g><g  fill="white" transform="scale(0.15) translate(400, 400)" filter="url(#displacementFilter)">';

    parts[6] = pluckCentralSymbol(tokenId);
    parts[7] = "</g>";

    string memory output = string(
        abi.encodePacked(
          parts[0],
          parts[1],
          parts[2],
          parts[3],
          parts[4],
          parts[5],
          parts[6],
          parts[7]
        )
    );

    return output;
  }

  function outerSymbolCount(uint256 tokenId)
    internal
    pure
    returns (uint256)
  {
    uint256 numSymbols = (uint256(keccak256(abi.encodePacked("outer", tokenId))) % 4) + 3;

    return numSymbols;
  }

  function pluckCentralSymbol(uint256 tokenId)
    internal
    pure
    returns (string memory)
  {
    uint256 rndIndex = (uint256(keccak256(abi.encodePacked("central", tokenId))) % 8) + 1;

    return SymbolStoreCenter.getSymbol(rndIndex);
  }

  function pluckOuterSymbol(uint256 tokenId, uint256 index)
    internal
    pure
    returns (string memory)
  {
    uint rnd = (uint256(keccak256(abi.encodePacked("outer", tokenId, index))) % 13) + 1;

    return SymbolStoreOuter.getSymbol(rnd);
  }

  function getCircleCoordinates(uint count)
    private
    pure
    returns (uint16[6] memory x, uint16[6] memory y)
  {
    if (count == 3) {
      return ([98,250,402,0,0,0],[338,75,338,0,0,0]);
    }
    if (count == 4) {
      return ([75,250,425,250,0,0],[250,75,250,425,0,0]);
    }
    if (count == 5) {
      return ([84,250,416,353,147,0],[196,75,196,391,391,0]);
    }
    if (count == 6) {
      return ([75,162,338,425,338,162],[250,98,98,250,402,402]);
    }
  }

  function getPolygonCoordinates(uint count)
    private
    pure
    returns (string memory points)
  {
    if (count == 3) {
      return "85,350 250,55 415,350";
    }
    if (count == 4) {
      return "55,250 250,55 445,250 250,445";
    }
    if (count == 5) {
      return "84,196 416,196 147,391 250,75 353,391 84,196 250,75 416,196 353,391 147,391";
    }
    if (count == 6) {
      return "75,250 338,98 338,402 75,250 162,98 425,250 162,402 162,98 338,98 425,250 338,402 162,402";
    }
  }

  function getSymbolCoordinates(uint count)
    private
    pure
    returns (uint16[6] memory x, uint16[6] memory y)
  {
    if (count == 3) {
      return ([60,211,365,0,0,0],[300,38,300,0,0,0]);
    }
    if (count == 4) {
      return ([37,211,388,211,0,0],[211,38,211,388,0,0]);
    }
    if (count == 5) {
      return ([46,211,380,316,108,0],[157,38,157,352,352,0]);
    }
    if (count == 6) {
      return ([37,124,300,388,300,124],[211,61,61,211,362,362]);
    }
  }
}
