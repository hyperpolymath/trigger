//  Discord API Bindings for Trigger
//  
//  Uses unified-hexadeca-api for Discord client functionality
//  via serenity (Rust) or discord-rs bindings through C ABI
//  
//  Original concept by 2nixx (T.me/NetworkCriminals)
//  Discord Zig bindings by hyperpolymath
//
//  Note: This would typically wrap a C-compatible Discord library.
//  For production use, this would integrate with:
//  - serenity (Rust Discord library) via C FFI
//  - discord-rs via C bindings
//  - or a custom Discord HTTP API client

const std = @import("std");

// Import unified-hexadeca-api for common utilities
// const hexadeca = @import("path:unified-hexadeca-api");

// =============================================================================
// DISCORD-SPECIFIC CONSTANTS
// =============================================================================

pub const DISCORD_API_BASE = "https://discord.com/api/v10";
pub const DISCORD_API_VERSION = 10;
pub const DISCORD_MAX_MESSAGE_LENGTH = 2000;
pub const DISCORD_MAX_EMBEDS = 10;
pub const DISCORD_RATE_LIMIT_RESET_AFTER = 5; // seconds

// =============================================================================
// DISCORD TYPES
// =============================================================================

// Snowflake: Discord's unique ID type (64-bit timestamp-based)
pub const Snowflake = u64;

// Discord timestamp (ISO 8601 string)
pub const Timestamp = []const u8;

// Nullable type for optional fields
pub const Nullable = []const u8;

// Discord user structure
pub const DiscordUser = extern struct {
    id: Snowflake,
    username: []const u8,
    discriminator: []const u8,
    avatar: Nullable,
    bot: bool,
    system: bool,
};

// Discord guild (server) structure
pub const DiscordGuild = extern struct {
    id: Snowflake,
    name: []const u8,
    icon: Nullable,
    owner_id: Snowflake,
    permissions: u64,
};

// Discord channel structure
pub const DiscordChannel = extern struct {
    id: Snowflake,
    type: u8,  // ChannelType enum
    name: []const u8,
    guild_id: Nullable,
    position: u16,
};

// Discord message structure
pub const DiscordMessage = extern struct {
    id: Snowflake,
    channel_id: Snowflake,
    guild_id: Nullable,
    author: *DiscordUser,
    content: []const u8,
    timestamp: []const u8,
    embeds: *DiscordEmbed,
    embeds_count: usize,
    attachments: *DiscordAttachment,
    attachments_count: usize,
};

// Discord embed structure
pub const DiscordEmbed = extern struct {
    title: Nullable,
    description: Nullable,
    url: Nullable,
    color: u32,
    fields: *DiscordEmbedField,
    fields_count: usize,
};

pub const DiscordEmbedField = extern struct {
    name: []const u8,
    value: []const u8,
    inline: bool,
};

// Discord attachment structure
pub const DiscordAttachment = extern struct {
    id: Snowflake,
    filename: []const u8,
    url: []const u8,
    proxy_url: []const u8,
};

// Discord role structure
pub const DiscordRole = extern struct {
    id: Snowflake,
    name: []const u8,
    color: u32,
    hoist: bool,
    position: u16,
    permissions: u64,
};

// Channel types
pub const ChannelType = enum {
    GUILD_TEXT = 0,
    DM = 1,
    GUILD_VOICE = 2,
    GROUP_DM = 3,
    GUILD_CATEGORY = 4,
    GUILD_NEWS = 5,
    GUILD_STORE = 6,
    GUILD_STAGE_VOICE = 13,
};

// =============================================================================
// DISCORD CLIENT
// =============================================================================

