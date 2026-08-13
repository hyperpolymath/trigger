-- SocialMediaAPI.idr - Generic Social Media API Layer for Trigger
-- 
-- This module provides a platform-agnostic, type-safe API interface for social
-- media operations. Platform-specific implementations (Telegram, Discord, Twitter)
-- implement this interface using their respective FFI bindings.
-- 
-- Architecture:
--   - Idris2: Type-safe API interfaces (this file)
--   - Zig:    Platform-specific FFI implementations (ffi/zig/<platform>/)
--   - Ada:    Core application logic (src/trigger/)
--
-- Original concept by 2nixx (T.me/NetworkCriminals)
-- Generic API design by hyperpolymath

module SocialMediaAPI

import Data.String
import Data.Maybe
import Data.List
import Data.Nat
import Control.Monad.Effect

-- =============================================================================
-- PLATFORM TYPE
-- =============================================================================

/// Platform identifier - extends to support new platforms
%hiding (Eq, Show)
data Platform = 
  | Telegram
  | Discord
  | Twitter  -- X
  | Instagram
  | Reddit
  | Facebook
  | YouTube
  | TikTok
  | LinkedIn
  | Custom String  -- For user-defined platforms

-- =============================================================================
-- ERROR TYPE
-- =============================================================================

/// Unified error type for all platform operations
%hiding (Eq, Show)
data SocialError = 
  | NetworkError String
  | AuthError String
  | RateLimitError Nat  -- Seconds until retry allowed
  | NotFoundError String
  | PermissionError String
  | PlatformError Platform String
  | UnknownError String

-- =============================================================================
-- ACCOUNT TYPE
-- =============================================================================

/// Generic account representation across all platforms
record Account where
  constructor MkAccount
  
  platform    : Platform
  identifier  : String    -- Platform-specific ID (phone, username, email, etc.)
  displayName : Maybe String
  active      : Bool
  verified    : Bool
  createdAt   : Nat      -- Timestamp
  lastUsedAt  : Nat      -- Timestamp
  reports     : Nat

-- =============================================================================
-- SESSION TYPE
-- =============================================================================

/// Generic authenticated session
record Session where
  constructor MkSession
  
  platform      : Platform
  account       : Account
  sessionId     : String
  accessToken   : Maybe String
  refreshToken  : Maybe String
  tokenExpires  : Maybe Nat  -- Timestamp
  encrypted     : Bool      -- Whether session data is encrypted

-- =============================================================================
-- MESSAGE TYPE
-- =============================================================================

/// Generic message/content from any platform
record Message where
  constructor MkMessage
  
  platform    : Platform
  id          : String    -- Platform-specific message ID
  content     : String
  author      : Account
  timestamp   : Nat
  channel     : String    -- Channel/Server/Group identifier
  metadata    : Maybe MessageMetadata

/// Platform-specific message metadata
record MessageMetadata where
  constructor MkMessageMetadata
  
  replies      : Maybe Nat
  reactions    : Maybe Nat
  views        : Maybe Nat
  attachments  : Maybe (List String)
  platformData : Maybe String  -- Platform-specific JSON/data

-- =============================================================================
-- REPORT TYPE
-- =============================================================================

/// Report reason - platform-agnostic categories
%hiding (Eq, Show)
data ReportReason = 
  | Spam
  | Scam
  | Harassment
  | Violence
  | HateSpeech
  | SexualContent
  | Misinformation
  | IllegalActivity
  | CopyrightInfringement
  | SelfHarm
  | SuicideOrInjury
  | Custom String

/// Report status
%hiding (Eq, Show)
data ReportStatus = 
  | Pending
  | InReview
  | Approved
  | Rejected
  | Appealable

/// Report result
record ReportResult where
  constructor MkReportResult
  
  success     : Bool
  status      : ReportStatus
  reportId    : Maybe String
  message     : Maybe String
  cooldown    : Maybe Nat  -- Seconds

-- =============================================================================
-- PLATFORM CAPABILITIES
-- =============================================================================

/// Capabilities that a platform may or may not support
record PlatformCapabilities where
  constructor MkPlatformCapabilities
  
  supportsMessaging     : Bool
  supportsReporting     : Bool
  supportsMultiAccount  : Bool
  supportsSessionPersist: Bool
  supportsRateLimitInfo : Bool
  supportsWebhooks      : Bool
  supportsSearch        : Bool
  supportsMediaUpload   : Bool
  supportsMediaDownload : Bool

