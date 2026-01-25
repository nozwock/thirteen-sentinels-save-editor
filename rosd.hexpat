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
import std.limits as limits;
import type.magic;

// Guessed by repeating FFs (12 of them) from near start of the file above the 0x01 .. 0x20 bytes that I saw in diff
u64 SAVE_SIZE = 728376;
// Guessed from image starting marker and CCs near the end of image
u64 THUMBNAIL_RESERVED_SIZE = 204800;

struct JfifThumbnail {
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

struct CharacterStat {
    u32 lv; // 0 based, decides unlocked pilot skills
    u32 exp;
    $ += 0x190;
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

struct Save {
    u64 base = $;

    padding[0x29D7C];
    u32 meta_system_lv; // 0 based
    u64 battle_score;
    u64 meta_chips [[comment("Fixed-point integer; Least significant digit is used as the only decimal place")]];
    TerminalUpgrades terminal_upgrades;
    u32 mystery_points @ $ + 0xAFB70 [[comment("Clamped at 999")]];
    BattleStat battle_stat @ base + 0x377D4;
    CharacterStat char_stats[13] @ base + 0x37900;
    be JfifThumbnail thumbnail @ base + 0x6302C;
} [[static, fixed_size(SAVE_SIZE)]];

struct SaveFile {
    padding[4];
    type::Magic<"ROSD"> magic;
    padding[14 * 4];
    Save saves[10];
} [[inline]];

SaveFile save_file @ 0x00;