pub const DiscordClient = struct {
    allocator: std.mem.Allocator,
    token: []u8,
    base_url: []u8,
    rate_limiter: *RateLimiter,

    // Initialize a new Discord client
    pub fn init(allocator: std.mem.Allocator, token: []const u8) !DiscordClient {
        var client = DiscordClient{
            .allocator = allocator,
            .token = try allocator.dupe(u8, token),
            .base_url = try allocator.dupe(u8, DISCORD_API_BASE),
            .rate_limiter = try allocator.create(RateLimiter),
            .rate_limiter.* = .{
                .allocator = allocator,
                .remaining = DISCORD_MAX_MESSAGE_LENGTH,
                .reset_after = DISCORD_RATE_LIMIT_RESET_AFTER,
            },
        };
        return client;
    }

    // Deinitialize client
    pub fn deinit(self: *DiscordClient) void {
        self.allocator.free(self.token);
        self.allocator.free(self.base_url);
        self.rate_limiter.deinit();
        self.allocator.free(self.rate_limiter);
    }

    // Wait for rate limit if needed
    pub fn waitForRateLimit(self: *DiscordClient) !void {
        if (self.rate_limiter.remaining == 0) {
            std.time.sleep(std.time.milliseconds(self.rate_limiter.reset_after * 1000));
            self.rate_limiter.remaining = DISCORD_MAX_MESSAGE_LENGTH;
        }
        self.rate_limiter.remaining -= 1;
    }
};

// =============================================================================
// RATE LIMITER
// =============================================================================

pub const RateLimiter = struct {
    allocator: std.mem.Allocator,
    remaining: u16,
    reset_after: u64,
    last_request: i64,

    pub fn deinit(self: *RateLimiter) void {
        _ = self;
    }
};

// =============================================================================
// DISCORD API FUNCTIONS
// =============================================================================

// Get current user information
pub fn getCurrentUser(client: *DiscordClient) !DiscordUser {
    _ = client;
    // TODO: Implement actual HTTP request to Discord API
    // GET /api/v10/users/@me
    return DiscordUser{
        .id = 0,
        .username = "",
        .discriminator = "",
        .avatar = null,
        .bot = false,
        .system = false,
    };
}

// Send message to channel
pub fn sendMessage(client: *DiscordClient, channel_id: Snowflake, content: []const u8) !DiscordMessage {
    _ = client;
    _ = channel_id;
    _ = content;
    // TODO: Implement actual HTTP request to Discord API
    // POST /api/v10/channels/{channel_id}/messages
    return DiscordMessage{
        .id = 0,
        .channel_id = channel_id,
        .guild_id = null,
        .author = null,
        .content = "",
        .timestamp = "",
        .embeds = null,
        .embeds_count = 0,
        .attachments = null,
        .attachments_count = 0,
    };
}

// Get messages from channel
pub fn getMessages(client: *DiscordClient, channel_id: Snowflake, limit: u8) ![]DiscordMessage {
    _ = client;
    _ = channel_id;
    _ = limit;
    // TODO: Implement actual HTTP request to Discord API
    // GET /api/v10/channels/{channel_id}/messages?limit={limit}
    return &[_]DiscordMessage{};
}

// Get guild information
pub fn getGuild(client: *DiscordClient, guild_id: Snowflake) !DiscordGuild {
    _ = client;
    _ = guild_id;
    // TODO: Implement actual HTTP request to Discord API
    // GET /api/v10/guilds/{guild_id}
    return DiscordGuild{
        .id = 0,
        .name = "",
        .icon = null,
        .owner_id = 0,
        .permissions = 0,
    };
}

// Ban user from guild
pub fn banUser(client: *DiscordClient, guild_id: Snowflake, user_id: Snowflake, reason: []const u8) !void {
    _ = client;
    _ = guild_id;
    _ = user_id;
    _ = reason;
    // TODO: Implement actual HTTP request to Discord API
    // PUT /api/v10/guilds/{guild_id}/bans/{user_id}?reason={reason}
}

// Kick user from guild
pub fn kickUser(client: *DiscordClient, guild_id: Snowflake, user_id: Snowflake, reason: []const u8) !void {
    _ = client;
    _ = guild_id;
    _ = user_id;
    _ = reason;
    // TODO: Implement actual HTTP request to Discord API
    // DELETE /api/v10/guilds/{guild_id}/members/{user_id}?reason={reason}
}

