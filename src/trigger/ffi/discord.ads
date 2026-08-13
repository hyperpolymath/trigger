--  Trigger - Discord FFI Bindings Specification
--  
--  Ada bindings for Discord API via Zig FFI (unified-hexadeca-api)
--  
--  This package provides the interface for calling Discord functions
--  implemented in Zig through C-exported symbols.
--  
--  Author: hyperpolymath
--  Architecture: Ada/SPARK <- Idris2 <- Zig (FFI)
--  License: MPL-2.0
--  SPDX-License-Identifier: MPL-2.0

package Trigger.FFI.Discord is

   --  Discord client handle (opaque pointer from Zig)
   type Discord_Client_Ptr is access all void;

   --  Discord message handle
   type Discord_Message_Ptr is access all void;

   --  Discord user handle
   type Discord_User_Ptr is access all void;

   --  Discord guild (server) handle
   type Discord_Guild_Ptr is access all void;

   --  Discord Snowflake type (64-bit ID)
   type Snowflake is mod 2**64;

   --  Maximum string lengths
   Max_Username_Length : constant := 64;
   Max_Message_Length : constant := 2000;
   Max_Guild_Name_Length : constant := 100;
   Max_Channel_Name_Length : constant := 100;

   --  Create a Discord client
   function Create_Client (Token : String) return Discord_Client_Ptr
     with Import, Convention => C, External_Name => "create_discord_client";

   --  Destroy a Discord client
   procedure Destroy_Client (Client : Discord_Client_Ptr)
     with Import, Convention => C, External_Name => "destroy_discord_client";

   --  Get current user
   function Get_Current_User (Client : Discord_Client_Ptr) return Discord_User_Ptr
     with Import, Convention => C, External_Name => "discord_client_get_me";

   --  Send a message
   function Send_Message (
      Client : Discord_Client_Ptr;
      Channel_Id : Snowflake;
      Content : String
   ) return Discord_Message_Ptr
     with Import, Convention => C, External_Name => "discord_client_send_message";

   --  Get messages from channel
   function Get_Messages (
      Client : Discord_Client_Ptr;
      Channel_Id : Snowflake;
      Limit : Integer
   ) return Discord_Message_Ptr
     with Import, Convention => C, External_Name => "discord_client_get_messages";

   --  Report a message (via reaction or API)
   procedure Report_Message (
      Client : Discord_Client_Ptr;
      Channel_Id : Snowflake;
      Message_Id : Snowflake;
      Reason : Integer
   )
     with Import, Convention => C, External_Name => "discord_client_report_message";

   --  Get guild information
   function Get_Guild (
      Client : Discord_Client_Ptr;
      Guild_Id : Snowflake
   ) return Discord_Guild_Ptr
     with Import, Convention => C, External_Name => "discord_client_get_guild";

   --  Ping the Discord API
   function Ping (Client : Discord_Client_Ptr) return Integer
     with Import, Convention => C, External_Name => "discord_client_ping";

end Trigger.FFI.Discord;
