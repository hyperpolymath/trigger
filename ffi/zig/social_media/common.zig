// social_media/common.zig - Common utilities for social media platforms
//
// Shared types, utilities, and helpers for all social media FFI implementations.
//
// Original concept by 2nixx (T.me/NetworkCriminals)
// Common utilities by hyperpolymath

const std = @import("std");

// =============================================================================
// COMMON CONSTANTS
// =============================================================================

pub const MAX_USERNAME_LENGTH = 64;
pub const MAX_MESSAGE_LENGTH = 4096;
pub const MAX_BIO_LENGTH = 160;
pub const MAX_URL_LENGTH = 2048;

// =============================================================================
// COMMON TYPES
// =============================================================================

// Platform identifier (matches Idris2 SocialMediaAPI.Platform)
pub const Platform = enum {
    TELEGRAM,
    DISCORD,
    TWITTER,
    INSTAGRAM,
    REDDIT,
    FACEBOOK,
    YOUTUBE,
    TIKTOK,
    LINKEDIN,
    CUSTOM,
};

// Error codes (matches Idris2 SocialMediaAPI.SocialError)
pub const SocialErrorCode = enum {
    NETWORK_ERROR,
    AUTH_ERROR,
    RATE_LIMIT_ERROR,
    NOT_FOUND_ERROR,
    PERMISSION_ERROR,
    PLATFORM_ERROR,
    UNKNOWN_ERROR,
};

// Rate limit info structure
pub const RateLimitInfo = extern struct {
    remaining: u16,
    reset_in: u64,  // seconds
    limit: u16,
    retry_after: u64,  // seconds, optional
};

// Authentication tokens
pub const AuthTokens = extern struct {
    access_token: []const u8,
    refresh_token: []const u8,
    expires_in: u64,  // seconds
    token_type: []const u8,
};

// =============================================================================
// STRING UTILITIES
// =============================================================================

/// Check if a string is null or empty
pub fn isNullOrEmpty(str: []const u8) bool {
    return str.len == 0;
}

/// Convert a C string to a Zig string, handling null
pub fn cToZigStringNullable(c_str: [*c]const u8) ?[]const u8 {
    if (c_str == null) {
        return null;
    }
    return std.c.toZigString(c_str);
}

/// Safe string duplication with null check
pub fn safeDupe(allocator: std.mem.Allocator, str: []const u8) ![]u8 {
    if (isNullOrEmpty(str)) {
        return try allocator.alloc(u8, 0);
    }
    return try allocator.dupe(u8, str);
}

// =============================================================================
// HTTP UTILITIES
// =============================================================================

pub const HttpMethod = enum {
    GET,
    POST,
    PUT,
    DELETE,
    PATCH,
    HEAD,
    OPTIONS,
};

pub const HttpStatus = enum {
    CONTINUE = 100,
    SWITCHING_PROTOCOLS = 101,
    PROCESSING = 102,
    
    OK = 200,
    CREATED = 201,
    ACCEPTED = 202,
    NON_AUTHORITATIVE_INFORMATION = 203,
    NO_CONTENT = 204,
    RESET_CONTENT = 205,
    PARTIAL_CONTENT = 206,
    MULTI_STATUS = 207,
    ALREADY_REPORTED = 208,
    IM_USED = 226,
    
    MULTIPLE_CHOICES = 300,
    MOVED_PERMANENTLY = 301,
    FOUND = 302,
    SEE_OTHER = 303,
    NOT_MODIFIED = 304,
    USE_PROXY = 305,
    TEMPORARY_REDIRECT = 307,
    PERMANENT_REDIRECT = 308,
    
    BAD_REQUEST = 400,
    UNAUTHORIZED = 401,
    PAYMENT_REQUIRED = 402,
    FORBIDDEN = 403,
    NOT_FOUND = 404,
    METHOD_NOT_ALLOWED = 405,
    NOT_ACCEPTABLE = 406,
    PROXY_AUTHENTICATION_REQUIRED = 407,
    REQUEST_TIMEOUT = 408,
    CONFLICT = 409,
    GONE = 410,
    LENGTH_REQUIRED = 411,
    PRECONDITION_FAILED = 412,
    PAYLOAD_TOO_LARGE = 413,
    URI_TOO_LONG = 414,
    UNSUPPORTED_MEDIA_TYPE = 415,
    RANGE_NOT_SATISFIABLE = 416,
    EXPECTATION_FAILED = 417,
    I_AM_A_TEAPOT = 418,
    UNPROCESSABLE_ENTITY = 422,
    LOCKED = 423,
    FAILED_DEPENDENCY = 424,
    TOO_EARLY = 425,
    UPGRADE_REQUIRED = 426,
    PRECONDITION_REQUIRED = 428,
    TOO_MANY_REQUESTS = 429,
    REQUEST_HEADER_FIELDS_TOO_LARGE = 431,
    UNAVAILABLE_FOR_LEGAL_REASONS = 451,
    
    INTERNAL_SERVER_ERROR = 500,
    NOT_IMPLEMENTED = 501,
    BAD_GATEWAY = 502,
    SERVICE_UNAVAILABLE = 503,
    GATEWAY_TIMEOUT = 504,
    HTTP_VERSION_NOT_SUPPORTED = 505,
    VARIANT_ALSO_NEGOTIATES = 506,
    INSUFFICIENT_STORAGE = 507,
    LOOP_DETECTED = 508,
    NOT_EXTENDED = 510,
    NETWORK_AUTHENTICATION_REQUIRED = 511,
};

