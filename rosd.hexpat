#pragma description 13 Sentinels ROBO13 Save Data

// Pattern file for ImHex
// https://github.com/WerWolv/ImHex
// https://docs.werwolv.net/pattern-language/

// For auto-loading, place or symlink the file under:
// `%appdata%/../Local/imhex/patterns/` or `~/.config/imhex/patterns/`

// ROSD
#pragma magic [ 52 4F 53 44 ] @ 0x04
#pragma endian little

import std.io;
import std.core;
import std.array;
import std.limits as limits;
import type.magic;

// Guessed by repeating FFs (12 of them) from near start of the file above the 0x01 .. 0x20 bytes that I saw in diff
u64 SAVE_SIZE = 728376;
// Guessed from image starting marker and CCs near the end of image
u64 THUMBNAIL_RESERVED_SIZE = 204800;

struct JpegThumbnail {
    u16 soi_marker;
    u16 app0_marker;
    u16 length;
    char magic[5]; // JFIF\x00
    // and so on... until EOI marker 0xFFD9
} [[sealed, fixed_size(THUMBNAIL_RESERVED_SIZE)]];

struct TerminalUpgrades { // unlocked=0?, locked=ff
    u8 meta_system_lv[9] [[sealed]];
    padding[1];
    u8 score_multiplier[5] [[sealed]];
    u8 score_multiplier_extra[4] [[sealed]];
    u8 chips_multiplier[5] [[sealed]];
    u8 chips_multiplier_extra[4] [[sealed]];
    u8 meta_skill_use[3] [[sealed]];
    u8 terminal_recovery;
    u8 heal_team_hp;
    u8 heal_team_ep;
    u8 instant_team_cooldown;
    u8 team_barrier;
    u8 team_accelerate;
    u8 power_boost;
    u8 durability_boost;
    u8 gravity;
    u8 deploy_type_98_bipeds;
    u8 score_boost[5] [[sealed]];
} [[static]];

// Character order for stats
enum CharacterByStat : u8 {
    NenjiOgata,
    TakatoshiHijiyama,
    JuroKurabe,
    RyokoShinonome,
    IoriFuyusaka,
    TomiKisaragi,
    NatsunoMinami,
    KeitaroMiura,
    ShuAmiguchi,
    YukiTakamiya,
    RenyaGouto,
    EiSekigahara,
    MegumiYakusiji,
};

// Character order for sentinel armament unlocks/upgrades
enum CharacterByArms : u8 {
    NenjiOgata,
    TakatoshiHijiyama,
    EiSekigahara,
    JuroKurabe,
    IoriFuyusaka,
    RyokoShinonome,
    NatsunoMinami,
    TomiKisaragi,
    KeitaroMiura,
    MegumiYakusiji,
    RenyaGouto,
    YukiTakamiya,
    ShuAmiguchi,
};

struct SentinelArmUpgrades {
    // Some slots aren't in use
    // unlocked=0?
    std::Array<std::Array<u8, 16>, 13> char_base_arms;
    padding[16 * 4];
    std::Array<std::Array<u8, 2>, 13> char_alt_arms;
} [[static]];

enum SentinelUpgrade : u8 {
    Armor,
    Generator,
    FireControl,
    Actuator,
    Neurolink
};

struct SentinelUpgrades {
    u32 upgrade_lv[5];
    padding[3 * 4];
    u32 chips[5] [[comment("Invested meta-chips")]];
    padding[3 * 4];
    u32 chips_max[5] [[comment("meta-chips needed for next upgrade")]];
    padding[3 * 4];
} [[static]];

struct CharacterStat {
    u32 lv; // 0 based, decides unlocked pilot skills
    u32 exp;
    padding[0x124];
    SentinelUpgrades sentinel_upgrades;
    padding[3 * 4];
} [[static]];

struct CharacterBattleStat {
    u32 brain_overload; // u32_max if max out of max left, else specific amount left
    u32 hp;
    u32 ep;
    u32 status; // e.g. Standby FFs, Ready 00s
} [[static]];

struct BattleStat {
    u32 win_streak;
    CharacterBattleStat char_battle_stats[13]; // There seems to be reserved space for 3 more?
} [[static]];

struct Settings {
    u32 auto_advance_wait; // u32 ones are slider steps
    u32 bgm_volume;
    u32 se_volume;
    u32 voice_volume;
    bool auto_advance;
    bool dialouge_type;
    bool thought_cloud_controls;
    bool directional_buttons;
    bool stop_on_unread;
    bool;
    bool auto_save;
    bool character_intro;
    u32 camera_zoom_speed;
    u32 maximum_zoom_out;
    u32 maximum_zoom_in;
    bool;
    bool audio_language;
    bool subtitle_display;
    bool;
    u32;
} [[static]];

