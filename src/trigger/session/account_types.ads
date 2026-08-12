--  Trigger - Account Types Specification
--  
--  Defines the data types for Telegram account management.
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)

with Ada.Strings.Unbounded;
with Ada.Calendar;

package Trigger.Session.Account_Types is

   --  Account type representing a Telegram account
   type Account is tagged private;

   --  Array of accounts
   type Account_List is array (Positive range <>) of aliased Account;

   --  Get account phone number
   function Get_Phone (A : Account) return String;

   --  Get session name
   function Get_Session_Name (A : Account) return String;

   --  Check if account is active
   function Is_Active (A : Account) return Boolean;

   --  Get creation timestamp
   function Get_Created_At (A : Account) return Ada.Calendar.Time;

   --  Get last used timestamp
   function Get_Last_Used (A : Account) return Ada.Calendar.Time;

   --  Get report count
   function Get_Report_Count (A : Account) return Natural;

   --  Set account as active/inactive
   procedure Set_Active (A : in out Account; Value : Boolean);

   --  Increment report count
   procedure Increment_Report_Count (A : in out Account);

   --  Set last used to current time
   procedure Mark_Used (A : in out Account);

   --  Create a new account
   function Create_Account (
      Phone : String;
      Session_Name : String
   ) return Account;

private

   --  Account record
   type Account is tagged record
      Phone : Ada.Strings.Unbounded.Unbounded_String;
      Session_Name : Ada.Strings.Unbounded.Unbounded_String;
      Is_Active : Boolean := True;
      Created_At : Ada.Calendar.Time := Ada.Calendar.Clock;
      Last_Used : Ada.Calendar.Time := Ada.Calendar.Clock_Epoch;
      Report_Count : Natural := 0;
   end record;

end Trigger.Session.Account_Types;