-- =============================================================================
-- PLATFORM INTERFACE
-- =============================================================================

/// Generic platform interface - all implementations must provide these
interface SocialPlatform a where
  -- Platform information
  getPlatform       : a -> Platform
  getCapabilities   : a -> PlatformCapabilities
  
  -- Session management
  createSession     : a -> Account -> Effect (Either SocialError Session)
  destroySession    : a -> Session -> Effect (Either SocialError ())
  connect           : a -> Session -> Effect (Either SocialError Bool)
  disconnect        : a -> Session -> Effect (Either SocialError ())
  isAuthorized      : a -> Session -> Effect (Either SocialError Bool)
  refreshSession    : a -> Session -> Effect (Either SocialError Session)
  
  -- Account management
  getAccount        : a -> Session -> String -> Effect (Either SocialError Account)
  listAccounts      : a -> Session -> Effect (Either SocialError (List Account))
  updateAccount     : a -> Session -> Account -> Effect (Either SocialError Account)
  
  -- Message operations
  getMessages       : a -> Session -> String -> Nat -> Effect (Either SocialError (List Message))
  getMessage        : a -> Session -> String -> String -> Effect (Either SocialError Message)
  
  -- Reporting operations
  reportMessage     : a -> Session -> Message -> ReportReason -> String -> Effect (Either SocialError ReportResult)
  reportMessages    : a -> Session -> List Message -> ReportReason -> String -> Effect (Either SocialError (List ReportResult))
  
  -- Platform health
  ping             : a -> Effect (Either SocialError ())
  getRateLimits    : a -> Session -> Effect (Either SocialError RateLimitInfo)

-- Rate limit information
record RateLimitInfo where
  constructor MkRateLimitInfo
  
  remaining      : Nat
  resetIn        : Nat  -- Seconds until reset
  limit          : Nat
  retryAfter     : Maybe Nat

-- =============================================================================
-- FACTORY FUNCTION
-- =============================================================================

/// Create a platform instance based on platform type
/// This is the entry point for the plugin system
export
createPlatform : Platform -> Effect (Maybe (Any SocialPlatform))
createPlatform platform = do
  case platform of
    Telegram  => pure (Just (Any (MkTelegramPlatform : SocialPlatform TelegramPlatform)))
    Discord   => pure (Just (Any (MkDiscordPlatform : SocialPlatform DiscordPlatform)))
    Twitter   => pure (Just (Any (MkTwitterPlatform : SocialPlatform TwitterPlatform)))
    Instagram => pure Nothing  -- Not yet implemented
    Reddit     => pure Nothing  -- Not yet implemented
    Facebook   => pure Nothing  -- Not yet implemented
    YouTube    => pure Nothing  -- Not yet implemented
    TikTok     => pure Nothing  -- Not yet implemented
    LinkedIn   => pure Nothing  -- Not yet implemented
    Custom _   => pure Nothing  -- Custom platforms not supported yet

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

/// Get all supported platforms
export
getSupportedPlatforms : List Platform
getSupportedPlatforms = [Telegram, Discord, Twitter]

/// Check if a platform is supported
export
isSupported : Platform -> Bool
isSupported p = p `elem` getSupportedPlatforms

/// Platform name as string
export
platformToString : Platform -> String
platformToString Telegram  = "Telegram"
platformToString Discord   = "Discord"
platformToString Twitter   = "Twitter/X"
platformToString Instagram = "Instagram"
platformToString Reddit     = "Reddit"
platformToString Facebook   = "Facebook"
platformToString YouTube    = "YouTube"
platformToString TikTok     = "TikTok"
platformToString LinkedIn   = "LinkedIn"
platformToString (Custom s) = s

-- =============================================================================
-- ERROR HANDLING UTILITIES
-- =============================================================================

/// Convert platform-specific error to generic error
%hiding (toMaybe)
export
toSocialError : String -> SocialError
toSocialError msg = PlatformError Telegram msg  -- Default, override per platform

-- =============================================================================
-- NOTE
-- =============================================================================
--
-- Platform-specific implementations (TelegramAPI.idr, DiscordAPI.idr, etc.)
-- must implement the SocialPlatform interface and use their respective
-- Zig FFI bindings.
--
-- The Zig FFI layer uses unified-hexadeca-api for consistency across platforms.