/// Check if HTTP status is successful (2xx)
pub fn isSuccess(status: HttpStatus) bool {
    return @intCast(u16, status) >= 200 and @intCast(u16, status) < 300;
}

/// Check if HTTP status is rate limited (429)
pub fn isRateLimited(status: HttpStatus) bool {
    return status == .TOO_MANY_REQUESTS;
}

// =============================================================================
// JSON UTILITIES
// =============================================================================

// Placeholder for JSON parsing - would use zig-json or similar
pub fn parseJson(_: []const u8) anyerror {!void} {
    // TODO: Implement JSON parsing
    return;
}

pub fn serializeJson(_: anytype) anyerror {![]const u8} {
    // TODO: Implement JSON serialization
    return &[_]u8{};
}

// =============================================================================
-- LOGGING
// =============================================================================

pub const LogLevel = enum {
    ERROR,
    WARN,
    INFO,
    DEBUG,
    TRACE,
};

pub fn log(level: LogLevel, platform: Platform, message: []const u8) void {
    const prefix = switch (level) {
        .ERROR => "[ERROR]",
        .WARN => "[WARN]",
        .INFO => "[INFO]",
        .DEBUG => "[DEBUG]",
        .TRACE => "[TRACE]",
    };
    const platform_str = switch (platform) {
        .TELEGRAM => "Telegram",
        .DISCORD => "Discord",
        .TWITTER => "Twitter",
        .INSTAGRAM => "Instagram",
        .REDDIT => "Reddit",
        .FACEBOOK => "Facebook",
        .YOUTUBE => "YouTube",
        .TIKTOK => "TikTok",
        .LINKEDIN => "LinkedIn",
        .CUSTOM => "Custom",
    };
    std.debug.print("{s} [{s}] {s}\n", .{ prefix, platform_str, message });
}

pub fn logError(platform: Platform, message: []const u8) void {
    log(.ERROR, platform, message);
}

pub fn logWarn(platform: Platform, message: []const u8) void {
    log(.WARN, platform, message);
}

pub fn logInfo(platform: Platform, message: []const u8) void {
    log(.INFO, platform, message);
}

pub fn logDebug(platform: Platform, message: []const u8) void {
    log(.DEBUG, platform, message);
}

// =============================================================================
-- RATE LIMIT MANAGEMENT
// =============================================================================

pub const RateLimitState = struct {
    allocator: std.mem.Allocator,
    limits: std.StringHashMap(u64),  // endpoint -> reset timestamp
    
    pub fn init(allocator: std.mem.Allocator) !RateLimitState {
        var hashmap = std.StringHashMap(u64).init(allocator);
        return RateLimitState{
            .allocator = allocator,
            .limits = hashmap,
        };
    }
    
    pub fn deinit(self: *RateLimitState) void {
        var iter = self.limits.iterator();
        while (iter.next()) |entry| {
            _ = entry.key_ptr.*;
            _ = entry.value_ptr.*;
        }
        self.limits.deinit();
    }
    
    /// Check if we should wait for rate limit
    pub fn shouldWait(self: *RateLimitState, endpoint: []const u8) bool {
        if (!self.limits.contains(endpoint)) {
            return false;
        }
        const reset_time = self.limits.get(endpoint) orelse return false;
        const now = std.time.timestamp();
        return now < reset_time;
    }
    
    /// Update rate limit for an endpoint
    pub fn updateLimit(self: *RateLimitState, endpoint: []const u8, reset_in: u64) void {
        const reset_time = std.time.timestamp() + std.time.s(reset_in);
        self.limits.put(endpoint, reset_time);
    }
    
    /// Get remaining time for an endpoint
    pub fn getRemaining(self: *RateLimitState, endpoint: []const u8) ?u64 {
        if (!self.limits.contains(endpoint)) {
            return null;
        }
        const reset_time = self.limits.get(endpoint) orelse return null;
        const now = std.time.timestamp();
        if (now >= reset_time) {
            return 0;
        }
        return @intCast(u64, reset_time - now);
    }
};
