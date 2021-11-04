// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../strings.sol";
import "../MetadataUtils.sol";
import "../Random.sol";

/// @notice Inspired by LootComponents by dhof
/// @dev    Raw materials arrays and a plucker
library Components {
    using strings for string;
    using strings for strings.slice;

    string internal constant suffixes =
        "of Borrowed Souls,of Synthetics,of Yield,of Qua'Driga,of Liquidation Pools,of Asteroids,of Atoms,of Betelgeuse,of Celestial,of the Cosmics,of Cybernetics,of Dark Nebulas,of Dopplers,of Electromagnetism,of the Elements,of Meta,of the Hyperscape,of Mars,of Parallax,of Zenith,of Judgement,of Technology,of Hyperspace,of Cyberspace";
    uint256 constant suffixesLength = 24;

    string internal constant namePrefixes =
        "Balthazar,Larp,Rugged,Doxxed,Simp,Meme,Moon,Oracle,Astrogate,Android,Blaster,Cloaking,Continuum,Cyborg,Death Ray,Disintegrator,Earthborn,Digital,Force,Genetic,Holographic,Hyperdrive,Ionic,Jump,Light Speed,Martian,Mech,Matrix,Multiversal,Nebula,Null,Outerworld,Phase,Replicant,Machine,Shield,Space,Starbase,Paradox,Time,Ultraviolet,Fusion,Zero,Quantum,Artificial,Intelligent";
    uint256 constant namePrefixesLength = 46;

    string internal constant nameSuffixes =
        "Nocoiner,Maximus,Degen,All-In,Apesbane,Bearsbane,Minimaxi,Bridgecrosser,Bridgeburner,Goldman,Beam,Comlink,Cyberpunk,Dimensional,Disruptor,Dystopian,Nomadic,Scan,Galactic,Gravity,Humanoid,Hyperspeed,Interplanetary,Laser,Lunar,Matter,Mercurial,Morphic,Mutant,Nova,Orbital,Parallel,Ray,Robot,Sapient,Sol,Pirate,Temporal,Terra,Warp,Uranium,Worm,Xeno";
    uint256 constant nameSuffixesLength = 43;

    string internal constant creatures =
        "None,Twisted Memwraith,Hashenhorror,Shadow Wen,Bear Ape,Moon Wolf,Size Lorde,Degendragon,GM Doge,Lite Llama,Yearning Nymph,Crvaceous Snake,Holovyper,Wailing Integer,Craaven Defaulter,Byzantine Princesss,Manbearpig,Larping Terror,T-Rekt,Defi-ant,Ropsten Whale,Llama,Enchanted Rug,Blind Oracle,Gwei Accountant,Lazarus Cotten,Mempool Wraith,Pernicious Penguin,Seed Stalker,Snark,Shadowswapper,Ravage 0xxl,Market Rat,Dread Dip Dog,Axallaxxa,Fragmented Cobielodon,Jomoeon,Umbramystics,Pepboi,Cypher Ghouls,Censor Vines,Tormented Gorgon,Sushi Kraken,Alpha-eating Ooze,Kirby,Rinkeby Raider,Smol banteg,Blockworm,Metaworm";
    uint256 internal constant creaturesLength = 49;

    string internal constant items =
        "Cybernetic Arm,Cybernetic Eye,Cybernetic Leg,Cybernetic Chest,Cybernetic Foot,Plasma Rifle,Blue Pill,Red Pill,A Block,Cloaking Device,Transporter,Bridge Key,Digital Land,Metawallet,Orb of Protection,Coin,Deck of Cards,Gas,Godblood,Memfruit,Calldata,Event Data,Transaction Data,Metadata,Royalties,Killswitch,Private Key,Cyberknife,Vial of Corruption,Vial of Regeneration,Meta Planet,Meta Golf Course,Meta Tower,Meta Skyscaper,Meta Race Track,Key to the City,Extra Life,Pocket Vehicle,Meta Apartment,Meta House,Meta Company,Divine Bodysuit,Phase Katana,Orb of Summoning,Bottomless Bag,Hoverboard,Merkle Root,Ancient Tattoo";
    uint256 internal constant itemsLength = 48;

    string internal constant origins =
        "Shadowkain's Domain,Kulechovs Dominion,Perilous Farms,Dark Forest,Mempool,Shadowchain,Polygonal Meshspace,Lands of Arbitrum,Chainspace,Chains of Nazarov,Blue Lagoon,Swamp,Genesis Cube,Lands of Optimism,Ether Chain,Outerblocks";
    uint256 internal constant originsLength = 16;

    string internal constant bloodlines =
        "O,Wokr,Vmew,Kali-Zui,Zaphthrot,Luban,Yu-Koth,Sturrosh,Ia-Ngai,Khakh,Gyathna,Huacas,Zhar and Lloigor,Xl-rho,Shudde Mell,Crethagu,Unsca Norna,Phvithvre,Yorae,Ydheut,Pa'ch,Waarza,Chhnghu,Shi-Yvgaa,Ximayya Xan,l'Totoxl,Wakan,Ythogtha,Ub-ji,Shuaicha,Sthuma,Senne'll,Xyngogtha";
    uint256 internal constant bloodlinesLength = 33;

    string internal constant perks =
        "3'3,Shitposting,Diamond Bull Horns,Masternode,Front Running,MEV Collector,NFT Flipper,Artblocks Connoisseur,Diamond Hands,Free Transactions,Made It,Flash Bundler,Private Relays,Compounding,Galaxy Brain,Low IQ,High IQ,Rugged,Doxxed,Liquidated,Waifu Simp,Exploited,Paper Hands,Flash Loaned,UTXO,Theorist,NGMI,Mid IQ,Copy Trader,Larper,Floor seller,Goxxed,Oyster Forked,Chad Bro,Exit Liquidity,Hacked,Failed Transaction,Black Hat,White Hat,Zero Knowledge";
    uint256 internal constant perksLength = 40;

    string internal constant names =
        "Satoshi,Vitalik,Vlad,Adam,Ailmar,Darfin,Jhaan,Zabbas,Neldor,Gandor,Bellas,Daealla,Nym,Vesryn,Angor,Gogu,Malok,Rotnam,Chalia,Astra,Fabien,Orion,Quintus,Remus,Rorik,Sirius,Sybella,Azura,Dorath,Freya,Ophelia,Yvanna,Zeniya,James,Robert,John,Michael,William,David,Richard,Joseph,Thomas,Charles,Mary,Patricia,Jennifer,Linda,Elizabeth,Kwisatz,Barbara,Susan,Jessica,Sarah,Karen,Dilibe,Eva,Matthew,Bolethe,Polycarp,Ambrogino,Jiri,Chukwuebuka,Chinonyelum,Mikael,Mira,Aniela,Samuel,Isak,Archibaldo,Chinyelu,Kerstin,Abigail,Olympia,Grace,Nahum,Elisabeth,Serge,Sugako,Patrick,Florus,Svatava,Ilona,Lachlan,Caspian,Filippa,Paulo,Darda,Linda,Gradasso,Carly,Jens,Betty,Ebony,Dennis,Martin Davorin,Laura,Jesper,Remy,Onyekachukwu,Jan,Dioscoro,Hilarij,Rosvita,Noah,Patrick,Mohammed,Chinwemma,Raff,Aron,Miguel,Dzemail,Gawel,Gustave,Efraim,Adelbert,Jody,Mackenzie,Victoria,Selam,Jenci,Ulrich,Chishou,Domonkos,Stanislaus,Fortinbras,George,Daniel,Annabelle,Shunichi,Bogdan,Anastazja,Marcus,Monica,Martin,Yuukou,Harriet,Geoffrey,Jonas,Dennis,Hana,Abdelhak,Ravil,Patrick,Karl,Eve,Csilla,Isabella,Radim,Thomas,Faina,Rasmus,Alma,Charles,Chad,Zefram,Hayden,Joseph,Andre,Irene,Molly,Cindy,Su,Stani,Ed,Janet,Cathy,Kyle,Zaki,Belle,Bella,Jessica,Amou,Steven,Olgu,Eva,Ivan,Vllad,Helga,Anya,John,Rita,Evan,Jason,Donald,Tyler,Changpeng,Sam";
    uint256 internal constant namesLength = 187;

    // ===== Components ====

    function creatureComponents(uint256 seed)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(seed, "CREATURE", creaturesLength);
    }

    function itemComponents(uint256 seed)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(seed, "ITEM", itemsLength);
    }

    function originComponents(uint256 seed, bool shadowChain)
        internal
        pure
        returns (uint256[5] memory)
    {
        if (shadowChain) return pluck(seed, "ORIGIN", 5);
        return pluck(seed, "ORIGIN", originsLength);
    }

    function bloodlineComponents(uint256 seed)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(seed, "BLOODLINE", bloodlinesLength);
    }

    function perkComponents(uint256 seed)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(seed, "PERK", perksLength);
    }

    function nameComponents(uint256 seed)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(seed, "NAME", namesLength);
    }

    // ===== Pluck Index Numbers of Raw Materials =====

    /// @notice Uses seed value to get a component
    /// @param seed Pseudorandom number from commit-reveal scheme
    /// @param keyPrefix Type of item being plucked, hashed together with seed
    /// @param sourceCSVLength Length of the array of values
    /// @return New array of values which act as index numbers for respective string csv arrays
    function pluck(
        uint256 seed,
        string memory keyPrefix,
        uint256 sourceCSVLength
    ) internal pure returns (uint256[5] memory) {
        uint256[5] memory components;

        seed = uint256(keccak256(abi.encodePacked(keyPrefix, seed)));

        components[0] = seed % sourceCSVLength;
        components[1] = 0;
        components[2] = 0;

        uint256 greatness = seed % 21;
        if (greatness > 14) {
            components[1] = (seed % suffixesLength) + 1;
        }
        if (greatness >= 19) {
            components[2] = (seed % namePrefixesLength) + 1;
            components[3] = (seed % nameSuffixesLength) + 1;
            if (greatness == 19) {
                // ...
            } else {
                components[4] = 1;
            }
        }

        return components;
    }

    // ===== Get Item from Components =====

    function getItemFromCSV(string memory str, uint256 index)
        internal
        pure
        returns (string memory)
    {
        strings.slice memory strSlice = str.toSlice();
        string memory separatorStr = ",";
        strings.slice memory separator = separatorStr.toSlice();
        strings.slice memory item;
        for (uint256 i = 0; i <= index; i++) {
            item = strSlice.split(separator);
        }
        return item.toString();
    }

    // ===== Get Item from Affixes ====

    function getNamePrefixes(uint256 index)
        internal
        pure
        returns (string memory)
    {
        return getItemFromCSV(namePrefixes, index);
    }

    function getNameSuffixes(uint256 index)
        internal
        pure
        returns (string memory)
    {
        return getItemFromCSV(nameSuffixes, index);
    }

    function getSuffixes(uint256 index) internal pure returns (string memory) {
        return getItemFromCSV(suffixes, index);
    }
}
