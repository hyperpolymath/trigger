--
-- platform_types.ads - Platform Type Definitions for Trigger
--
-- This package defines the core types for multi-platform social media support.
--
-- Architecture:
--   Platform Types (this file) <- Platform Interface <- Platform Implementations
--
-- Original concept by 2nixx (T.me/NetworkCriminals)
-- Ada/SPARK implementation by hyperpolymath
--
-- License: MPL-2.0
-- SPDX-License-Identifier: MPL-2.0
--

package Platform_Types is

   -- Platform identifier
   type Platform_Type is (Telegram, Discord, Twitter, Instagram, Reddit, 
                          Facebook, YouTube, TikTok, LinkedIn, Custom);
   
   -- Error types
   type Error_Type is (Network_Error, Auth_Error, Rate_Limit_Error, Not_Found_Error,
                       Permission_Error, Platform_Error, Unknown_Error);
   
   -- Capabilities
   type Platform_Capabilities is record
      Supports_Messaging     : Boolean;
      Supports_Reporting     : Boolean;
      Supports_Multi_Account : Boolean;
      Supports_Session_Persist : Boolean;
      Supports_Rate_Limit_Info : Boolean;
      Supports_Webhooks      : Boolean;
      Supports_Search        : Boolean;
      Supports_Media_Upload  : Boolean;
      Supports_Media_Download : Boolean;
   end record;
   
   -- Session type
   type Session_Type is record
      Platform      : Platform_Type;
      Session_Id    : String(1..256);
      Access_Token  : String(1..1024);
      Refresh_Token : String(1..1024);
      Token_Expires : Integer;
      Encrypted     : Boolean;
   end record;
   
   -- Account type
   type Account_Type is record
      Platform    : Platform_Type;
      Identifier  : String(1..256);
      Display_Name : String(1..256);
      Active      : Boolean;
      Verified    : Boolean;
      Created_At  : Integer;
      Last_Used_At : Integer;
      Reports     : Integer;
   end record;
   
   -- Message type
   type Message_Type is record
      Platform    : Platform_Type;
      Id          : String(1..128);
      Content     : String(1..4096);
      Author      : Account_Type;
      Timestamp   : Integer;
      Channel     : String(1..256);
   end record;
   
   -- Rate limit info
   type Rate_Limit_Info is record
      Remaining  : Integer;
      Reset_In   : Integer;
      Limit      : Integer;
      Retry_After : Integer;
   end record;
   
   -- Report reason
   type Report_Reason is (Spam, Scam, Harassment, Violence, Hate_Speech,
                         Sexual_Content, Misinformation, Illegal_Activity,
                         Copyright_Infringement, Self_Harm, Custom_Reason);
   
   -- Report status
   type Report_Status is (Pending, In_Review, Approved, Rejected, Appealable);
   
   -- Report result
   type Report_Result is record
      Success     : Boolean;
      Status      : Report_Status;
      Report_Id   : String(1..128);
      Message     : String(1..512);
      Cooldown    : Integer;
   end record;

end Platform_Types;
