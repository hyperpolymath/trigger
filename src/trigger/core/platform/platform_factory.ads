--
-- platform_factory.ads - Platform Factory for Trigger
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

package Platform_Factory is

   -- Default values for platform configuration
   Default_Api_Id : constant Integer := 0;
   Default_Session_Dir : constant String(1..256) := (others => ' ');

   -- Array type for returning multiple platforms
   type Platform_Array is array (1..10) of Platform_Types.Platform_Type;

   -- Create a platform instance based on platform type
   -- Returns null if platform is not supported or creation fails
   function Create_Platform (Platform : Platform_Types.Platform_Type) 
                          return access Platform_Interface.Platform_Interface'Class;

   -- Create a platform instance with custom configuration
   function Create_Platform_With_Config (
      Platform : Platform_Types.Platform_Type;
      Api_Id : Integer;
      Api_Hash : String;
      Session_Dir : String
   ) return access Platform_Interface.Platform_Interface'Class;

   -- Check if a platform is supported
   function Is_Supported (Platform : Platform_Types.Platform_Type) return Boolean;

   -- Get all supported platforms
   function Get_Supported_Platforms return Platform_Array;

   -- Get platform name as string
   function Platform_To_String (Platform : Platform_Types.Platform_Type) return String;

end Platform_Factory;
