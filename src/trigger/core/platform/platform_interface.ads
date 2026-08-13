--
-- platform_interface.ads - Platform Interface for Trigger
--
-- This package defines the abstract interface that all platform implementations
-- must provide. This enables the core application to work with any supported
-- social media platform without knowing the specifics.
--
-- Architecture:
--   Core Application -> Platform_Interface -> Platform_Implementations
--
-- Original concept by 2nixx (T.me/NetworkCriminals)
-- Ada/SPARK implementation by hyperpolymath
--
-- License: MPL-2.0
-- SPDX-License-Identifier: MPL-2.0
--

with Platform_Types;

package Platform_Interface is

   -- Platform interface - all platform implementations must provide these operations
   type Platform_Interface is abstract tagged private interface
   with
      -- Platform information
      function Get_Platform return Platform_Type is abstract;
      function Get_Capabilities return Platform_Capabilities is abstract;
      
      -- Session management
      function Create_Session (Account : Account_Type) return Session_Type is abstract;
      procedure Destroy_Session (Session : in out Session_Type) is abstract;
      function Connect (Session : Session_Type) return Boolean is abstract;
      procedure Disconnect (Session : in out Session_Type) is abstract;
      function Is_Authorized (Session : Session_Type) return Boolean is abstract;
      function Refresh_Session (Session : Session_Type) return Session_Type is abstract;
      
      -- Account management
      function Get_Account (Session : Session_Type; Account_Id : String) return Account_Type is abstract;
      function List_Accounts (Session : Session_Type) return Account_Array is abstract;
      function Update_Account (Session : Session_Type; Account : Account_Type) return Account_Type is abstract;
      
      -- Message operations
      function Get_Messages (Session : Session_Type; Channel : String; Limit : Integer) return Message_Array is abstract;
      function Get_Message (Session : Session_Type; Channel : String; Message_Id : String) return Message_Type is abstract;
      
      -- Reporting operations
      function Report_Message (Session : Session_Type; Message : Message_Type; 
                                Reason : Report_Reason; Additional_Info : String) return Report_Result is abstract;
      function Report_Messages (Session : Session_Type; Messages : Message_Array;
                                 Reason : Report_Reason; Additional_Info : String) return Report_Array is abstract;
      
      -- Platform health
      function Ping return Boolean is abstract;
      function Get_Rate_Limits (Session : Session_Type) return Rate_Limit_Info is abstract;
   end interface;
   
   -- Array types for returning multiple items
   type Account_Array is array (1..100) of Account_Type;
   type Message_Array is array (1..1000) of Message_Type;
   type Report_Array is array (1..100) of Report_Result;

end Platform_Interface;
