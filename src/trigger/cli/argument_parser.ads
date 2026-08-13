--  Trigger - CLI Argument Parser Specification
--  
--  Handles command-line argument parsing with extensive flags and options.
--  
--  Author: hyperpolymath

with Ada.Strings.Unbounded;

package Trigger.CLI.Argument_Parser is

   --  Execution modes
   type Execution_Mode is (
      Mode_Help,
      Mode_Man,
      Mode_Version,
      Mode_License,
      Mode_List_Platforms,
      Mode_Diagnose,
      Mode_Self_Heal,
      Mode_Check_Deps,
      Mode_Check_Config,
      Mode_Check_Sessions,
      Mode_Health,
      Mode_Fix_Config,
      Mode_Fix_Permissions,
      Mode_Fix_Sessions,
      Mode_TUI,
      Mode_Execute,
      Mode_Invalid
   );

   --  Log level type
   type Log_Level is (Log_Debug, Log_Info, Log_Warning, Log_Error);

   --  Report reason type
   type Report_Reason is (
      Reason_Spam,
      Reason_Violence,
      Reason_Pornography,
      Reason_Copyright,
      Reason_Privacy,
      Reason_Scam,
      Reason_Other
   );

   --  Platform type
   type Platform_Type is (Platform_Telegram, Platform_Discord, Platform_Twitter);

   --  Configuration record for CLI options
   type Configuration_Type is tagged record
      --  Informational
      Show_Help : Boolean := False;
      Show_Man : Boolean := False;
      Show_Version : Boolean := False;
      Show_License : Boolean := False;
      
      --  Configuration file
      Config_File : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      Save_Config : Boolean := False;
      Reset_Config : Boolean := False;
      
      --  API credentials
      API_ID : Integer := 0;
      API_Hash : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      Set_Credentials : Boolean := False;
      
      --  Session settings
      Session_Dir : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      List_Sessions : Boolean := False;
      Clean_Sessions : Boolean := False;
      
      --  Proxy settings
      Proxy_URL : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      No_Proxy : Boolean := False;
      
      --  Logging settings
      Log_Level : Log_Level := Log_Info;
      Log_File : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      No_Color : Boolean := False;
      Quiet : Boolean := False;
      
      --  Platform selection
      Platform : Platform_Type := Platform_Telegram;
      List_Platforms : Boolean := False;
      Discord_Token : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      Twitter_Token : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      
      --  Account settings
      Specific_Account : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      All_Accounts : Boolean := False;
      List_Accounts : Boolean := False;
      Add_Account : Boolean := False;
      Remove_Account : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      
      --  Reporting settings
      Channel : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      List_Channels : Boolean := False;
      Report_Count : Integer := 3;
      Delay : Float := 2.0;
      Report_Reason : Report_Reason := Reason_Spam;
      Dry_Run : Boolean := False;
      
      --  Encryption settings
      Encrypt : Boolean := False;
      Decrypt : Boolean := False;
      Salt : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      Password : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      
      --  Diagnostic/healing flags
      Diagnose : Boolean := False;
      Self_Heal : Boolean := False;
      Check_Dependencies : Boolean := False;
      Check_Configuration : Boolean := False;
      Check_Sessions : Boolean := False;
      Health_Check : Boolean := False;
      Fix_Config : Boolean := False;
      Fix_Permissions : Boolean := False;
      Fix_Sessions : Boolean := False;
   end record;

   --  Argument list type
   type Argument_List is array (Positive range <>) of 
     Ada.Strings.Unbounded.Unbounded_String;

   --  Parse command line arguments
   procedure Parse_Arguments (
      Args : out Argument_List;
      Config : out Configuration_Type;
      Mode : out Execution_Mode;
      Exit_Code : out Integer
   );

   --  Display parsed configuration (for debugging)
   procedure Display_Configuration (Config : Configuration_Type);

   --  Validate configuration
   function Validate_Configuration (Config : Configuration_Type) return Boolean;

end Trigger.CLI.Argument_Parser;