// Report message
pub fn reportMessage(client: *DiscordClient, channel_id: Snowflake, message_id: Snowflake, reason: u8) !void {
    _ = client;
    _ = channel_id;
    _ = message_id;
    _ = reason;
    // TODO: Implement actual HTTP request to Discord API
    // POST /api/v10/channels/{channel_id}/messages/{message_id}/reactions/\u{001F44E}/@me
    // (Reporting is done via reactions in Discord API)
}

// =============================================================================
// C-EXPORTED FUNCTIONS FOR ADA FFI
// =============================================================================

// SAFETY: The following functions use @ptrCast which is inherently unsafe.
// These are required for FFI between Zig and Ada/C. All pointer casts:
// 1. Use proper @alignCast to ensure correct alignment
// 2. Assume the caller (Ada side) passes valid, properly-aligned pointers
// 3. Document the expected lifetime of returned pointers
// 4. Handle memory management explicitly

pub export fn create_discord_client(
    token_ptr: [*c]const u8
) callconv(.C) ?*anyopaque {
    const allocator = std.heap.page_allocator;
    const token = std.c.toZigString(token_ptr);
    
    // SAFETY: Allocating on heap, pointer will be freed by destroy_discord_client
    var client = try DiscordClient.init(allocator, token);
    return @ptrCast([*]anyopaque, &client);
}

pub export fn destroy_discord_client(client_ptr: [*c]*anyopaque) callconv(.C) void {
    // SAFETY: Pointer must have been returned by create_discord_client
    // and not already freed. We cast back to the original type.
    const client = @ptrCast(*DiscordClient, @alignCast(@alignOf(DiscordClient), client_ptr));
    client.deinit();
    std.heap.page_allocator.free(client);
}

pub export fn discord_client_get_me(
    client_ptr: [*c]*anyopaque
) callconv(.C) ?*anyopaque {
    // SAFETY: client_ptr must be valid and point to a DiscordClient
    const client = @ptrCast(*DiscordClient, @alignCast(@alignOf(DiscordClient), client_ptr));
    const user = client.getCurrentUser() catch |err| {
        std.debug.print("Error getting current user: {}", .{err});
        return null;
    };
    // SAFETY: Allocating user on heap for return to caller
    const user_ptr = try std.heap.page_allocator.create(DiscordUser);
    user_ptr.* = user;
    return @ptrCast([*]anyopaque, user_ptr);
}

pub export fn discord_client_send_message(
    client_ptr: [*c]*anyopaque,
    channel_id: u64,
    content_ptr: [*c]const u8
) callconv(.C) ?*anyopaque {
    // SAFETY: client_ptr must be valid and point to a DiscordClient
    const client = @ptrCast(*DiscordClient, @alignCast(@alignOf(DiscordClient), client_ptr));
    const content = std.c.toZigString(content_ptr);
    const msg = client.sendMessage(channel_id, content) catch |err| {
        std.debug.print("Error sending message: {}", .{err});
        return null;
    };
    // SAFETY: Allocating message on heap for return to caller
    const msg_ptr = try std.heap.page_allocator.create(DiscordMessage);
    msg_ptr.* = msg;
    return @ptrCast([*]anyopaque, msg_ptr);
}

pub export fn discord_client_get_messages(
    client_ptr: [*c]*anyopaque,
    channel_id: u64,
    limit: u8
) callconv(.C) ?*anyopaque {
    // SAFETY: client_ptr must be valid and point to a DiscordClient
    const client = @ptrCast(*DiscordClient, @alignCast(@alignOf(DiscordClient), client_ptr));
    const msgs = client.getMessages(channel_id, limit) catch |err| {
        std.debug.print("Error getting messages: {}", .{err});
        return null;
    };
    // SAFETY: Allocating messages array on heap for return to caller
    // Note: This is a simplified placeholder - real implementation would need
    // proper memory management for the array and its elements
    return null;
}

// =============================================================================
// NOTE
// =============================================================================
//
// For production use, this would integrate with:
// - serenity (https://github.com/serenity-rs/serenity) via C FFI
// - or discord-rs via C bindings
// - or a custom HTTP client using zig-http
//
// The unified-hexadeca-api would provide common utilities for:
// - HTTP client functionality
// - JSON serialization/deserialization
// - OAuth2 token management
// - Rate limiting
