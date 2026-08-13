--  Trigger - Telegram FFI Bindings Specification
--  
--  Ada bindings for Telegram API via Zig FFI (unified-hexadeca-api)
--  
--  This package provides the interface for calling Telegram functions
--  implemented in Zig through C-exported symbols.
--  
--  Author: hyperpolymath
--  Architecture: Ada/SPARK <- Idris2 <- Zig (FFI)
--  License: MPL-2.0
--  SPDX-License-Identifier: MPL-2.0

package Trigger.FFI.Telegram is

   --  Telegram client handle (opaque pointer from Zig)
   type Telegram_Client_Ptr is access all Integer;

   --  Telegram message handle
   type Telegram_Message_Ptr is access all Integer;

   --  Telegram user handle
   type Telegram_User_Ptr is access all Integer;

   --  Telegram chat/channel handle
   type Telegram_Chat_Ptr is access all Integer;

   --  Maximum string lengths
   Max_Phone_Length : constant := 20;
   Max_Username_Length : constant := 64;
   Max_Message_Length : constant := 4096;

   --  Create a Telegram client
   function Create_Client (
      Api_Id : Integer;
      Api_Hash : String;
      Session_Dir : String
   ) return Telegram_Client_Ptr
     with Import, Convention => C, External_Name => "create_telegram_client";

   --  Destroy a Telegram client
   procedure Destroy_Client (Client : Telegram_Client_Ptr)
     with Import, Convention => C, External_Name => "destroy_telegram_client";

   --  Connect to Telegram
   function Connect (Client : Telegram_Client_Ptr) return Integer
     with Import, Convention => C, External_Name => "telegram_client_connect";

   --  Disconnect from Telegram
   procedure Disconnect (Client : Telegram_Client_Ptr)
     with Import, Convention => C, External_Name => "telegram_client_disconnect";

   --  Check if connected
   function Is_Connected (Client : Telegram_Client_Ptr) return Integer
     with Import, Convention => C, External_Name => "telegram_client_is_connected";

   --  Check if authorized
   function Is_Authorized (Client : Telegram_Client_Ptr) return Integer
     with Import, Convention => C, External_Name => "telegram_client_is_authorized";

   --  Get current user
   function Get_Me (Client : Telegram_Client_Ptr) return Telegram_User_Ptr
     with Import, Convention => C, External_Name => "telegram_client_get_me";

   --  Get messages from a chat/channel
   function Get_Messages (
      Client : Telegram_Client_Ptr;
      Chat_Identifier : String;
      Limit : Integer
   ) return Telegram_Message_Ptr
     with Import, Convention => C, External_Name => "telegram_client_get_messages";

   --  Report a message
   procedure Report_Message (
      Client : Telegram_Client_Ptr;
      Chat_Identifier : String;
      Message_Id : Integer;
      Reason : Integer
   )
     with Import, Convention => C, External_Name => "telegram_client_report_message";

   --  Send a message
   function Send_Message (
      Client : Telegram_Client_Ptr;
      Chat_Identifier : String;
      Content : String
   ) return Telegram_Message_Ptr
     with Import, Convention => C, External_Name => "telegram_client_send_message";

   --  Ping the Telegram API
   function Ping (Client : Telegram_Client_Ptr) return Integer
     with Import, Convention => C, External_Name => "telegram_client_ping";

end Trigger.FFI.Telegram;
