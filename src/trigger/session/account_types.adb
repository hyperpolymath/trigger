--  Trigger - Account Types Implementation
--  
--  Implements the account data types for Telegram account management.

with Ada.Strings.Unbounded;
with Ada.Calendar;

package body Trigger.Session.Account_Types is

   function Get_Phone (A : Account) return String is
   begin
      return Ada.Strings.Unbounded.To_String (A.Phone);
   end Get_Phone;

   function Get_Session_Name (A : Account) return String is
   begin
      return Ada.Strings.Unbounded.To_String (A.Session_Name);
   end Get_Session_Name;

   function Is_Active (A : Account) return Boolean is
   begin
      return A.Is_Active;
   end Is_Active;

   function Get_Created_At (A : Account) return Ada.Calendar.Time is
   begin
      return A.Created_At;
   end Get_Created_At;

   function Get_Last_Used (A : Account) return Ada.Calendar.Time is
   begin
      return A.Last_Used;
   end Get_Last_Used;

   function Get_Report_Count (A : Account) return Natural is
   begin
      return A.Report_Count;
   end Get_Report_Count;

   procedure Set_Active (A : in out Account; Value : Boolean) is
   begin
      A.Is_Active := Value;
   end Set_Active;

   procedure Increment_Report_Count (A : in out Account) is
   begin
      A.Report_Count := A.Report_Count + 1;
   end Increment_Report_Count;

   procedure Mark_Used (A : in out Account) is
   begin
      A.Last_Used := Ada.Calendar.Clock;
      A.Report_Count := A.Report_Count + 1;
   end Mark_Used;

   function Create_Account (
      Phone : String;
      Session_Name : String
   ) return Account is
   begin
      return Account'(
         Phone => Ada.Strings.Unbounded.To_Unbounded_String (Phone),
         Session_Name => Ada.Strings.Unbounded.To_Unbounded_String (Session_Name),
         Is_Active => True,
         Created_At => Ada.Calendar.Clock,
         Last_Used => Ada.Calendar.Clock_Epoch,
         Report_Count => 0
      );
   end Create_Account;

end Trigger.Session.Account_Types;
