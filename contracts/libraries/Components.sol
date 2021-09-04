// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./strings.sol";
import "./MetadataUtils.sol";

contract NameChanger {
    /* IERC20 internal constant agld =
        IERC20(0x32353A6C91143bfd6C7d363B546e62a9A2489A20);
    uint256 private constant NAME_CHANGE_BASE_PRICE = 420 * 10**18;
    mapping(uint256 => string) internal firstNameOverride;
    mapping(uint256 => string) internal lastNameOverride;
    mapping(uint256 => uint256) internal numNameChanges;

    function changeName(
        uint256 tokenId,
        string calldata firstName,
        string calldata lastName
    ) external nonReentrant {
        require(tokenId > 0 && tokenId < 8021, "Token ID invalid");
        require(ownerOf(tokenId) == msg.sender, "Not Name owner");

        // transfer AGLD to owner
        agld.transferFrom(msg.sender, owner(), nameChangePrice(tokenId));

        // override name
        firstNameOverride[tokenId] = firstName;
        lastNameOverride[tokenId] = lastName;
        numNameChanges[tokenId] += 1;
    } */
}

contract Components {
    using strings for string;
    using strings for strings.slice;

    string[] internal suffixes = [
        // <no suffix>          // 0
        "of Power", // 1
        "of Giants", // 2
        "of Titans", // 3
        "of Skill", // 4
        "of Perfection", // 5
        "of Brilliance", // 6
        "of Enlightenment", // 7
        "of Protection", // 8
        "of Anger", // 9
        "of Rage", // 10
        "of Fury", // 11
        "of Vitriol", // 12
        "of the Fox", // 13
        "of Detection", // 14
        "of Reflection", // 15
        "of the Twins" // 16
    ];
    uint256 constant suffixesLength = 16;

    string[] internal namePrefixes = [
        // <no name>            // 0
        "Agony", // 1
        "Apocalypse", // 2
        "Armageddon", // 3
        "Beast", // 4
        "Behemoth", // 5
        "Blight", // 6
        "Blood", // 7
        "Bramble", // 8
        "Brimstone", // 9
        "Brood", // 10
        "Carrion", // 11
        "Cataclysm", // 12
        "Chimeric", // 13
        "Corpse", // 14
        "Corruption", // 15
        "Damnation", // 16
        "Death", // 17
        "Demon", // 18
        "Dire", // 19
        "Dragon", // 20
        "Dread", // 21
        "Doom", // 22
        "Dusk", // 23
        "Eagle", // 24
        "Empyrean", // 25
        "Fate", // 26
        "Foe", // 27
        "Gale", // 28
        "Ghoul", // 29
        "Gloom", // 30
        "Glyph", // 31
        "Golem", // 32
        "Grim", // 33
        "Hate", // 34
        "Havoc", // 35
        "Honour", // 36
        "Horror", // 37
        "Hypnotic", // 38
        "Kraken", // 39
        "Loath", // 40
        "Maelstrom", // 41
        "Mind", // 42
        "Miracle", // 43
        "Morbid", // 44
        "Oblivion", // 45
        "Onslaught", // 46
        "Pain", // 47
        "Pandemonium", // 48
        "Phoenix", // 49
        "Plague", // 50
        "Rage", // 51
        "Rapture", // 52
        "Rune", // 53
        "Skull", // 54
        "Sol", // 55
        "Soul", // 56
        "Sorrow", // 57
        "Spirit", // 58
        "Storm", // 59
        "Tempest", // 60
        "Torment", // 61
        "Vengeance", // 62
        "Victory", // 63
        "Viper", // 64
        "Vortex", // 65
        "Woe", // 66
        "Wrath", // 67
        "Light's", // 68
        "Shimmering" // 69
    ];
    uint256 constant namePrefixesLength = 69;

    string[] internal nameSuffixes = [
        // <no name>            // 0
        "Bane", // 1
        "Root", // 2
        "Bite", // 3
        "Song", // 4
        "Roar", // 5
        "Grasp", // 6
        "Instrument", // 7
        "Glow", // 8
        "Bender", // 9
        "Shadow", // 10
        "Whisper", // 11
        "Shout", // 12
        "Growl", // 13
        "Tear", // 14
        "Peak", // 15
        "Form", // 16
        "Sun", // 17
        "Moon" // 18
    ];
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

    string internal constant stats =
        "Satoshi,Vitalik,Vlad,Adam,Ailmar,Darfin,Jhaan,Zabbas,Neldor,Gandor,Bellas,Daealla,Nym,Vesryn,Angor,Gogu,Malok,Rotnam,Chalia,Astra,Fabien,Orion,Quintus,Remus,Rorik,Sirius,Sybella,Azura,Dorath,Freya,Ophelia,Yvanna,Zeniya,James,Robert,John,Michael,William,David,Richard,Joseph,Thomas,Charles,Mary,Patricia,Jennifer,Linda,Elizabeth,Barbara,Susan,Jessica,Sarah,Karen,Dilibe,Eva,Matthew,Bolethe,Polycarp,Ambrogino,Jiri,Chukwuebuka,Chinonyelum,Mikael,Mira,Aniela,Samuel,Isak,Archibaldo,Chinyelu,Kerstin,Abigail,Olympia,Grace,Nahum,Elisabeth,Serge,Sugako,Patrick,Florus,Svatava,Ilona,Lachlan,Caspian,Filippa,Paulo,Darda,Linda,Gradasso,Carly,Jens,Betty,Ebony,Dennis,Martin Davorin,Laura,Jesper,Remy,Onyekachukwu,Jan,Dioscoro,Hilarij,Rosvita,Noah,Patrick,Mohammed,Chinwemma,Raff,Aron,Miguel,Dzemail,Gawel,Gustave,Efraim,Adelbert,Jody,Mackenzie,Victoria,Selam,Jenci,Ulrich,Chishou,Domonkos,Stanislaus,Fortinbras,George,Daniel,Annabelle,Shunichi,Bogdan,Anastazja,Marcus,Monica,Martin,Yuukou,Harriet,Geoffrey,Jonas,Dennis,Hana,Abdelhak,Ravil,Patrick,Karl,Eve,Csilla,Isabella,Radim,Thomas,Faina,Rasmus,Alma,Charles,Chad,Zefram,Hayden,Joseph,Andre,Irene,Molly,Cindy,Su,Stani,Ed,Janet,Cathy,Kyle,Zaki,Belle,Bella,Jessica,Amou,Steven,Olgu,Eva,Ivan,Vllad,Helga,Anya,John,Rita,Evan,Jason,Donald,Tyler,Changpeng,Sam";
    uint256 internal constant statsLength = 186;

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

    function statComponent(uint256 tokenId, string memory keyPrefix)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, keyPrefix, stats, statsLength, false);
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

    /* function pluck(
        uint256 tokenId,
        string memory keyPrefix,
        string memory sourceCSV,
        uint256 sourceCSVLength,
        bool rareTrait
    ) internal pure returns (string memory) {
        uint256 rand = random(
            string(abi.encodePacked(keyPrefix, toString(tokenId)))
        );
        if (!rareTrait || shouldGib(tokenId, keyPrefix)) {
            return getItemFromCSV(sourceCSV, rand % sourceCSVLength);
        } else {
            return "";
        }
    } */

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
}
