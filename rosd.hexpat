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

struct Save {
    u32 meta_chips @ $ + 0x29D88 [[comment("Value is multiplied by 10")]];
    be JfifThumbnail thumbnail @ $ + 0x6302C;
} [[static, fixed_size(SAVE_SIZE)]];

struct SaveFile {
    padding[4];
    type::Magic<"ROSD"> magic;
    padding[14 * 4];
    Save saves[10];
} [[inline]];

SaveFile save_file @ 0x00;