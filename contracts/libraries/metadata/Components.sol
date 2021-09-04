// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../strings.sol";
import "../MetadataUtils.sol";

library Components {
    using strings for string;
    using strings for strings.slice;

    string internal constant suffixes =
        "of Power,of Giants,of Titans,of Skill,of Perfection,of Brilliance,of Enlightenment,of Protection,of Anger,of Rage,of Fury,of Vitriol,of the Fox,of Detection,of Reflection,of the Twins";
    uint256 constant suffixesLength = 16;

    string internal constant namePrefixes =
        "Agony,Apocalypse,Armageddon,Beast,Behemoth,Blight,Blood,Bramble,Brimstone,Brood,Carrion,Cataclysm,Chimeric,Corpse,Corruption,Damnation,Death,Demon,Dire,Dragon,Dread,Doom,Dusk,Eagle,Empyrean,Fate,Foe,Gale,Ghoul,Gloom,Glyph,Golem,Grim,Hate,Havoc,Honour,Horror,Hypnotic,Kraken,Loath,Maelstrom,Mind,Miracle,Morbid,Oblivion,Onslaught,Pain,Pandemonium,Phoenix,Plague,Rage,Rapture,Rune,Skull,Sol,Soul,Sorrow,Spirit,Storm,Tempest,Torment,Vengeance,Victory,Viper,Vortex,Woe,Wrath,Light's,Shimmering";
    uint256 constant namePrefixesLength = 69;

    string internal constant nameSuffixes =
        "Bane,Root,Bite,Song,Roar,Grasp,Instrument,Glow,Bender,Shadow,Whisper,Shout,Growl,Tear,Peak,Form,Sun,Moon";
    uint256 constant nameSuffixesLength = 18;

    string internal constant creatures =
        "Dragon,Manticore,Dire Wolf,Kraken,Giant,Unicorn,Griffin,Pegasus,Chimera,Yeti,Kappa,Hellhound,Demon,Werewolf,Rat King,White Stag,Minotaur,Giant Primate";
    uint256 internal constant creaturesLength = 18;

    string internal constant flaws =
        "Missing Eye,Missing Tooth,Dragon Scar,Missing Ear,Eye Scar,Face Scar,Body Scar,Missing Tail,Burnt Arm,Broken Claw,Missing Claw,Burnt Face,Neck Scar,Divine Markings,Burnt Body";
    uint256 internal constant flawsLength = 15;

    string internal constant origins =
        "Shadowchain,Chainspace,Genesis Cube,Mempool";
    uint256 internal constant originsLength = 4;

    string internal constant bloodlines =
        "Genesis,The Judge of Cogito,Jqzl wn Xzwuqam,The Amalgam,The Devourer of Worlds";
    uint256 internal constant bloodlinesLength = 5;

    string internal constant eyes =
        "Gold Eyes,Blue Eyes,Violet Eyes,Red Eyes,Green Eyes";
    uint256 internal constant eyesLength = 5;

    string internal constant names =
        "Satoshi,Vitalik,Vlad,Adam,Ailmar,Darfin,Jhaan,Zabbas,Neldor,Gandor,Bellas,Daealla,Nym,Vesryn,Angor,Gogu,Malok,Rotnam,Chalia,Astra,Fabien,Orion,Quintus,Remus,Rorik,Sirius,Sybella,Azura,Dorath,Freya,Ophelia,Yvanna,Zeniya,James,Robert,John,Michael,William,David,Richard,Joseph,Thomas,Charles,Mary,Patricia,Jennifer,Linda,Elizabeth,Barbara,Susan,Jessica,Sarah,Karen,Dilibe,Eva,Matthew,Bolethe,Polycarp,Ambrogino,Jiri,Chukwuebuka,Chinonyelum,Mikael,Mira,Aniela,Samuel,Isak,Archibaldo,Chinyelu,Kerstin,Abigail,Olympia,Grace,Nahum,Elisabeth,Serge,Sugako,Patrick,Florus,Svatava,Ilona,Lachlan,Caspian,Filippa,Paulo,Darda,Linda,Gradasso,Carly,Jens,Betty,Ebony,Dennis,Martin Davorin,Laura,Jesper,Remy,Onyekachukwu,Jan,Dioscoro,Hilarij,Rosvita,Noah,Patrick,Mohammed,Chinwemma,Raff,Aron,Miguel,Dzemail,Gawel,Gustave,Efraim,Adelbert,Jody,Mackenzie,Victoria,Selam,Jenci,Ulrich,Chishou,Domonkos,Stanislaus,Fortinbras,George,Daniel,Annabelle,Shunichi,Bogdan,Anastazja,Marcus,Monica,Martin,Yuukou,Harriet,Geoffrey,Jonas,Dennis,Hana,Abdelhak,Ravil,Patrick,Karl,Eve,Csilla,Isabella,Radim,Thomas,Faina,Rasmus,Alma,Charles,Chad,Zefram,Hayden,Joseph,Andre,Irene,Molly,Cindy,Su,Stani,Ed,Janet,Cathy,Kyle,Zaki,Belle,Bella,Jessica,Amou,Steven,Olgu,Eva,Ivan,Vllad,Helga,Anya,John,Rita,Evan,Jason,Donald,Tyler,Changpeng,Sam";
    uint256 internal constant namesLength = 186;

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function creatureComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "CREATURE", creatures, creaturesLength, true);
    }

    function flawComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "FLAW", flaws, flawsLength, true);
    }

    function originComponents(uint256 tokenId, bool shadowChain)
        internal
        pure
        returns (uint256[5] memory)
    {
        if (shadowChain)
            return pluck(tokenId, "ORIGIN", "Shadowchain", 1, false);
        return pluck(tokenId, "ORIGIN", origins, originsLength, false);
    }

    function bloodlineComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "BLOODLINE", bloodlines, bloodlinesLength, true);
    }

    function eyeComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "EYES", eyes, eyesLength, true);
    }

    function nameComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "NAME", names, namesLength, true);
    }

    function pluck(
        uint256 tokenId,
        string memory keyPrefix,
        string memory sourceCSV,
        uint256 sourceCSVLength,
        bool rareTrait
    ) internal pure returns (uint256[5] memory) {
        uint256[5] memory components;

        uint256 rand = random(
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

    function shouldGib(uint256 tokenId, string memory keyPrefix)
        internal
        pure
        returns (bool)
    {
        uint256 rand = random(
            string(abi.encodePacked("SHOULD_GIB", keyPrefix, toString(tokenId)))
        );
        uint256 greatness = rand % 21;
        return (greatness >= 19);
    }

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
