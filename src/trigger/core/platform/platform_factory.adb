--
-- platform_factory.adb - Platform Factory for Trigger
--
-- This package provides a factory for creating platform instances based on
-- the platform type. It uses a plugin-style architecture where each platform
-- registers itself.
--
-- Architecture:
--   Platform_Factory -> Platform_Implementations (Telegram, Discord, Twitter)
--
-- Original concept by 2nixx (T.me/NetworkCriminals)
-- Ada/SPARK implementation by hyperpolymath
--
-- License: MPL-2.0
-- SPDX-License-Identifier: MPL-2.0
--

with Platform_Types;
with Platform_Interface;

package body Platform_Factory is

   -- Default API ID and Hash (can be overridden via configuration)
   Default_Api_Id : constant Integer := 0;
   Default_Api_Hash : constant String(1..64) := (others => ' ');
   Default_Session_Dir : constant String(1..256) := (others => ' ');

   -- Array type for platform list
   type Platform_Array is array (1..10) of Platform_Types.Platform_Type;

   -- Create a platform instance based on platform type
   -- Returns null if platform is not supported or creation fails
   function Create_Platform (Platform : Platform_Types.Platform_Type) return access Platform_Interface.Platform_Interface'Class is
   begin
      case Platform is
         when Platform_Types.Telegram =>
            return new Telegram_Platform.Platform_Implementation'(
               Telegram_Platform.Platform_Implementation'(
                  Telegram_Platform.Init (Default_Api_Id, Default_Api_Hash, Default_Session_Dir)
               )
            );
         when Platform_Types.Discord =>
            return new Discord_Platform.Platform_Implementation;
         when Platform_Types.Twitter =>
            return new Twitter_Platform.Platform_Implementation;
         when others =>
            return null;
      end case;
   end Create_Platform;

   -- Create a platform instance with custom configuration
   function Create_Platform_With_Config (
      Platform : Platform_Types.Platform_Type;
      Api_Id : Integer;
      Api_Hash : String;
      Session_Dir : String
   ) return access Platform_Interface.Platform_Interface'Class is
   begin
      case Platform is
         when Platform_Types.Telegram =>
            return new Telegram_Platform.Platform_Implementation'(
               Telegram_Platform.Platform_Implementation'(
                  Telegram_Platform.Init (Api_Id, Api_Hash, Session_Dir)
               )
            );
         when Platform_Types.Discord =>
            return new Discord_Platform.Platform_Implementation;
         when Platform_Types.Twitter =>
            return new Twitter_Platform.Platform_Implementation;
         when others =>
            return null;
      end case;
   end Create_Platform_With_Config;
   
   -- Check if a platform is supported
   function Is_Supported (Platform : Platform_Types.Platform_Type) return Boolean is
   begin
      return Platform in Platform_Types.Telegram | Platform_Types.Discord | Platform_Types.Twitter;
   end Is_Supported;
   
   -- Get all supported platforms
   function Get_Supported_Platforms return Platform_Array is
      Supported : constant Platform_Array := (
         1 => Platform_Types.Telegram,
         2 => Platform_Types.Discord,
         3 => Platform_Types.Twitter,
         others => Platform_Types.Telegram  -- Default for unused slots
      );
   begin
      return Supported;
   end Get_Supported_Platforms;
   
   -- Get platform name as string
   function Platform_To_String (Platform : Platform_Types.Platform_Type) return String is
   begin
      case Platform is
         when Platform_Types.Telegram => return "Telegram";
         when Platform_Types.Discord => return "Discord";
         when Platform_Types.Twitter => return "Twitter/X";
         when Platform_Types.Instagram => return "Instagram";
         when Platform_Types.Reddit => return "Reddit";
         when Platform_Types.Facebook => return "Facebook";
         when Platform_Types.YouTube => return "YouTube";
         when Platform_Types.TikTok => return "TikTok";
         when Platform_Types.LinkedIn => return "LinkedIn";
         when Platform_Types.Custom => return "Custom";
      end case;
   end Platform_To_String;

end Platform_Factory;
