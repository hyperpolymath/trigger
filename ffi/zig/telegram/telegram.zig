//  Telegram API Bindings for Trigger
//  
//  Uses unified-hexadeca-api for Telegram client functionality
//  
//  Original concept by 2nixx (T.me/NetworkCriminals)
//  Zig bindings by hyperpolymath

const std = @import("std");
const hexadeca = @import("path:unified-hexadeca-api");  // Would reference actual path

//  Telegram client wrapper
pub const TelegramClient = struct {
    client: *hexadeca.TelegramClient,
    api_id: i32,
    api_hash: []const u8,
    session_name: []const u8,
    
    //  Initialize a new Telegram client
    pub fn init(allocator: std.mem.Allocator, api_id: i32, api_hash: []const u8, session_name: []const u8) !TelegramClient {
        var self = TelegramClient{
            .client = try hexadeca.telegramClientInit(allocator, api_id, api_hash),
            .api_id = api_id,
            .api_hash = api_hash,
            .session_name = session_name,
        };
        return self;
    }
    
    //  Deinitialize client
    pub fn deinit(self: *TelegramClient) void {
        hexadeca.telegramClientDestroy(self.client);
    }
    
    //  Start session with phone number
    pub fn start(self: *TelegramClient, phone: []const u8) !void {
        _ = try self.client.startSession(phone);
    }
    
    //  Connect to Telegram servers
    pub fn connect(self: *TelegramClient) !void {
        try self.client.connect();
    }
    
    //  Disconnect from Telegram servers
    pub fn disconnect(self: *TelegramClient) void {
        self.client.disconnect();
    }
    
    //  Check if user is authorized
    pub fn isAuthorized(self: *TelegramClient) bool {
        return self.client.isUserAuthorized();
    }
    
    //  Report a message
    pub fn reportMessage(self: *TelegramClient, peer: []const u8, message_id: i64, reason: []const u8) !void {
        try self.client.reportMessage(peer, message_id, reason);
    }
    
    //  Get messages from a chat
    pub fn getMessages(self: *TelegramClient, peer: []const u8, limit: i32) ![]hexadeca.Message {
        return try self.client.getMessages(peer, limit);
    }
    
    //  Save session to file
    pub fn saveSession(self: *TelegramClient) !void {
        try self.client.saveSessionToFile(self.session_name);
    }
    
    //  Load session from file
    pub fn loadSession(self: *TelegramClient) !void {
        try self.client.loadSessionFromFile(self.session_name);
    }
};

//  C-exported functions for Ada FFI
//  
//  SAFETY: The following functions use @ptrCast which is inherently unsafe.
//  These are required for FFI between Zig and Ada/C. All pointer casts:
//  1. Use proper @alignCast to ensure correct alignment
//  2. Assume the caller (Ada side) passes valid, properly-aligned pointers
//  3. Document the expected lifetime of returned pointers
//  4. Handle memory management explicitly (allocator used for creation, free for destruction)
//  
//  The unsafe operations are isolated to this FFI boundary layer only.

pub export fn create_telegram_client(
    api_id: i32,
    api_hash_ptr: [*c]const u8,
    session_name_ptr: [*c]const u8
) callconv(.C) ?*anyopaque {
    const allocator = std.heap.page_allocator;
    const api_hash = std.c.toZigString(api_hash_ptr);
    const session_name = std.c.toZigString(session_name_ptr);
    
    //  SAFETY: Allocating on heap, pointer will be freed by destroy_telegram_client
    var client = try TelegramClient.init(allocator, api_id, api_hash, session_name);
    return @ptrCast([*]anyopaque, &client);
}

pub export fn destroy_telegram_client(client_ptr: [*c]*anyopaque) callconv(.C) void {
    //  SAFETY: Pointer must have been returned by create_telegram_client
    //  and not already freed. We cast back to the original type.
    const client = @ptrCast(*TelegramClient, @alignCast(@alignOf(TelegramClient), client_ptr));
    client.deinit();
    std.heap.page_allocator.free(client);
}

pub export fn telegram_client_start(
    client_ptr: [*c]*anyopaque,
    phone_ptr: [*c]const u8
) callconv(.C) bool {
    //  SAFETY: client_ptr must be valid and point to a TelegramClient
    const client = @ptrCast(*TelegramClient, @alignCast(@alignOf(TelegramClient), client_ptr));
    const phone = std.c.toZigString(phone_ptr);
    return client.start(phone) catch false;
}

pub export fn telegram_client_connect(client_ptr: [*c]*anyopaque) callconv(.C) bool {
    //  SAFETY: client_ptr must be valid and point to a TelegramClient
    const client = @ptrCast(*TelegramClient, @alignCast(@alignOf(TelegramClient), client_ptr));
    return client.connect() catch false;
}

pub export fn telegram_client_disconnect(client_ptr: [*c]*anyopaque) callconv(.C) void {
    //  SAFETY: client_ptr must be valid and point to a TelegramClient
    const client = @ptrCast(*TelegramClient, @alignCast(@alignOf(TelegramClient), client_ptr));
    client.disconnect();
}

pub export fn telegram_client_is_authorized(client_ptr: [*c]*anyopaque) callconv(.C) bool {
    //  SAFETY: client_ptr must be valid and point to a TelegramClient
    const client = @ptrCast(*TelegramClient, @alignCast(@alignOf(TelegramClient), client_ptr));
    return client.isAuthorized();
}

//  Note: In a real implementation, this would properly integrate with
//  the unified-hexadeca-api which provides Telegram TDLib or MTProto bindings
