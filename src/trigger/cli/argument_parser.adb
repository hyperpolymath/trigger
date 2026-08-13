--  Trigger - CLI Argument Parser Implementation
--  
--  Handles command-line argument parsing with extensive flags and options.
--  
--  Author: hyperpolymath

with Ada.Text_IO;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;
with Ada.Command_Line;

package body Trigger.CLI.Argument_Parser is

   use Ada.Strings.Unbounded;
   use Ada.Command_Line;

   --  Helper function to check if a string starts with a prefix
   function Starts_With (S : String; Prefix : String) return Boolean is
   begin
      if S'Length < Prefix'Length then
         return False;
      end if;
      return S (S'First .. S'First + Prefix'Length - 1) = Prefix;
   end Starts_With;

   --  Helper function to convert string to Log_Level
   function String_To_Log_Level (S : String) return Log_Level is
   begin
      if S = "debug" or S = "DEBUG" then
         return Log_Debug;
      elsif S = "info" or S = "INFO" then
         return Log_Info;
      elsif S = "warning" or S = "WARNING" then
         return Log_Warning;
      elsif S = "error" or S = "ERROR" then
         return Log_Error;
      else
         return Log_Info;  -- Default
      end if;
   end String_To_Log_Level;

   --  Helper function to convert string to Report_Reason
   function String_To_Report_Reason (S : String) return Report_Reason is
   begin
      if S = "spam" or S = "SPAM" then
         return Reason_Spam;
      elsif S = "violence" or S = "VIOLENCE" then
         return Reason_Violence;
      elsif S = "pornography" or S = "PORNOGRAPHY" then
         return Reason_Pornography;
      elsif S = "copyright" or S = "COPYRIGHT" then
         return Reason_Copyright;
      elsif S = "privacy" or S = "PRIVACY" then
         return Reason_Privacy;
      elsif S = "scam" or S = "SCAM" then
         return Reason_Scam;
      else
         return Reason_Other;
      end if;
   end String_To_Report_Reason;

   --  Helper function to check if a string is a valid integer
   function Is_Integer (S : String) return Boolean is
      use Ada.Strings;
   begin
      if S'Length = 0 then
         return False;
      end if;
      for I in S'Range loop
         if not (S (I) in '0' .. '9' | '+') then
            return False;
         end if;
      end loop;
      return True;
   exception
      when others =>
         return False;
   end Is_Integer;

   --  Helper function to check if a string is a valid float
   function Is_Float (S : String) return Boolean is
   begin
      if S'Length = 0 then
         return False;
      end if;
      for I in S'Range loop
         if not (S (I) in '0' .. '9' | '.' | '+' | '-') then
            return False;
         end if;
      end loop;
      return True;
   exception
      when others =>
         return False;
   end Is_Float;

   --  Parse command line arguments
   procedure Parse_Arguments (
      Args : out Argument_List;
      Config : out Configuration_Type;
      Mode : out Execution_Mode;
      Exit_Code : out Integer
   ) is
      Arg_Count : constant Integer := Ada.Command_Line.Argument_Count;

      --  Reset configuration to defaults
      Config : Configuration_Type := Configuration_Type'(
         Show_Help => False,
         Show_Man => False,
         Show_Version => False,
         Show_License => False,
         Config_File => To_Unbounded_String (""),
         Save_Config => False,
         Reset_Config => False,
         API_ID => 0,
         API_Hash => To_Unbounded_String (""),
         Set_Credentials => False,
         Session_Dir => To_Unbounded_String (""),
         List_Sessions => False,
         Clean_Sessions => False,
         Proxy_URL => To_Unbounded_String (""),
         No_Proxy => False,
         Log_Level => Log_Info,
         Log_File => To_Unbounded_String (""),
         No_Color => False,
         Quiet => False,
         Specific_Account => To_Unbounded_String (""),
         All_Accounts => False,
         List_Accounts => False,
         Add_Account => False,
         Remove_Account => To_Unbounded_String (""),
         Channel => To_Unbounded_String (""),
         List_Channels => False,
         Report_Count => 3,
         Delay => 2.0,
         Report_Reason => Reason_Spam,
         Dry_Run => False,
         Encrypt => False,
         Decrypt => False,
         Salt => To_Unbounded_String (""),
         Password => To_Unbounded_String (""),
         Diagnose => False,
         Self_Heal => False,
         Check_Dependencies => False,
         Check_Configuration => False,
         Check_Sessions => False,
         Health_Check => False,
         Fix_Config => False,
         Fix_Permissions => False,
         Fix_Sessions => False
      );

      --  Temporary arrays to hold arguments
      Temp_Args : array (1 .. Arg_Count) of Unbounded_String;
      Current_Arg_Index : Integer := 0;

      --  Set default mode to TUI (interactive mode)
      Mode := Mode_TUI;
      Exit_Code := 0;

      --  If no arguments, keep mode as TUI
      if Arg_Count = 0 then
         Args := Temp_Args (1 .. 0);
         return;
      end if;

      --  Parse arguments using index variable for proper skipping
      --  We use a while loop with manual index management
      J : Integer := 1;
      while J <= Arg_Count loop
         declare
            Arg : constant String := Ada.Command_Line.Argument (J);
         begin
            Current_Arg_Index := Current_Arg_Index + 1;

            --  Informational flags
            if Arg = "-h" or Arg = "--help" then
               Config.Show_Help := True;
               Mode := Mode_Help;
               J := J + 1;
            elsif Arg = "--man" then
               Config.Show_Man := True;
               Mode := Mode_Man;
               J := J + 1;
            elsif Arg = "-v" or Arg = "--version" then
               Config.Show_Version := True;
               Mode := Mode_Version;
               J := J + 1;
            elsif Arg = "--license" then
               Config.Show_License := True;
               Mode := Mode_License;
               J := J + 1;

            --  Configuration flags
            elsif Arg = "-c" or Arg = "--config" then
               if J < Arg_Count then
                  Config.Config_File := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --config requires a file argument");
                  J := J + 1;
               end if;
            elsif Arg = "--save-config" then
               Config.Save_Config := True;
               J := J + 1;
            elsif Arg = "--reset-config" then
               Config.Reset_Config := True;
               J := J + 1;

            --  API credentials flags
            elsif Arg = "-a" or Arg = "--api-id" then
               if J < Arg_Count then
                  begin
                     Config.API_ID := Integer'Value (Ada.Command_Line.Argument (J + 1));
                     J := J + 2;
                  exception
                     when others =>
                        Exit_Code := 1;
                        Ada.Text_IO.Put_Line ("Error: --api-id requires a valid integer");
                        J := J + 1;
                  end;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --api-id requires an integer argument");
                  J := J + 1;
               end if;
            elsif Arg = "--api-hash" then
               if J < Arg_Count then
                  Config.API_Hash := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --api-hash requires a string argument");
                  J := J + 1;
               end if;
            elsif Arg = "--set-credentials" then
               Config.Set_Credentials := True;
               J := J + 1;

            --  Session flags
            elsif Arg = "-s" or Arg = "--session-dir" then
               if J < Arg_Count then
                  Config.Session_Dir := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --session-dir requires a directory argument");
                  J := J + 1;
               end if;
            elsif Arg = "--list-sessions" then
               Config.List_Sessions := True;
               Mode := Mode_Execute;
               J := J + 1;
            elsif Arg = "--clean-sessions" then
               Config.Clean_Sessions := True;
               Mode := Mode_Execute;
               J := J + 1;

            --  Proxy flags
            elsif Arg = "-p" or Arg = "--proxy" then
               if J < Arg_Count then
                  Config.Proxy_URL := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --proxy requires a URL argument");
                  J := J + 1;
               end if;
            elsif Arg = "--no-proxy" then
               Config.No_Proxy := True;
               J := J + 1;

            --  Logging flags
            elsif Arg = "-l" or Arg = "--log-level" then
               if J < Arg_Count then
                  Config.Log_Level := String_To_Log_Level (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --log-level requires a level argument");
                  J := J + 1;
               end if;
            elsif Arg = "--log-file" then
               if J < Arg_Count then
                  Config.Log_File := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --log-file requires a file argument");
                  J := J + 1;
               end if;
            elsif Arg = "--no-color" then
               Config.No_Color := True;
               J := J + 1;
            elsif Arg = "--quiet" then
               Config.Quiet := True;
               J := J + 1;

            --  Account flags
            elsif Arg = "-A" or Arg = "--account" then
               if J < Arg_Count then
                  Config.Specific_Account := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --account requires a phone number argument");
                  J := J + 1;
               end if;
            elsif Arg = "--all-accounts" then
               Config.All_Accounts := True;
               J := J + 1;
            elsif Arg = "--list-accounts" then
               Config.List_Accounts := True;
               Mode := Mode_Execute;
               J := J + 1;
            elsif Arg = "--add-account" then
               Config.Add_Account := True;
               Mode := Mode_Execute;
               J := J + 1;
            elsif Arg = "--remove-account" then
               if J < Arg_Count then
                  Config.Remove_Account := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --remove-account requires a phone number argument");
                  J := J + 1;
               end if;

            --  Reporting flags
            elsif Arg = "-C" or Arg = "--channel" then
               if J < Arg_Count then
                  Config.Channel := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --channel requires a channel name argument");
                  J := J + 1;
               end if;
            elsif Arg = "--list-channels" then
               Config.List_Channels := True;
               Mode := Mode_Execute;
               J := J + 1;
            elsif Arg = "-n" or Arg = "--report-count" then
               if J < Arg_Count then
                  begin
                     Config.Report_Count := Integer'Value (Ada.Command_Line.Argument (J + 1));
                     J := J + 2;
                  exception
                     when others =>
                        Exit_Code := 1;
                        Ada.Text_IO.Put_Line ("Error: --report-count requires a valid integer");
                        J := J + 1;
                  end;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --report-count requires an integer argument");
                  J := J + 1;
               end if;
            elsif Arg = "--delay" then
               if J < Arg_Count then
                  begin
                     Config.Delay := Float'Value (Ada.Command_Line.Argument (J + 1));
                     J := J + 2;
                  exception
                     when others =>
                        Exit_Code := 1;
                        Ada.Text_IO.Put_Line ("Error: --delay requires a valid float");
                        J := J + 1;
                  end;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --delay requires a float argument");
                  J := J + 1;
               end if;
            elsif Arg = "--reason" then
               if J < Arg_Count then
                  Config.Report_Reason := String_To_Report_Reason (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --reason requires a reason argument");
                  J := J + 1;
               end if;
            elsif Arg = "--dry-run" then
               Config.Dry_Run := True;
               J := J + 1;

            --  Encryption flags
            elsif Arg = "-e" or Arg = "--encrypt" then
               Config.Encrypt := True;
               J := J + 1;
            elsif Arg = "--decrypt" then
               Config.Decrypt := True;
               J := J + 1;
            elsif Arg = "--salt" then
               if J < Arg_Count then
                  Config.Salt := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --salt requires a salt value argument");
                  J := J + 1;
               end if;
            elsif Arg = "--password" then
               if J < Arg_Count then
                  Config.Password := To_Unbounded_String (Ada.Command_Line.Argument (J + 1));
                  J := J + 2;
               else
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: --password requires a password argument");
                  J := J + 1;
               end if;

            --  Diagnostic and healing flags
            elsif Arg = "--diagnose" then
               Config.Diagnose := True;
               Mode := Mode_Diagnose;
               J := J + 1;
            elsif Arg = "--self-heal" then
               Config.Self_Heal := True;
               Mode := Mode_Self_Heal;
               J := J + 1;
            elsif Arg = "--check-deps" then
               Config.Check_Dependencies := True;
               Mode := Mode_Check_Deps;
               J := J + 1;
            elsif Arg = "--check-config" then
               Config.Check_Configuration := True;
               Mode := Mode_Check_Config;
               J := J + 1;
            elsif Arg = "--check-sessions" then
               Config.Check_Sessions := True;
               Mode := Mode_Check_Sessions;
               J := J + 1;
            elsif Arg = "--health" then
               Config.Health_Check := True;
               Mode := Mode_Health;
               J := J + 1;
            elsif Arg = "--fix-config" then
               Config.Fix_Config := True;
               Mode := Mode_Fix_Config;
               J := J + 1;
            elsif Arg = "--fix-permissions" then
               Config.Fix_Permissions := True;
               Mode := Mode_Fix_Permissions;
               J := J + 1;
            elsif Arg = "--fix-sessions" then
               Config.Fix_Sessions := True;
               Mode := Mode_Fix_Sessions;
               J := J + 1;

            --  TUI mode (explicit)
            elsif Arg = "--tui" then
               Mode := Mode_TUI;
               J := J + 1;

            --  Unknown argument
            else
               if Starts_With (Arg, "-") then
                  Exit_Code := 1;
                  Ada.Text_IO.Put_Line ("Error: Unknown option: " & Arg);
                  Mode := Mode_Invalid;
               else
                  --  Positional argument (non-flag), store it
                  Temp_Args (Current_Arg_Index) := To_Unbounded_String (Arg);
               end if;
               J := J + 1;
            end if;
         end;
      end loop;

      --  Set Args to the collected non-flag arguments
      Args := Temp_Args (1 .. Current_Arg_Index);

      --  Determine final mode based on flags
      if Config.Show_Help then
         Mode := Mode_Help;
      elsif Config.Show_Man then
         Mode := Mode_Man;
      elsif Config.Show_Version then
         Mode := Mode_Version;
      elsif Config.Show_License then
         Mode := Mode_License;
      elsif Config.Diagnose then
         Mode := Mode_Diagnose;
      elsif Config.Self_Heal then
         Mode := Mode_Self_Heal;
      elsif Config.Check_Dependencies then
         Mode := Mode_Check_Deps;
      elsif Config.Check_Configuration then
         Mode := Mode_Check_Config;
      elsif Config.Check_Sessions then
         Mode := Mode_Check_Sessions;
      elsif Config.Health_Check then
         Mode := Mode_Health;
      elsif Config.Fix_Config then
         Mode := Mode_Fix_Config;
      elsif Config.Fix_Permissions then
         Mode := Mode_Fix_Permissions;
      elsif Config.Fix_Sessions then
         Mode := Mode_Fix_Sessions;
      elsif Config.List_Sessions or Config.Clean_Sessions or
            Config.List_Accounts or Config.Add_Account or
            Config.List_Channels or
            (Length (Config.Remove_Account) > 0) then
         Mode := Mode_Execute;
      else
         --  Default mode
         Mode := Mode_TUI;
      end if;

   end Parse_Arguments;

   --  Display parsed configuration
   procedure Display_Configuration (Config : Configuration_Type) is
   begin
      Ada.Text_IO.Put_Line ("CLI Configuration:");
      Ada.Text_IO.Put_Line ("  Informational:");
      Ada.Text_IO.Put_Line ("    Show_Help: " & Boolean'Image (Config.Show_Help));
      Ada.Text_IO.Put_Line ("    Show_Man: " & Boolean'Image (Config.Show_Man));
      Ada.Text_IO.Put_Line ("    Show_Version: " & Boolean'Image (Config.Show_Version));
      Ada.Text_IO.Put_Line ("    Show_License: " & Boolean'Image (Config.Show_License));
      Ada.Text_IO.Put_Line ("  Configuration:");
      Ada.Text_IO.Put_Line ("    Config_File: " & To_String (Config.Config_File));
      Ada.Text_IO.Put_Line ("    Save_Config: " & Boolean'Image (Config.Save_Config));
      Ada.Text_IO.Put_Line ("    Reset_Config: " & Boolean'Image (Config.Reset_Config));
      Ada.Text_IO.Put_Line ("  API:");
      Ada.Text_IO.Put_Line ("    API_ID: " & Integer'Image (Config.API_ID));
      Ada.Text_IO.Put_Line ("    Set_Credentials: " & Boolean'Image (Config.Set_Credentials));
      Ada.Text_IO.Put_Line ("  Session:");
      Ada.Text_IO.Put_Line ("    Session_Dir: " & To_String (Config.Session_Dir));
      Ada.Text_IO.Put_Line ("    List_Sessions: " & Boolean'Image (Config.List_Sessions));
      Ada.Text_IO.Put_Line ("    Clean_Sessions: " & Boolean'Image (Config.Clean_Sessions));
      Ada.Text_IO.Put_Line ("  Proxy:");
      Ada.Text_IO.Put_Line ("    Proxy_URL: " & To_String (Config.Proxy_URL));
      Ada.Text_IO.Put_Line ("    No_Proxy: " & Boolean'Image (Config.No_Proxy));
      Ada.Text_IO.Put_Line ("  Logging:");
      Ada.Text_IO.Put_Line ("    Log_Level: " & Log_Level'Image (Config.Log_Level));
      Ada.Text_IO.Put_Line ("    Log_File: " & To_String (Config.Log_File));
      Ada.Text_IO.Put_Line ("    No_Color: " & Boolean'Image (Config.No_Color));
      Ada.Text_IO.Put_Line ("    Quiet: " & Boolean'Image (Config.Quiet));
      Ada.Text_IO.Put_Line ("  Account:");
      Ada.Text_IO.Put_Line ("    Specific_Account: " & To_String (Config.Specific_Account));
      Ada.Text_IO.Put_Line ("    All_Accounts: " & Boolean'Image (Config.All_Accounts));
      Ada.Text_IO.Put_Line ("    List_Accounts: " & Boolean'Image (Config.List_Accounts));
      Ada.Text_IO.Put_Line ("    Add_Account: " & Boolean'Image (Config.Add_Account));
      Ada.Text_IO.Put_Line ("  Reporting:");
      Ada.Text_IO.Put_Line ("    Channel: " & To_String (Config.Channel));
      Ada.Text_IO.Put_Line ("    List_Channels: " & Boolean'Image (Config.List_Channels));
      Ada.Text_IO.Put_Line ("    Report_Count: " & Integer'Image (Config.Report_Count));
      Ada.Text_IO.Put_Line ("    Delay: " & Float'Image (Config.Delay));
      Ada.Text_IO.Put_Line ("    Report_Reason: " & Report_Reason'Image (Config.Report_Reason));
      Ada.Text_IO.Put_Line ("    Dry_Run: " & Boolean'Image (Config.Dry_Run));
      Ada.Text_IO.Put_Line ("  Encryption:");
      Ada.Text_IO.Put_Line ("    Encrypt: " & Boolean'Image (Config.Encrypt));
      Ada.Text_IO.Put_Line ("    Decrypt: " & Boolean'Image (Config.Decrypt));
      Ada.Text_IO.Put_Line ("  Diagnostics:");
      Ada.Text_IO.Put_Line ("    Diagnose: " & Boolean'Image (Config.Diagnose));
      Ada.Text_IO.Put_Line ("    Check_Dependencies: " & Boolean'Image (Config.Check_Dependencies));
      Ada.Text_IO.Put_Line ("    Check_Configuration: " & Boolean'Image (Config.Check_Configuration));
      Ada.Text_IO.Put_Line ("    Check_Sessions: " & Boolean'Image (Config.Check_Sessions));
      Ada.Text_IO.Put_Line ("    Health_Check: " & Boolean'Image (Config.Health_Check));
      Ada.Text_IO.Put_Line ("    Self_Heal: " & Boolean'Image (Config.Self_Heal));
      Ada.Text_IO.Put_Line ("    Fix_Config: " & Boolean'Image (Config.Fix_Config));
      Ada.Text_IO.Put_Line ("    Fix_Permissions: " & Boolean'Image (Config.Fix_Permissions));
      Ada.Text_IO.Put_Line ("    Fix_Sessions: " & Boolean'Image (Config.Fix_Sessions));
   end Display_Configuration;

   --  Validate configuration
   function Validate_Configuration (Config : Configuration_Type) return Boolean is
   begin
      --  Check for mutually exclusive encryption flags
      if Config.Encrypt and Config.Decrypt then
         Ada.Text_IO.Put_Line ("Error: Cannot specify both --encrypt and --decrypt");
         return False;
      end if;

      --  Check for required encryption parameters
      if (Config.Encrypt or Config.Decrypt) and Length (Config.Password) = 0 then
         Ada.Text_IO.Put_Line ("Error: --encrypt or --decrypt requires --password");
         return False;
      end if;

      --  Check report count is positive
      if Config.Report_Count <= 0 then
         Ada.Text_IO.Put_Line ("Error: --report-count must be positive");
         return False;
      end if;

      --  Check delay is non-negative
      if Config.Delay < 0.0 then
         Ada.Text_IO.Put_Line ("Error: --delay must be non-negative");
         return False;
      end if;

      return True;
   end Validate_Configuration;

end Trigger.CLI.Argument_Parser;