struct DateTime {
    u16 year;
    u8 month;
    u8 day;
    u8 hour;
    u8 minute;
    u8 second;
    padding[1];
} [[static, format("datetime_format")]];

fn datetime_format(DateTime datetime) {
    return std::format(
        "{}/{}/{} {:02}:{:02}:{:02}",
        datetime.year,
        datetime.month,
        datetime.day,
        datetime.hour,
        datetime.minute,
        datetime.second
    );
};

fn game_ticks_format(u32 ticks) {
    u32 seconds = ticks / 60;
    u8 hour =  seconds / 3600;
    u8 minute = (seconds % 3600) / 60;
    u8 second = seconds % 60;

    return std::format(
        "{:02}:{:02}:{:02}",
        hour,
        minute,
        second
    );
};

fn bit_entry_name(u32 index, u32 offset, str prefix = "") {
    return std::format("{}No. {}", prefix, index * 8 + offset);
};

bitfield ArchiveBitEntry {
    bool b0 : 1 [[name(bit_entry_name(std::core::array_index(), 0, "Archive "))]];
    bool b1 : 1 [[name(bit_entry_name(std::core::array_index(), 1, "Archive "))]];
    bool b2 : 1 [[name(bit_entry_name(std::core::array_index(), 2, "Archive "))]];
    bool b3 : 1 [[name(bit_entry_name(std::core::array_index(), 3, "Archive "))]];
    bool b4 : 1 [[name(bit_entry_name(std::core::array_index(), 4, "Archive "))]];
    bool b5 : 1 [[name(bit_entry_name(std::core::array_index(), 5, "Archive "))]];
    bool b6 : 1 [[name(bit_entry_name(std::core::array_index(), 6, "Archive "))]];
    bool b7 : 1 [[name(bit_entry_name(std::core::array_index(), 7, "Archive "))]];
} [[color("a6262a" /* red */)]];

bitfield MysteryBitEntry {
    bool b0 : 1 [[name(bit_entry_name(std::core::array_index(), 0, "File "))]];
    bool b1 : 1 [[name(bit_entry_name(std::core::array_index(), 1, "File "))]];
    bool b2 : 1 [[name(bit_entry_name(std::core::array_index(), 2, "File "))]];
    bool b3 : 1 [[name(bit_entry_name(std::core::array_index(), 3, "File "))]];
    bool b4 : 1 [[name(bit_entry_name(std::core::array_index(), 4, "File "))]];
    bool b5 : 1 [[name(bit_entry_name(std::core::array_index(), 5, "File "))]];
    bool b6 : 1 [[name(bit_entry_name(std::core::array_index(), 6, "File "))]];
    bool b7 : 1 [[name(bit_entry_name(std::core::array_index(), 7, "File "))]];
} [[color("1e618f" /* blue */)]];

enum GameMode : u32 {
    Remembrance = 1,
    Menu = 2,
    Destruction = 3,
};

struct Save {
    u64 base = $;

    GameMode game_mode @ base + 0x1AAC;

    DateTime save_time @ base + 0x42B0;
    u32 playtime_ticks @ base + 0x42B8 [[format("game_ticks_format")]];

    padding[0x29D7C];
    u32 meta_system_lv; // 0 based
    u64 battle_score;
    u64 meta_chips [[comment("Fixed-point integer; Least significant digit is used as the only decimal place")]];
    TerminalUpgrades terminal_upgrades;
    padding[8 * 3];
    SentinelArmUpgrades sentinel_arms;
    u32 mystery_points @ base + 0xAFB70 [[comment("Clamped at 999")]];
    BattleStat battle_stat @ base + 0x377D4;
    CharacterStat char_stats[13] @ base + 0x37900;
    Settings settings @ base + 0x39280;
    be JpegThumbnail thumbnail @ base + 0x6302C;
    u8 viewed_mystery_file_entries[80] @ base + 0xB0570 [[sealed]]; // Bit array, ends at ??
    ArchiveBitEntry viewed_event_archives[40] @ base + 0xB1728; // Total 315 entries in-game
    MysteryBitEntry unlocked_mystery_files[32] @ base + 0xB1768; // Total 250 entries in-game
} [[static, fixed_size(SAVE_SIZE)]];

struct SaveFile {
    padding[4];
    type::Magic<"ROSD"> magic;
    padding[14 * 4];
    Save saves[10];
} [[inline]];

SaveFile save_file @ 0x00;
