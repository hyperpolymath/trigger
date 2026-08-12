--  Trigger - Session Manager Specification
--  
--  Manages Telegram sessions for multiple accounts including
--  creation, loading, saving, and encryption of session data.
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)

with Ada.Strings.Unbounded;
with Trigger.Session.Account_Types;

package Trigger.Session.Session_Manager is

   --  Session manager type
   type Session_Manager_Type is tagged private;

   --  Initialize the session manager
   procedure Initialize (
      Manager : out Session_Manager_Type;
      Data_Dir : String
   );

   --  Finalize the session manager
   procedure Finalize (Manager : in out Session_Manager_Type);

   --  Generate a session name from phone number
   function Generate_Session_Name (Phone : String) return String;

   --  Create a new Telegram session
   procedure Create_Session (
      Manager : in out Session_Manager_Type;
      API_ID : Integer;
      API_Hash : String;
      Phone : String;
      Session_Name : String;
      Success : out Boolean;
      Error_Message : out Ada.Strings.Unbounded.Unbounded_String
   );

   --  Get a Telegram client for an account
   --  This would use Zig FFI to create the actual client
   --  Placeholder for now
   type Telegram_Client_Type is private;

   procedure Get_Client (
      Manager : Session_Manager_Type;
      API_ID : Integer;
      API_Hash : String;
      Account : Account_Types.Account;
      Client : out Telegram_Client_Type
   );

   --  Add an account to the manager
   procedure Add_Account (
      Manager : in out Session_Manager_Type;
      Phone : String;
      Session_Name : String
   );

   --  Remove an account from the manager
   function Remove_Account (
      Manager : in out Session_Manager_Type;
      Phone : String
   ) return Boolean;

   --  Get all accounts
   function Get_Accounts (
      Manager : Session_Manager_Type
   ) return Account_Types.Account_List;

   --  Get active accounts only
   function Get_Active_Accounts (
      Manager : Session_Manager_Type
   ) return Account_Types.Account_List;

   --  Mark an account as used (updates last_used and report_count)
   procedure Mark_Account_Used (
      Manager : in out Session_Manager_Type;
      Phone : String
   );

   --  Get an account by phone number
   function Get_Account (
      Manager : Session_Manager_Type;
      Phone : String
   ) return Account_Types.Account;

private

   --  Session manager record
   type Session_Manager_Type is tagged record
      Data_Directory : Ada.Strings.Unbounded.Unbounded_String;
      Accounts_File : Ada.Strings.Unbounded.Unbounded_String;
      Accounts : Account_Types.Account_List (1 .. 100);
      Account_Count : Natural := 0;
   end record;

   --  Placeholder for Telegram client
   type Telegram_Client_Type is record
      Session_Name : Ada.Strings.Unbounded.Unbounded_String;
      Initialized : Boolean := False;
   end record;

end Trigger.Session.Session_Manager;
