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
        "Master,Right Honourable,Senator,President,Generalissimo,His Majesty,Her Majesty,His Grace,Her Grace,Lord,Archbishop,Bishop,Council,Emperor,Empress,Caesar,Chieftain,Chief Ape,Couch,Pope,King,Queen,Dr.,Ser,Prophet,Professor,Marshal,Private,Comrade,Fren,Druid,Imperator,Doge,Archon,Lord Protector,Archduke,Duke,Earl,Count,Baron,Basileus,Khan,Earth-Shaker,Mayor,Viceroy,Tribune,Chad,Cringe,Based,0x,Mohandas,Arch-ape,General Financier,DAO Dictator,Benevolent Dictator,Secretary of the Treasury,Khal,Khaleesi,Sultan";
    uint256 internal constant creaturesLength = 59;

    string internal constant flaws =
        "Satoshi,Vitalik,Vlad,Adam,Ailmar,Darfin,Jhaan,Zabbas,Neldor,Gandor,Bellas,Daealla,Nym,Vesryn,Angor,Gogu,Malok,Rotnam,Chalia,Astra,Fabien,Orion,Quintus,Remus,Rorik,Sirius,Sybella,Azura,Dorath,Freya,Ophelia,Yvanna,Zeniya,James,Robert,John,Michael,William,David,Richard,Joseph,Thomas,Charles,Mary,Patricia,Jennifer,Linda,Elizabeth,Barbara,Susan,Jessica,Sarah,Karen,Dilibe,Eva,Matthew,Bolethe,Polycarp,Ambrogino,Jiri,Chukwuebuka,Chinonyelum,Mikael,Mira,Aniela,Samuel,Isak,Archibaldo,Chinyelu,Kerstin,Abigail,Olympia,Grace,Nahum,Elisabeth,Serge,Sugako,Patrick,Florus,Svatava,Ilona,Lachlan,Caspian,Filippa,Paulo,Darda,Linda,Gradasso,Carly,Jens,Betty,Ebony,Dennis,Martin Davorin,Laura,Jesper,Remy,Onyekachukwu,Jan,Dioscoro,Hilarij,Rosvita,Noah,Patrick,Mohammed,Chinwemma,Raff,Aron,Miguel,Dzemail,Gawel,Gustave,Efraim,Adelbert,Jody,Mackenzie,Victoria,Selam,Jenci,Ulrich,Chishou,Domonkos,Stanislaus,Fortinbras,George,Daniel,Annabelle,Shunichi,Bogdan,Anastazja,Marcus,Monica,Martin,Yuukou,Harriet,Geoffrey,Jonas,Dennis,Hana,Abdelhak,Ravil,Patrick,Karl,Eve,Csilla,Isabella,Radim,Thomas,Faina,Rasmus,Alma,Charles,Chad,Zefram,Hayden,Joseph,Andre,Irene,Molly,Cindy,Su,Stani,Ed,Janet,Cathy,Kyle,Zaki,Belle,Bella,Jessica,Amou,Steven,Olgu,Eva,Ivan,Vllad,Helga,Anya,John,Rita,Evan,Jason,Donald,Tyler,Changpeng,Sam";
    uint256 internal constant flawsLength = 186;

    string internal constant birthplaces =
        "von,de la,chadde,mise,of,da,from,in,first of,sixth of,t11s,hi tuba,vibes,mons,zef,state,sump,sunarto,jai,mewny,amogsus,light,groovy,formerly";
    uint256 internal constant birthplacesLength = 24;

    string internal constant bloodlines =
        "Nakamoto,Buterin,Zamfir,Mintz,Ashbluff,Marblemaw,Bozzelli,Fellowes,Windward,Yarrow,Yearwood,Wixx,Humblecut,Dustfinger,Biddercombe,Kicklighter,Vespertine,October,Gannon,Collymore,Stoll,Adler,Huxley,Ledger,Hayes,Ford,Finnegan,Beckett,Zimmerman,Crassus,Hendrix,Lennon,Thatcher,St. James,Cromwell,Monroe,West,Langley,Cassidy,Lopez,Jenkins,Udobata,Valova,Gresham,Frederiksen,Vasiliev,Mancini,Danicek,Okwuoma,Chibugo,Broberg,Strozak,Borkowska,Araujo,Geisler,Hidalgo,Ibekwe,Schmidt,Leehy,Rodrigue,Hines,Izmaylov,Egede,Pinette,Hakugi,McLellan,Mailhot,Lelkova,Simon,Tjangamarra,Sandgreen,Nystrom,Kjeldsen,Goncalves,Sos,Hornblower,Pelletier,Donaldson,Jackson,Rojo,Ermakov,Stornik,Lothran,Gousse,Henrichon,Onwuka,Horak,Elizondo,Mikulanc,Skotnik,Berg,Nilsson,Berg,Enyinnaya,Hermanns,Holmberg,Oliveira,Kufersin,Kwiatkowski,Courtois,Piest,Sandheaver,Woods,Ives,Dias,Grizelj,Viragh,Blau,Kodou,Torma,Sorokina,Took-Took,Allen,Melo,Bunker,Kiyomizu,Donkervoort,Maciejewska,Steffensen,Solomina,Zidek,Gotou,Bryant,Quenneville,Karlsen,Thomsen,Havlikova,Feron,Bazhenov,Amsel,Enoksen,Schneider,Kiss,Woodd,Benes,Probst,Aliyeva,Fleischer,Plain,Hoskinson,Chad,Maki,Gandhi,Zhao,Wintermute,Cronje,Felten,Yellen,Wood,Zhu,Davis,K,Delphine,Thorne,Kulechov,Nigiri,Goldfeder,Ranth,Galt,Lincoln,Trump";
    uint256 internal constant bloodlinesLength = 161;

    string internal constant eyes =
        "the Great,Jr.,Sr.,the Ape,the Magnificent,the Impaler,the Able,the Ambitious,the Astrologer,the Bad,the Bastard,the Black,the Blessed,the Bloody,the Conqueror,the Cruel,the Damned,Dracula,the Drunkard,the Elder,the Eloquent,the Enlightened,the Fair,the Farmer,the Fat,the Fearless,the Fighter,the Comfy,the Couch,the Fortunate,the Generous,the Gentle,the Glorious,the Good,the God-Given,the Grim,the Handsome,the Hammer,Hadrada,the Hidden,the Holy,the Hunter,the Illustrious,the Invincible,the Iron,the Just,the Kind,the Lame,the Last,the Lawgiver,the Learned,the Liberator,the Lion,the Mad,the Magnanimous,the Mighty,the Monk,the Mild,the Musician,the Navigator,the Nobel,the Old,the One-Eyed,the Outlaw,the Pale,the Peaceful,the Philosopher,the Pilgrim,the Pious,the Poet,the Proud,the Quiet,the Rash,the Red,the Reformer,the Saint,the Savior,the Seer,the Short,the Silent,the Simple,the Sorcerer,the Strong,the Tall,the Terrible,the Thunderbolt,the Trembling,the Tyrant,the Unlucky,the Unready,the Vain,the Virgin,the Warrior,the Weak,the White,the Wicked,the Wise,the Young,the Cuck,the Chad,the NoCoiner,.eth,da gay,the Prophet,the Paper-Handed";
    uint256 internal constant eyesLength = 105;

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

    function birthplaceComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return
            pluck(tokenId, "BIRTHPLACE", birthplaces, birthplacesLength, true);
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
}
