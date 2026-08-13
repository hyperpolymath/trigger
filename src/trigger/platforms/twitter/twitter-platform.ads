--
-- twitter-platform.ads - Twitter Platform Implementation
--
-- This package provides the Twitter/X-specific implementation of the
-- Platform_Interface.
--
-- Original concept by 2nixx (T.me/NetworkCriminals)
-- Ada/SPARK implementation by hyperpolymath
--
-- License: MPL-2.0
-- SPDX-License-Identifier: MPL-2.0
--

with Platform_Types;
with Platform_Interface;

package Twitter_Platform is

   -- Twitter-specific types
   type Twitter_Id_Type is range 0..2**64-1;
   
   -- Twitter platform implementation
   type Platform_Implementation is new Platform_Interface.Platform_Interface with
   private
      Bearer_Token : String(1..256);
      Api_Url : String(1..128);
   end record;
   
   -- Override operations from Platform_Interface
   overriding
      function Get_Platform return Platform_Type;
      function Get_Capabilities return Platform_Capabilities;
      
      function Create_Session (Account : Account_Type) return Session_Type;
      procedure Destroy_Session (Session : in out Session_Type);
      function Connect (Session : Session_Type) return Boolean;
      procedure Disconnect (Session : in out Session_Type);
      function Is_Authorized (Session : Session_Type) return Boolean;
      function Refresh_Session (Session : Session_Type) return Session_Type;
      
      function Get_Account (Session : Session_Type; Account_Id : String) return Account_Type;
      function List_Accounts (Session : Session_Type) return Platform_Interface.Account_Array;
      function Update_Account (Session : Session_Type; Account : Account_Type) return Account_Type;
      
      function Get_Messages (Session : Session_Type; Channel : String; Limit : Integer) return Platform_Interface.Message_Array;
      function Get_Message (Session : Session_Type; Channel : String; Message_Id : String) return Message_Type;
      
      function Report_Message (Session : Session_Type; Message : Message_Type;
                                Reason : Report_Reason; Additional_Info : String) return Report_Result;
      function Report_Messages (Session : Session_Type; Messages : Platform_Interface.Message_Array;
                                 Reason : Report_Reason; Additional_Info : String) return Platform_Interface.Report_Array;
      
      function Ping return Boolean;
      function Get_Rate_Limits (Session : Session_Type) return Rate_Limit_Info;

end Twitter_Platform;
