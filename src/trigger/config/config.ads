--  Trigger - Configuration Package Specification
--  
--  Manages application configuration including API credentials,
--  session settings, proxy configuration, and logging preferences.
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)

with Ada.Strings.Unbounded;

package Trigger.Config is

   --  Configuration record type
   type Configuration is tagged private;

   --  Default session directory
   Default_Session_Directory : constant String := "./sessions";

   --  Default configuration file name
   Config_File_Name : constant String := "config.json";

   --  Load configuration from file
   procedure Load (Config : out Configuration);

   --  Save configuration to file
   procedure Save (Config : Configuration);

   --  Get default configuration
   function Get_Default return Configuration;

private

   --  Configuration record
   type Configuration is tagged record
      --  Telegram API credentials
      API_ID : Integer := 0;
      API_Hash : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("");
      
      --  Session settings
      Session_Directory : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String (Default_Session_Directory);
      
      --  Reporting defaults
      Default_Message_Count : Integer := 3;
      Default_Delay : Float := 2.0;
      Default_Report_Option : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("spam");
      
      --  Proxy configuration
      Proxy_Enabled : Boolean := False;
      Proxy_Type : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("socks5");
      Proxy_Host : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("127.0.0.1");
      Proxy_Port : Integer := 1080;
      
      --  Encryption settings
      Encrypt_Sessions : Boolean := False;
      Crypto_Salt : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("static_salt_placeholder");
      
      --  Logging settings
      Log_Level : Ada.Strings.Unbounded.Unbounded_String := 
        Ada.Strings.Unbounded.To_Unbounded_String ("INFO");
      Log_Colorized : Boolean := True;
   end record;

end Trigger.Config;
