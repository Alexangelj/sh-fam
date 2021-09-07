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
        "of Borrowed Souls,of Synthetics,of Yield, of Qua'Driga,of Liquidation Pools,of Power,of Giants,of Titans,of Skill,of Perfection,of Brilliance,of Enlightenment,of Protection,of Anger,of Rage,of Fury,of Vitriol,of the Fox,of Detection,of Reflection,of the Twins";
    uint256 constant suffixesLength = 21;

    string internal constant namePrefixes =
        "Balthazar,NoGm,The Larp,The Rugged,The Doxxed,The Simp,The Meme,The Top buyer,The Bottom seller,The Moon,The Oracle,Agony,Apocalypse,Armageddon,Beast,Behemoth,Blight,Blood,Bramble,Brimstone,Brood,Carrion,Cataclysm,Chimeric,Corpse,Corruption,Damnation,Death,Demon,Dire,Dragon,Dread,Doom,Dusk,Eagle,Empyrean,Fate,Foe,Gale,Ghoul,Gloom,Glyph,Golem,Grim,Hate,Havoc,Honour,Horror,Hypnotic,Kraken,Loath,Maelstrom,Mind,Miracle,Morbid,Oblivion,Onslaught,Pain,Pandemonium,Phoenix,Plague,Rage,Rapture,Rune,Skull,Sol,Soul,Sorrow,Spirit,Storm,Tempest,Torment,Vengeance,Victory,Viper,Vortex,Woe,Wrath,Light's,Shimmering";
    uint256 constant namePrefixesLength = 80;

    string internal constant nameSuffixes =
        "Nocoiner,Maximus,Ngmi,Degen,Black Hat,White Hat,All-In,Apesbane,Bearsbane,Minimaxi,Bridgecrosser,Bridgeburner,Goldman,Bane,Root,Bite,Song,Roar,Grasp,Instrument,Glow,Bender,Shadow,Whisper,Shout,Growl,Tear,Peak,Form,Sun,Moon";
    uint256 constant nameSuffixesLength = 31;

    string internal constant creatures =
        "None,Twisted Memwraith,Hashenhorror,Shadow Wen,Bear Ape,Moon Wolf,Size Lorde,Degendragon,GM Doge,Lite Llama,Yearning Nymph,Crvaceous Snake,Holovyper,Wailing Integer,Craaven Defaulter,Floating Eyes of Sec,Byzantine Princesss,Manbearpig,Larping Terror,T-Rekt,Defi-ant ,Ropsten Whale,Llama,Enchanted Rug,Blind Oracle,Gwei Accountant,Lazarus Cotten,Mempool Wraith,Pernicious penguins,Seed Stalker,Snark,Shadowswapper,Ravage 0xxl,Market Rat,Dread Dip Dog,Axallaxxa,Fragmented Cobielodon,Jomoeon,Umbramystics,Pepboi,Cypher Ghouls,Censor Vines,Tormented Gorgon,Sushi Kraken,Alpha-eating Ooze,Blathering Kirby,Rinkeby Raider,Smol banteg";
    uint256 internal constant creaturesLength = 47;

    string internal constant flaws =
        "Rugged ,Doxxed,Liquidated,Waifu simp,Exploited,Paper hands,Flash Loaned,UTXO,Theorist,NGMI,Mid IQ,Copy Trader,Larper,Floor seller,Goxxed,Oyster Forked,Chad Bro,Exit Liquidity,Hacked,Failed Transaction";
    uint256 internal constant flawsLength = 20;

    string internal constant origins =
        "Shadowkain's Domain,Kulechovs Dominion ,Perilous Farms,Oceans of Degen Tears,Dark Forest,Mempool,Shadowchain,Polygonal Meshspace,Lands of Arbitrary Optimism,Chainspace,Chains of Nazarov,Blue Lagoon,Swamp,Genesis Cube";
    uint256 internal constant originsLength = 14;

    string internal constant bloodlines =
        "O,Wokr,Vmew,Kali-Zui,Zaphthrot,Luban,Yu-Koth,Sturrosh,Ia-Ngai,Khakh,Gyathna,Huacas,Zhar & Lloigor,Xl-rho,Shudde Mell,Crethagu,Unsca Norna,Phvithvre,Yorae,Ydheut,Pa'ch,Waarza,Chhnghu,Shi-Yvgaa,Ximayya Xan,l'Totoxl,Wakan,Ythogtha,Ub-ji,Shuaicha,Sthuma,Senne'll,Xyngogtha";
    //"QmTWXhdXKcw6RXhKPcBhWVmj12wRLvYcgrSpT1nikmBtGv,QmfJsL7Lh2jrRqaTMxorT7qRuMuDSW7jLMb2vQuyMhHokk,QmdcDCzGVTo2VPwj1haCuPoop5SkC9BFroXU4aw9Hza67e,QmenTr74f5Hn5SkJT1NTEFWSaT49F8fi2onT146UwgdshR,QmfVgziuVbPovhQqKgW8J3DQYRieQx9PmHNSe4yUbZYT4W,QmSXxRgxn2hevEDXDw1KPMNpBrTxGAZXAbfCsXRbKQ7FNR,QmYD8wuKLojhuR7VyJTBxEwFjpTFQciLU5QmKfD1k4SeVF,QmPEgBRK6wGhCkKPwAw9j2Na86cp77fmjtMVfT5V4VYWpQ,QmWuHooTjwnDZw4CS58bUWwoSUP9PMjp3vxN3Rmkc3JDU2,QmWhZ9rYPU7S5hkGv4gXQuqMu85Z87oWK1f3hCFK2T9fbD,QmSmxeYAQsHeV5cY75ijruASZ4HpG64SskdTLVYUzBmJUm,Qmbje3tHZNXnCYz3mfzFxQ2ZzpXNYtwWRCoviLC29euWud,QmR7VG4etp7ueP1yoFw7uaZGCLckcf4qhkbTaTK5C8Wd2E,QmPRDQX7GekyKsispCZKJ4cRLxwhVBN3TbWEAqMLPZvqec,QmRwUvuDja6Ss2NNKUnBqsJhHaDMNyW6FdzzSVG77ACcaz,QmcTZRpjWd9b4FkPSR5bGwx3r5cko9jqks5H5b81rjCjLp,QmV3Pbskd7D4DPmseyojXo4E8uzm6rbiPASh6b2TpU38n4,QmWYFJDqDuDrKikgAJj45Mr5gQ37dPywK6D5giFerT3oVG,QmavyWUXwnpvgMHad2pXkALe1WHq9pJatFkqW67p7Nv5Jm,QmSwu6wHHHu8DYXZB9HXRpc2mnrAUYFQbbLHmzMgxxEKZq,QmQJitWq2HjuBsrfm5W4zzsAowe5agM2pbeDg5a43Fh2cv,QmPCGrxrJ77VRzCMpmgFszFx9Ky2FXhHrNKtv8kfBA276Y,QmeenofHLBmbPDvh6bf9pDwXXtuerGunDLYRjpurmV3qt2,QmSR9pWx9wHaD4tTyJrjGYrYkYwvBcBYieGqnhzwEJfHo1,QmXpXZWi7PQdZuYg1aBr8oDbgaVmSXY2D1rRDnjQ8Ax5zK,Qmc3DYKkQX9tXfy4c5qzc6KKKSUYu1iEwZRNkZpgXRNTsR,QmVQ1VjppWsuspouBKNB73Wk1K1U273zVAwJPuW8aEKK9N,QmSR9pWx9wHaD4tTyJrjGYrYkYwvBcBYieGqnhzwEJfHo1,Qmb3ZVTSX4bHR7WaRVeupnnnZ9wvov9HHA4zdpZVL8hcyi,QmUm6BeTkSu8brGG1ZwXENBuUihPGLX79whA9t1ZrKhjkQ,QmPcfHotn4MCtuMk5HnPSTEr2jjaonoGUZBNM9zs8Y9X9S,QmPCTkdEAsALUYQcdbmpbZrgCSMfgX9x7UsVFqtGCEn7JN,QmdUwtdf3UwZhPcWi1Qw1DPoANdPcdPZQSz95tpc8sSX5w";
    uint256 internal constant bloodlinesLength = 33;

    string internal constant abilities =
        "3'3,Shitposting,Diamond Bull Horns,Masternode,Front Running,MEV Collector,NFT Flipper,Artblocks connoisseur ,Diamond hands,Free transactions,Perma Low Gas Fees,Made it ,Flash Bundler,Private relays,Compounding,Galaxy Brain,Low IQ,High IQ";
    uint256 internal constant abilitiesLength = 18;

    string internal constant names =
        "Satoshi,Vitalik,Vlad,Adam,Ailmar,Darfin,Jhaan,Zabbas,Neldor,Gandor,Bellas,Daealla,Nym,Vesryn,Angor,Gogu,Malok,Rotnam,Chalia,Astra,Fabien,Orion,Quintus,Remus,Rorik,Sirius,Sybella,Azura,Dorath,Freya,Ophelia,Yvanna,Zeniya,James,Robert,John,Michael,William,David,Richard,Joseph,Thomas,Charles,Mary,Patricia,Jennifer,Linda,Elizabeth,Barbara,Susan,Jessica,Sarah,Karen,Dilibe,Eva,Matthew,Bolethe,Polycarp,Ambrogino,Jiri,Chukwuebuka,Chinonyelum,Mikael,Mira,Aniela,Samuel,Isak,Archibaldo,Chinyelu,Kerstin,Abigail,Olympia,Grace,Nahum,Elisabeth,Serge,Sugako,Patrick,Florus,Svatava,Ilona,Lachlan,Caspian,Filippa,Paulo,Darda,Linda,Gradasso,Carly,Jens,Betty,Ebony,Dennis,Martin Davorin,Laura,Jesper,Remy,Onyekachukwu,Jan,Dioscoro,Hilarij,Rosvita,Noah,Patrick,Mohammed,Chinwemma,Raff,Aron,Miguel,Dzemail,Gawel,Gustave,Efraim,Adelbert,Jody,Mackenzie,Victoria,Selam,Jenci,Ulrich,Chishou,Domonkos,Stanislaus,Fortinbras,George,Daniel,Annabelle,Shunichi,Bogdan,Anastazja,Marcus,Monica,Martin,Yuukou,Harriet,Geoffrey,Jonas,Dennis,Hana,Abdelhak,Ravil,Patrick,Karl,Eve,Csilla,Isabella,Radim,Thomas,Faina,Rasmus,Alma,Charles,Chad,Zefram,Hayden,Joseph,Andre,Irene,Molly,Cindy,Su,Stani,Ed,Janet,Cathy,Kyle,Zaki,Belle,Bella,Jessica,Amou,Steven,Olgu,Eva,Ivan,Vllad,Helga,Anya,John,Rita,Evan,Jason,Donald,Tyler,Changpeng,Sam";
    uint256 internal constant namesLength = 186;

    // ===== Components ====

    function creatureComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "CREATURE", creaturesLength);
    }

    function flawComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "FLAW", flawsLength);
    }

    function originComponents(uint256 tokenId, bool shadowChain)
        internal
        pure
        returns (uint256[5] memory)
    {
        if (shadowChain) return pluck(tokenId, "ORIGIN", 5);
        return pluck(tokenId, "ORIGIN", originsLength);
    }

    function bloodlineComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "BLOODLINE", bloodlinesLength);
    }

    function abilityComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "ABILITY", abilitiesLength);
    }

    function nameComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "NAME", namesLength);
    }

    // ===== Pluck Index Numbers of Raw Materials =====

    function pluck(
        uint256 tokenId,
        string memory keyPrefix,
        uint256 sourceCSVLength
    ) internal pure returns (uint256[5] memory) {
        uint256[5] memory components;

        uint256 rand = Random.random(
            string(abi.encodePacked(keyPrefix, toString(tokenId)))
        );

        components[0] = rand % sourceCSVLength;
        components[1] = 0;
        components[2] = 0;

        uint256 greatness = rand % 21;
        if (greatness > 14) {
            components[1] = (rand % suffixesLength) + 1;
        }
        if (greatness >= 19) {
            components[2] = (rand % namePrefixesLength) + 1;
            components[3] = (rand % nameSuffixesLength) + 1;
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
