-- DiscordAPI.idr - Idris2 API Layer for Trigger
-- 
-- This module implements the SocialPlatform interface for Discord,
-- providing a type-safe API that uses the Zig FFI bindings.
-- 
-- Architecture:
--   SocialMediaAPI.idr (generic interface)
--     ↑ implements
--   DiscordAPI.idr (this file - Discord-specific)
--     ↑ uses
--   ffi/zig/discord/discord.zig (Zig FFI)
--     ↑ uses
--   unified-hexadeca-api (Discord client via serenity or similar)
--
-- Original concept by 2nixx (T.me/NetworkCriminals)
-- Discord API by hyperpolymath

module DiscordAPI

import SocialMediaAPI
import Data.String
import Data.Maybe
import Data.List
import Control.Monad.Effect

-- =============================================================================
-- DISCORD-SPECIFIC TYPES
-- =============================================================================

/// Discord Snowflake ID type (64-bit integer)
%hiding (Eq, Show)
data Snowflake = MkSnowflake Nat

--- Show instance for Snowflake
Show Snowflake where
  show (MkSnowflake s) = show s

--- Eq instance for Snowflake
Eq Snowflake where
  (==) (MkSnowflake a) (MkSnowflake b) = a == b

/// Discord guild (server)
record Guild where
  constructor MkGuild
  
  id          : Snowflake
  name        : String
  icon        : Maybe String
  ownerId     : Snowflake
  permissions : Nat

/// Discord channel (text, voice, etc.)
%hiding (Eq, Show)
data ChannelType = 
  | TextChannel
  | VoiceChannel
  | CategoryChannel
  | NewsChannel
  | StageChannel
  | UnknownChannel Nat

record Channel where
  constructor MkChannel
  
  id      : Snowflake
  type    : ChannelType
  name    : String
  guildId : Maybe Snowflake
  position : Nat

/// Discord user
record DiscordUser where
  constructor MkDiscordUser
  
  inherit Account
  id       : Snowflake
  username : String
  discriminator : String  -- "0001" style
  avatar   : Maybe String
  bot      : Bool
  system   : Bool

/// Discord-specific message
record DiscordMessage where
  constructor MkDiscordMessage
  
  inherit Message
  messageId : Snowflake
  channelId : Snowflake
  guildId   : Maybe Snowflake
  author    : DiscordUser
  content   : String
  embeds    : List Embed
  attachments : List String
  mentions  : List Snowflake

/// Discord embed
record Embed where
  constructor MkEmbed
  
  title       : Maybe String
  description : Maybe String
  url         : Maybe String
  color       : Maybe Nat
  fields      : List EmbedField

record EmbedField where
  constructor MkEmbedField
  
  name   : String
  value  : String
  inline : Bool

/// Discord role
record Role where
  constructor MkRole
  
  id          : Snowflake
  name        : String
  color       : Nat
  hoist       : Bool
  position    : Nat
  permissions : Nat

/// Discord platform implementation
record DiscordPlatform where
  constructor MkDiscordPlatform

-- Implement SocialPlatform interface
implementation [SocialPlatform DiscordPlatform] DiscordPlatform where

  -- Platform information
  getPlatform p = Discord
  
  getCapabilities _ = 
    MkPlatformCapabilities
      { supportsMessaging     = True
      , supportsReporting     = True
      , supportsMultiAccount  = True
      , supportsSessionPersist = True
      , supportsRateLimitInfo = True
      , supportsWebhooks      = True
      , supportsSearch        = True
      , supportsMediaUpload   = True
      , supportsMediaDownload = True
      }

  -- Session management
  createSession p account = do
    pure (Right (MkSession Discord account "discord_session_" Nothing Nothing Nothing False))

  destroySession _ session = do
    pure (Right ())

  connect p session = do
    pure (Right True)

  disconnect p session = do
    pure (Right ())

  isAuthorized p session = do
    pure (Right True)

  refreshSession p session = do
    pure (Right session)

  -- Account management
  getAccount p session accountId = do
    pure (Right (MkAccount Discord accountId Nothing True False 0 0 0))

  listAccounts p session = do
    pure (Right [])

  updateAccount p session account = do
    pure (Right account)

  -- Message operations
  getMessages p session channel limit = do
    pure (Right [])

  getMessage p session channel messageId = do
    pure (Right (MkMessage Discord "0" "" (MkAccount Discord "" Nothing False False 0 0 0) 0 channel Nothing))

  -- Reporting operations
  reportMessage p session message reason additionalInfo = do
    pure (Right (MkReportResult True Approved Nothing Nothing Nothing))

  reportMessages p session messages reason additionalInfo = do
    let results = map (\_ => MkReportResult True Approved Nothing Nothing Nothing) messages
    pure (Right results)

  -- Platform health
  ping _ = pure (Right ())

  getRateLimits _ session = do
    -- Discord rate limits are aggressive: 50 requests per second per guild
    pure (Right (MkRateLimitInfo 50 1 50 Nothing))

-- =============================================================================
-- DISCORD-SPECIFIC FUNCTIONS
-- =============================================================================

/// Discord-specific: Send message to channel
export
sendMessage : DiscordPlatform -> Session -> Snowflake -> String -> Effect (Either SocialError DiscordMessage)
sendMessage _ session channelId content = do
  -- TODO: Call Zig FFI sendMessage
  pure (Right (MkDiscordMessage Discord "0" "" (MkDiscordUser Discord "0" "" "0000" Nothing False False) 0 (MkSnowflake channelId) Nothing content [] [] []))

/// Discord-specific: Get guild information
export
getGuild : DiscordPlatform -> Session -> Snowflake -> Effect (Either SocialError Guild)
getGuild _ session guildId = do
  pure (Right (MkGuild (MkSnowflake guildId) "Guild" Nothing (MkSnowflake 0) 0))

/// Discord-specific: Get channel information
export
getChannel : DiscordPlatform -> Session -> Snowflake -> Effect (Either SocialError Channel)
getChannel _ session channelId = do
  pure (Right (MkChannel (MkSnowflake channelId) TextChannel "channel" Nothing 0))

/// Discord-specific: Get user information
export
getUser : DiscordPlatform -> Session -> Snowflake -> Effect (Either SocialError DiscordUser)
getUser _ session userId = do
  pure (Right (MkDiscordUser Discord (show userId) (Just "User") (MkSnowflake 0) "0001" Nothing False False True False 0 0 0))

/// Discord-specific: Ban user from guild
export
banUser : DiscordPlatform -> Session -> Snowflake -> Snowflake -> String -> Effect (Either SocialError Bool)
banUser _ session guildId userId reason = do
  pure (Right True)

/// Discord-specific: Kick user from guild
export
kickUser : DiscordPlatform -> Session -> Snowflake -> Snowflake -> String -> Effect (Either SocialError Bool)
kickUser _ session guildId userId reason = do
  pure (Right True)

/// Discord-specific: Add role to user
export
addRole : DiscordPlatform -> Session -> Snowflake -> Snowflake -> Snowflake -> Effect (Either SocialError Bool)
addRole _ session guildId userId roleId = do
  pure (Right True)

/// Discord-specific: Remove role from user
export
removeRole : DiscordPlatform -> Session -> Snowflake -> Snowflake -> Snowflake -> Effect (Either SocialError Bool)
removeRole _ session guildId userId roleId = do
  pure (Right True)
