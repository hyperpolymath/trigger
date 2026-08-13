--  Trigger - Twitter/X FFI Bindings Specification
--  
--  Ada bindings for Twitter/X API via Zig FFI (unified-hexadeca-api)
--  
--  This package provides the interface for calling Twitter/X functions
--  implemented in Zig through C-exported symbols.
--  
--  Author: hyperpolymath
--  Architecture: Ada/SPARK <- Idris2 <- Zig (FFI)
--  License: MPL-2.0
--  SPDX-License-Identifier: MPL-2.0

package Trigger.FFI.Twitter is

   --  Twitter client handle (opaque pointer from Zig)
   type Twitter_Client_Ptr is access all Integer;

   --  Twitter message/tweet handle
   type Twitter_Tweet_Ptr is access all Integer;

   --  Twitter user handle
   type Twitter_User_Ptr is access all Integer;

   --  Maximum string lengths
   Max_Username_Length : constant := 15;  -- X/Twitter username limit
   Max_Tweet_Length : constant := 280;    -- X/Twitter tweet character limit
   Max_DM_Length : constant := 10000;    -- Direct message limit

   --  Twitter Snowflake type (64-bit ID)
   type Snowflake is mod 2**64;

   --  Create a Twitter client
   function Create_Client (
      Bearer_Token : String;
      Api_Key : String;
      Api_Secret : String
   ) return Twitter_Client_Ptr
     with Import, Convention => C, External_Name => "create_twitter_client";

   --  Destroy a Twitter client
   procedure Destroy_Client (Client : Twitter_Client_Ptr)
     with Import, Convention => C, External_Name => "destroy_twitter_client";

   --  Get current user
   function Get_Me (Client : Twitter_Client_Ptr) return Twitter_User_Ptr
     with Import, Convention => C, External_Name => "twitter_client_get_me";

   --  Get tweets from a user timeline
   function Get_Tweets (
      Client : Twitter_Client_Ptr;
      User_Id : String;
      Limit : Integer
   ) return Twitter_Tweet_Ptr
     with Import, Convention => C, External_Name => "twitter_client_get_tweets";

   --  Get direct messages
   function Get_DMs (
      Client : Twitter_Client_Ptr;
      Limit : Integer
   ) return Twitter_Tweet_Ptr
     with Import, Convention => C, External_Name => "twitter_client_get_dms";

   --  Report a tweet
   procedure Report_Tweet (
      Client : Twitter_Client_Ptr;
      Tweet_Id : Snowflake;
      Reason : Integer
   )
     with Import, Convention => C, External_Name => "twitter_client_report_tweet";

   --  Report a user
   procedure Report_User (
      Client : Twitter_Client_Ptr;
      User_Id : String;
      Reason : Integer
   )
     with Import, Convention => C, External_Name => "twitter_client_report_user";

   --  Send a tweet
   function Send_Tweet (
      Client : Twitter_Client_Ptr;
      Content : String
   ) return Twitter_Tweet_Ptr
     with Import, Convention => C, External_Name => "twitter_client_send_tweet";

   --  Ping the Twitter API
   function Ping (Client : Twitter_Client_Ptr) return Integer
     with Import, Convention => C, External_Name => "twitter_client_ping";

end Trigger.FFI.Twitter;
