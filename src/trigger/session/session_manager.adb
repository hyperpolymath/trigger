--  Trigger - Session Manager Implementation
--  
--  Implements session management for multiple Telegram accounts.

with Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
with Ada.Direct_IO;
with Ada.Text_IO;

with Trigger.Session.Account_Types;

package body Trigger.Session.Session_Manager is

   --  Internal function to save accounts to file
   procedure Save_Accounts (Manager : Session_Manager_Type);

   --  Internal function to load accounts from file
   procedure Load_Accounts (Manager : in out Session_Manager_Type);

   --  Internal function to ensure directories exist
   procedure Ensure_Directories (Manager : Session_Manager_Type);

   procedure Initialize (
      Manager : out Session_Manager_Type;
      Data_Dir : String
   ) is
   begin
      Manager.Data_Directory := Ada.Strings.Unbounded.To_Unbounded_String (Data_Dir);
      Manager.Accounts_File := Ada.Strings.Unbounded.To_Unbounded_String (
         Data_Dir & "/accounts.json");
      Manager.Account_Count := 0;
      
      Ensure_Directories (Manager);
      Load_Accounts (Manager);
   end Initialize;

   procedure Finalize (Manager : in out Session_Manager_Type) is
   begin
      Save_Accounts (Manager);
   end Finalize;

   function Generate_Session_Name (Phone : String) return String is
      Cleaned : String (1 .. Phone'Length);
      Index : Natural := 0;
   begin
      --  Remove '+' and spaces from phone number
      for I in Phone'Range loop
         if Phone (I) /= '+' and Phone (I) /= ' ' then
            Index := Index + 1;
            Cleaned (Index) := Phone (I);
         end if;
      end loop;
      
      return "session_" & Cleaned (1 .. Index);
   end Generate_Session_Name;

   procedure Ensure_Directories (Manager : Session_Manager_Type) is
      use Ada.Strings.Unbounded;
   begin
      --  In a full implementation, this would create the directory
      --  For now, we assume it exists
      null;
   end Ensure_Directories;

   procedure Load_Accounts (Manager : in out Session_Manager_Type) is
      --  In a full implementation, this would parse the JSON file
      --  For now, we start with empty accounts
   begin
      Manager.Account_Count := 0;
   end Load_Accounts;

   procedure Save_Accounts (Manager : Session_Manager_Type) is
      --  In a full implementation, this would write JSON
      --  For now, we skip
   begin
      null;
   end Save_Accounts;

   procedure Create_Session (
      Manager : in out Session_Manager_Type;
      API_ID : Integer;
      API_Hash : String;
      Phone : String;
      Session_Name : String;
      Success : out Boolean;
      Error_Message : out Ada.Strings.Unbounded.Unbounded_String
   ) is
      --  This would use Zig FFI to create a Telegram session
      --  For now, we simulate success
   begin
      --  In a real implementation, this would call Zig code via FFI
      --  to create a TelegramClient session
      
      --  Simulate success
      Success := True;
      Error_Message := Ada.Strings.Unbounded.To_Unbounded_String ("");
      
      --  Note: Actual implementation would use:
      --  pragma Import (C, Create_Telegram_Session, "create_telegram_session");
      --  which would be implemented in Zig via unified-hexadeca-api
   end Create_Session;

   procedure Get_Client (
      Manager : Session_Manager_Type;
      API_ID : Integer;
      API_Hash : String;
      Account : Account_Types.Account;
      Client : out Telegram_Client_Type
   ) is
   begin
      Client.Session_Name := Ada.Strings.Unbounded.To_Unbounded_String (
         Account_Types.Get_Session_Name (Account));
      Client.Initialized := True;
      
      --  In a real implementation, this would load the session
      --  using Zig FFI and handle decryption if needed
   end Get_Client;

   procedure Add_Account (
      Manager : in out Session_Manager_Type;
      Phone : String;
      Session_Name : String
   ) is
   begin
      if Manager.Account_Count < Manager.Accounts'Length then
         Manager.Account_Count := Manager.Account_Count + 1;
         Manager.Accounts (Manager.Account_Count) := 
            Account_Types.Create_Account (Phone, Session_Name);
         Save_Accounts (Manager);
      end if;
   end Add_Account;

   function Remove_Account (
      Manager : in out Session_Manager_Type;
      Phone : String
   ) return Boolean is
      Found : Boolean := False;
   begin
      for I in 1 .. Manager.Account_Count loop
         if Account_Types.Get_Phone (Manager.Accounts (I)) = Phone then
            --  Shift remaining accounts
            for J in I .. Manager.Account_Count - 1 loop
               Manager.Accounts (J) := Manager.Accounts (J + 1);
            end loop;
            Manager.Account_Count := Manager.Account_Count - 1;
            Found := True;
            exit;
         end if;
      end loop;
      
      if Found then
         Save_Accounts (Manager);
      end if;
      
      return Found;
   end Remove_Account;

   function Get_Accounts (
      Manager : Session_Manager_Type
   ) return Account_Types.Account_List is
   begin
      return Manager.Accounts (1 .. Manager.Account_Count);
   end Get_Accounts;

   function Get_Active_Accounts (
      Manager : Session_Manager_Type
   ) return Account_Types.Account_List is
      Count : Natural := 0;
   begin
      --  Count active accounts
      for I in 1 .. Manager.Account_Count loop
         if Account_Types.Is_Active (Manager.Accounts (I)) then
            Count := Count + 1;
         end if;
      end loop;
      
      --  Return active accounts
      declare
         Result : Account_Types.Account_List (1 .. Count);
         Index : Natural := 0;
      begin
         for I in 1 .. Manager.Account_Count loop
            if Account_Types.Is_Active (Manager.Accounts (I)) then
               Index := Index + 1;
               Result (Index) := Manager.Accounts (I);
            end if;
         end loop;
         return Result;
      end;
   end Get_Active_Accounts;

   procedure Mark_Account_Used (
      Manager : in out Session_Manager_Type;
      Phone : String
   ) is
   begin
      for I in 1 .. Manager.Account_Count loop
         if Account_Types.Get_Phone (Manager.Accounts (I)) = Phone then
            Account_Types.Mark_Used (Manager.Accounts (I));
            Save_Accounts (Manager);
            exit;
         end if;
      end loop;
   end Mark_Account_Used;

   function Get_Account (
      Manager : Session_Manager_Type;
      Phone : String
   ) return Account_Types.Account is
   begin
      for I in 1 .. Manager.Account_Count loop
         if Account_Types.Get_Phone (Manager.Accounts (I)) = Phone then
            return Manager.Accounts (I);
         end if;
      end loop;
      
      --  Return default account if not found
      return Account_Types.Create_Account ("", "");
   end Get_Account;

end Trigger.Session.Session_Manager;
