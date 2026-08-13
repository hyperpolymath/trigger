// telegram/mod.zig - Telegram module for unified-hexadeca-api
//
// This module exports the Telegram API bindings for use in Trigger.
//
// Original concept by 2nixx (T.me/NetworkCriminals)
// Module design by hyperpolymath

pub const telegram = @import("telegram.zig");

pub fn init(allocator: std.mem.Allocator, api_id: i32, api_hash: []const u8, session_name: []const u8) !telegram.TelegramClient {
    return telegram.TelegramClient.init(allocator, api_id, api_hash, session_name);
}
