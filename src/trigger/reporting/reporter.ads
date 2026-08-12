--  Trigger - Reporter Package Specification
--  
--  Handles reporting of Telegram messages/channels.
--  
--  Uses Zig FFI via unified-hexadeca-api for Telegram API access.
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)

with Ada.Strings.Unbounded;
with Trigger.Utils.Logging;

package Trigger.Reporting.Reporter is

   --  Telegram client type (from Zig FFI)
   type Telegram_Client_Type is private;

   --  Reporter type
   type Reporter_Type is tagged private;

   --  Report statistics
   type Report_Stats is record
      Report_Count : Natural := 0;
      Error_Count : Natural := 0;
      Success_Rate : Float := 0.0;
   end record;

   --  Initialize reporter
   procedure Initialize (
      Client : out Telegram_Client_Type;
      Reporter : out Reporter_Type;
      API_ID : Integer;
      API_Hash : String;
      Session_Name : String;
      Logger : Logging.Logger_Type
   );

   --  Finalize reporter
   procedure Finalize (Client : in out Telegram_Client_Type);

   --  Report specific messages
   procedure Report_Messages (
      Reporter : Reporter_Type;
      Client : Telegram_Client_Type;
      Chat_Username : String;
      Message_IDs : String;  --  Comma-separated list
      Delay : Float;
      Option : String;
      Success : out Boolean;
      Stats : out Report_Stats
   );

   --  Report last N messages from a channel
   procedure Report_Last_Messages (
      Reporter : Reporter_Type;
      Client : Telegram_Client_Type;
      Chat_Username : String;
      Count : Integer;
      Delay : Float;
      Option : String;
      Success : out Boolean;
      Stats : out Report_Stats
   );

private

   --  Reporter record
   type Reporter_Type is tagged record
      API_ID : Integer;
      API_Hash : Ada.Strings.Unbounded.Unbounded_String;
      Session_Name : Ada.Strings.Unbounded.Unbounded_String;
      Logger : Logging.Logger_Type;
      Report_Count : Natural := 0;
      Error_Count : Natural := 0;
   end record;

   --  Telegram client (placeholder for Zig FFI type)
   type Telegram_Client_Type is record
      Session_Name : Ada.Strings.Unbounded.Unbounded_String;
      Connected : Boolean := False;
   end record;

end Trigger.Reporting.Reporter;
