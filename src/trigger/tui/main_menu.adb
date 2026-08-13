--  Trigger - TUI Main Menu Implementation
--  
--  Provides the ADI (Advanced Dialog Interface) TUI for interactive use.
--  Supports multi-platform social media management (Telegram, Discord, Twitter/X).
--  
--  This TUI integrates with the Platform_Factory to create platform instances
--  and perform actual operations on selected platforms.
--  
--  Author: hyperpolymath

with Ada.Text_IO;
with Ada.Strings.Unbounded;

with Platform_Types;
with Platform_Interface;

package body Trigger.TUI.Main_Menu is

   use Ada.Strings.Unbounded;

   --  Current platform instance (access type to allow null)
   Current_Platform : access Platform_Interface.Platform_Interface'Class := null;

   --  Current session
   Current_Session : Platform_Types.Session_Type;

   --  Current account
   Current_Account : Platform_Types.Account_Type;

   --  Current channel for reporting
   Current_Channel : Unbounded_String := Null_Unbounded_String;

   --  Convert CLI Platform_Type to Core Platform_Type
   function CLI_Platform_To_Core_Platform (
      CLI_Platform : Trigger.CLI.Argument_Parser.Platform_Type
   ) return Platform_Types.Platform_Type is
   begin
      case CLI_Platform is
         when Trigger.CLI.Argument_Parser.Platform_Telegram =>
            return Platform_Types.Telegram;
         when Trigger.CLI.Argument_Parser.Platform_Discord =>
            return Platform_Types.Discord;
         when Trigger.CLI.Argument_Parser.Platform_Twitter =>
            return Platform_Types.Twitter;
      end case;
   end CLI_Platform_To_Core_Platform;

   --  Initialize a platform instance based on config
   procedure Initialize_Platform (
      Config : Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
      Core_Platform : Platform_Types.Platform_Type;
      Session_Dir : String (1..256) := (others => ' ');
   begin
      --  Clean up existing platform
      if Current_Platform /= null then
         --  In a real implementation, we would clean up properly
         Current_Platform := null;
      end if;

      Core_Platform := CLI_Platform_To_Core_Platform (Config.Platform);
      
      --  Get session directory from config or use default
      if Ada.Strings.Unbounded.Length (Config.Session_Dir) > 0 then
         declare
            Sess_Dir : constant String := Ada.Strings.Unbounded.To_String (Config.Session_Dir);
         begin
            Session_Dir (1..Sess_Dir'Length) := Sess_Dir;
         end;
      end if;
      
      --  Create the platform instance
      case Core_Platform is
         when Platform_Types.Telegram =>
            Current_Platform := new Telegram_Platform.Platform_Implementation'(
               Telegram_Platform.Platform_Implementation'(
                  Telegram_Platform.Init (
                     Config.API_ID,
                     Ada.Strings.Unbounded.To_String (Config.API_Hash),
                     Session_Dir
                  )
               )
            );
         when Platform_Types.Discord =>
            Current_Platform := new Discord_Platform.Platform_Implementation;
         when Platform_Types.Twitter =>
            Current_Platform := new Twitter_Platform.Platform_Implementation;
         when others =>
            Current_Platform := null;
            Ada.Text_IO.Put_Line ("Error: Platform not yet implemented");
      end case;

      if Current_Platform /= null then
         Ada.Text_IO.Put_Line ("Platform initialized: " & 
            Platform_Types.Platform_Type'Image (Current_Platform.Get_Platform));
      end if;
   exception
      when others =>
         Ada.Text_IO.Put_Line ("Error: Failed to initialize platform");
         Current_Platform := null;
   end Initialize_Platform;

   --  Display the main menu
   procedure Display_Main_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("         Trigger - ADI TUI");
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Multi-Platform Social Media Reporting Utility");
      Ada.Text_IO.Put_Line ("Supported: Telegram, Discord, Twitter/X");
      Ada.Text_IO.Put_Line ("Multi-account management with persistent sessions");
      Ada.Text_IO.New_Line;
      
      --  Show current platform if set
      if Current_Platform /= null then
         Ada.Text_IO.Put_Line ("Current Platform: " & 
            Platform_Types.Platform_Type'Image (Current_Platform.Get_Platform));
      else
         Ada.Text_IO.Put_Line ("Current Platform: [None selected]");
      end if;
      
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Main Menu:");
      Ada.Text_IO.Put_Line ("---------");
      Ada.Text_IO.Put_Line ("1. Select Platform");
      Ada.Text_IO.Put_Line ("2. Platform Operations");
      Ada.Text_IO.Put_Line ("3. Account Management");
      Ada.Text_IO.Put_Line ("4. Session Management");
      Ada.Text_IO.Put_Line ("5. Reporting Settings");
      Ada.Text_IO.Put_Line ("6. Proxy Settings");
      Ada.Text_IO.Put_Line ("7. Diagnostics & Health");
      Ada.Text_IO.Put_Line ("8. Start Reporting");
      Ada.Text_IO.Put_Line ("0. Exit");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Enter your choice (0-8): ");
   end Display_Main_Menu;

   --  Display platform selection menu
   procedure Display_Platform_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("         Select Platform");
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Available Platforms:");
      Ada.Text_IO.Put_Line ("-------------------");
      Ada.Text_IO.Put_Line ("1. Telegram");
      Ada.Text_IO.Put_Line ("2. Discord");
      Ada.Text_IO.Put_Line ("3. Twitter/X");
      Ada.Text_IO.Put_Line ("4. Back to Main Menu");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Enter your choice (1-4): ");
   end Display_Platform_Menu;

   --  Display platform-specific operations menu
   procedure Display_Platform_Operations_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("      Platform Operations Menu");
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.New_Line;
      
      if Current_Platform = null then
         Ada.Text_IO.Put_Line ("Error: No platform selected!");
         Ada.Text_IO.Put_Line ("Please select a platform first.");
         return;
      end if;
      
      Ada.Text_IO.Put_Line ("Current Platform: " & 
         Platform_Types.Platform_Type'Image (Current_Platform.Get_Platform));
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Operations:");
      Ada.Text_IO.Put_Line ("----------");
      Ada.Text_IO.Put_Line ("1. Test Connection (Ping)");
      Ada.Text_IO.Put_Line ("2. Show Platform Capabilities");
      Ada.Text_IO.Put_Line ("3. Check Rate Limits");
      Ada.Text_IO.Put_Line ("4. Back to Main Menu");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Enter your choice (1-4): ");
   end Display_Platform_Operations_Menu;

   --  Helper to read a string from user
   function Read_String (Prompt : String) return String is
      Input : Unbounded_String;
   begin
      Ada.Text_IO.Put (Prompt & ": ");
      Input := To_Unbounded_String (Ada.Text_IO.Get_Line);
      return To_String (Input);
   end Read_String;

   --  Helper to read an integer from user
   function Read_Integer (Prompt : String) return Integer is
      Input : String (1..100);
      Last : Integer;
      Value : Integer;
   begin
      loop
         Ada.Text_IO.Put (Prompt & ": ");
         Ada.Text_IO.Get_Line (Input, Last);
         begin
            Value := Integer'Value (Input (1..Last));
            return Value;
         exception
            when others =>
               Ada.Text_IO.Put_Line ("Invalid integer. Please try again.");
         end;
      end loop;
   end Read_Integer;

   --  Handle platform operations
   procedure Handle_Platform_Operations (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
      Caps : Platform_Types.Platform_Capabilities;
      Rate_Limits : Platform_Types.Rate_Limit_Info;
      Success : Boolean;
   begin
      if Current_Platform = null then
         Ada.Text_IO.Put_Line ("Error: No platform selected!");
         return;
      end if;

      case Choice is
         when '1' =>  -- Ping
            Success := Current_Platform.Ping;
            if Success then
               Ada.Text_IO.Put_Line ("Platform ping: SUCCESS");
            else
               Ada.Text_IO.Put_Line ("Platform ping: FAILED");
            end if;
            
         when '2' =>  -- Capabilities
            Caps := Current_Platform.Get_Capabilities;
            Ada.Text_IO.Put_Line ("Platform Capabilities:");
            Ada.Text_IO.Put_Line ("  Supports Messaging: " & Boolean'Image (Caps.Supports_Messaging));
            Ada.Text_IO.Put_Line ("  Supports Reporting: " & Boolean'Image (Caps.Supports_Reporting));
            Ada.Text_IO.Put_Line ("  Supports Multi-Account: " & Boolean'Image (Caps.Supports_Multi_Account));
            Ada.Text_IO.Put_Line ("  Supports Session Persist: " & Boolean'Image (Caps.Supports_Session_Persist));
            Ada.Text_IO.Put_Line ("  Supports Rate Limit Info: " & Boolean'Image (Caps.Supports_Rate_Limit_Info));
            Ada.Text_IO.Put_Line ("  Supports Webhooks: " & Boolean'Image (Caps.Supports_Webhooks));
            Ada.Text_IO.Put_Line ("  Supports Search: " & Boolean'Image (Caps.Supports_Search));
            Ada.Text_IO.Put_Line ("  Supports Media Upload: " & Boolean'Image (Caps.Supports_Media_Upload));
            Ada.Text_IO.Put_Line ("  Supports Media Download: " & Boolean'Image (Caps.Supports_Media_Download));
            
         when '3' =>  -- Rate Limits
            Rate_Limits := Current_Platform.Get_Rate_Limits (Current_Session);
            Ada.Text_IO.Put_Line ("Rate Limits:");
            Ada.Text_IO.Put_Line ("  Remaining: " & Integer'Image (Rate_Limits.Remaining));
            Ada.Text_IO.Put_Line ("  Reset In: " & Integer'Image (Rate_Limits.Reset_In) & " seconds");
            Ada.Text_IO.Put_Line ("  Limit: " & Integer'Image (Rate_Limits.Limit));
            Ada.Text_IO.Put_Line ("  Retry After: " & Integer'Image (Rate_Limits.Retry_After) & " seconds");
            
         when '4' =>
            Ada.Text_IO.Put_Line ("Returning to main menu...");
            
         when others =>
            Ada.Text_IO.Put_Line ("Invalid choice. Please enter a number from 1 to 4.");
      end case;
   exception
      when others =>
         Ada.Text_IO.Put_Line ("Error: Operation failed");
   end Handle_Platform_Operations;

   --  Display account management menu
   procedure Display_Account_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("       Account Management Menu");
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.New_Line;
      
      if Current_Platform = null then
         Ada.Text_IO.Put_Line ("Error: No platform selected!");
         Ada.Text_IO.Put_Line ("Please select a platform first.");
         return;
      end if;
      
      Ada.Text_IO.Put_Line ("Current Platform: " & 
         Platform_Types.Platform_Type'Image (Current_Platform.Get_Platform));
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Account Operations:");
      Ada.Text_IO.Put_Line ("-------------------");
      Ada.Text_IO.Put_Line ("1. List Accounts");
      Ada.Text_IO.Put_Line ("2. Get Account Info");
      Ada.Text_IO.Put_Line ("3. Back to Main Menu");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Enter your choice (1-3): ");
   end Display_Account_Menu;

   --  Handle account management selection
   procedure Handle_Account_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
      Accounts : Platform_Interface.Account_Array;
      Account_Id : String (1..256);
      Account : Platform_Types.Account_Type;
   begin
      if Current_Platform = null then
         Ada.Text_IO.Put_Line ("Error: No platform selected!");
         return;
      end if;

      case Choice is
         when '1' =>  -- List Accounts
            Accounts := Current_Platform.List_Accounts (Current_Session);
            Ada.Text_IO.Put_Line ("Accounts:");
            for I in 1..Max_Accounts loop
               if Accounts (I).Active then
                  Ada.Text_IO.Put_Line ("  [" & Integer'Image (I) & "] " & 
                     Accounts (I).Display_Name & " (@" & Accounts (I).Identifier & ")");
               end if;
            end loop;
            
         when '2' =>  -- Get Account Info
            Account_Id := Read_String ("Enter account ID");
            Account := Current_Platform.Get_Account (Current_Session, Account_Id);
            Ada.Text_IO.Put_Line ("Account Info:");
            Ada.Text_IO.Put_Line ("  Platform: " & Platform_Types.Platform_Type'Image (Account.Platform));
            Ada.Text_IO.Put_Line ("  ID: " & Account.Identifier);
            Ada.Text_IO.Put_Line ("  Display Name: " & Account.Display_Name);
            Ada.Text_IO.Put_Line ("  Active: " & Boolean'Image (Account.Active));
            Ada.Text_IO.Put_Line ("  Verified: " & Boolean'Image (Account.Verified));
            Ada.Text_IO.Put_Line ("  Reports: " & Integer'Image (Account.Reports));
            Current_Account := Account;
            
         when '3' =>
            Ada.Text_IO.Put_Line ("Returning to main menu...");
            
         when others =>
            Ada.Text_IO.Put_Line ("Invalid choice. Please enter a number from 1 to 3.");
      end case;
   exception
      when others =>
         Ada.Text_IO.Put_Line ("Error: Account operation failed");
   end Handle_Account_Selection;

   --  Display session management menu
   procedure Display_Session_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("       Session Management Menu");
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.New_Line;
      
      if Current_Platform = null then
         Ada.Text_IO.Put_Line ("Error: No platform selected!");
         Ada.Text_IO.Put_Line ("Please select a platform first.");
         return;
      end if;
      
      Ada.Text_IO.Put_Line ("Current Platform: " & 
         Platform_Types.Platform_Type'Image (Current_Platform.Get_Platform));
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Session Operations:");
      Ada.Text_IO.Put_Line ("-------------------");
      Ada.Text_IO.Put_Line ("1. Create Session");
      Ada.Text_IO.Put_Line ("2. Test Session Connection");
      Ada.Text_IO.Put_Line ("3. Check Session Authorization");
      Ada.Text_IO.Put_Line ("4. Back to Main Menu");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Enter your choice (1-4): ");
   end Display_Session_Menu;

   --  Handle session management selection
   procedure Handle_Session_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
      Account_Identifier : String (1..256);
      Success : Boolean;
      Is_Auth : Boolean;
   begin
      if Current_Platform = null then
         Ada.Text_IO.Put_Line ("Error: No platform selected!");
         return;
      end if;

      case Choice is
         when '1' =>  -- Create Session
            Account_Identifier := Read_String ("Enter account identifier (phone/email)");
            declare
               Temp_Account : Platform_Types.Account_Type := 
                 (Platform => Current_Platform.Get_Platform, others => <>);
            begin
               --  Set the identifier
               Temp_Account.Identifier := Account_Identifier & (Account_Identifier'Length+1..256 => ' ');
               Current_Session := Current_Platform.Create_Session (Temp_Account);
               Ada.Text_IO.Put_Line ("Session created with ID: " & Current_Session.Session_Id);
            end;
            
         when '2' =>  -- Test Connection
            Success := Current_Platform.Connect (Current_Session);
            if Success then
               Ada.Text_IO.Put_Line ("Connection: SUCCESS");
            else
               Ada.Text_IO.Put_Line ("Connection: FAILED");
            end if;
            
         when '3' =>  -- Check Authorization
            Is_Auth := Current_Platform.Is_Authorized (Current_Session);
            if Is_Auth then
               Ada.Text_IO.Put_Line ("Authorization: AUTHORIZED");
            else
               Ada.Text_IO.Put_Line ("Authorization: NOT AUTHORIZED");
            end if;
            
         when '4' =>
            Ada.Text_IO.Put_Line ("Returning to main menu...");
            
         when others =>
            Ada.Text_IO.Put_Line ("Invalid choice. Please enter a number from 1 to 4.");
      end case;
   exception
      when others =>
         Ada.Text_IO.Put_Line ("Error: Session operation failed");
   end Handle_Session_Selection;

   --  Display reporting menu
   procedure Display_Reporting_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("        Reporting Settings Menu");
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Reporting Configuration:");
      Ada.Text_IO.Put_Line ("------------------------");
      Ada.Text_IO.Put_Line ("1. Set Target Channel");
      Ada.Text_IO.Put_Line ("2. Set Report Count");
      Ada.Text_IO.Put_Line ("3. Set Report Delay");
      Ada.Text_IO.Put_Line ("4. Set Report Reason");
      Ada.Text_IO.Put_Line ("5. Test Reporting (Dry Run)");
      Ada.Text_IO.Put_Line ("6. Back to Main Menu");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Enter your choice (1-6): ");
   end Display_Reporting_Menu;

   --  Handle reporting selection
   procedure Handle_Reporting_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
      Channel : String (1..256);
      Count : Integer;
      Delay_Input : String (1..20);
      Last : Integer;
      Reason_Num : Integer;
      Messages : Platform_Interface.Message_Array;
   begin
      case Choice is
         when '1' =>  -- Set Channel
            Channel := Read_String ("Enter channel name");
            Current_Channel := To_Unbounded_String (Channel);
            Ada.Text_IO.Put_Line ("Channel set to: " & Channel);
            
         when '2' =>  -- Set Report Count
            Count := Read_Integer ("Enter report count");
            Config.Report_Count := Count;
            Ada.Text_IO.Put_Line ("Report count set to: " & Integer'Image (Count));
            
         when '3' =>  -- Set Delay
            Ada.Text_IO.Put ("Enter delay (seconds): ");
            Ada.Text_IO.Get_Line (Delay_Input, Last);
            Config.Delay := Float'Value (Delay_Input (1..Last));
            Ada.Text_IO.Put_Line ("Delay set to: " & Float'Image (Config.Delay));
            
         when '4' =>  -- Set Reason
            Ada.Text_IO.Put_Line ("Select report reason:");
            Ada.Text_IO.Put_Line ("  1. Spam");
            Ada.Text_IO.Put_Line ("  2. Violence");
            Ada.Text_IO.Put_Line ("  3. Pornography");
            Ada.Text_IO.Put_Line ("  4. Copyright");
            Ada.Text_IO.Put_Line ("  5. Privacy");
            Ada.Text_IO.Put_Line ("  6. Scam");
            Ada.Text_IO.Put_Line ("  7. Other");
            Reason_Num := Read_Integer ("Enter reason number");
            case Reason_Num is
               when 1 => Config.Report_Reason := Trigger.CLI.Argument_Parser.Reason_Spam;
               when 2 => Config.Report_Reason := Trigger.CLI.Argument_Parser.Reason_Violence;
               when 3 => Config.Report_Reason := Trigger.CLI.Argument_Parser.Reason_Pornography;
               when 4 => Config.Report_Reason := Trigger.CLI.Argument_Parser.Reason_Copyright;
               when 5 => Config.Report_Reason := Trigger.CLI.Argument_Parser.Reason_Privacy;
               when 6 => Config.Report_Reason := Trigger.CLI.Argument_Parser.Reason_Scam;
               when others => Config.Report_Reason := Trigger.CLI.Argument_Parser.Reason_Other;
            end case;
            Ada.Text_IO.Put_Line ("Reason set to: " & 
               Trigger.CLI.Argument_Parser.Report_Reason'Image (Config.Report_Reason));
            
         when '5' =>  -- Dry Run
            if Current_Platform = null then
               Ada.Text_IO.Put_Line ("Error: No platform selected!");
               return;
            end if;
            if Length (Current_Channel) = 0 then
               Ada.Text_IO.Put_Line ("Error: No channel selected!");
               return;
            end if;
            
            Messages := Current_Platform.Get_Messages (
               Current_Session, To_String (Current_Channel), Config.Report_Count);
            
            Ada.Text_IO.Put_Line ("Dry Run - Would report " & Integer'Image (Config.Report_Count) & 
               " messages from channel: " & To_String (Current_Channel));
            Ada.Text_IO.Put_Line ("Reason: " & 
               Trigger.CLI.Argument_Parser.Report_Reason'Image (Config.Report_Reason));
            
            --  For each message, show what would be reported
            for I in 1..Config.Report_Count loop
               if Messages (I).Id /= (1..128 => ' ') then
                  Ada.Text_IO.Put_Line ("  [" & Integer'Image (I) & "] Message ID: " & 
                     Messages (I).Id & " - Content: " & Messages (I).Content (1..50) & "...");
               end if;
            end loop;
            
         when '6' =>
            Ada.Text_IO.Put_Line ("Returning to main menu...");
            
         when others =>
            Ada.Text_IO.Put_Line ("Invalid choice. Please enter a number from 1 to 6.");
      end case;
   exception
      when others =>
         Ada.Text_IO.Put_Line ("Error: Invalid input");
   end Handle_Reporting_Selection;

   --  Display diagnostics menu
   procedure Display_Diagnostics_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("      Diagnostics & Self-Healing Menu");
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Diagnostic Options:");
      Ada.Text_IO.Put_Line ("-------------------");
      Ada.Text_IO.Put_Line ("1. Ping Platform");
      Ada.Text_IO.Put_Line ("2. Run Full Diagnostics");
      Ada.Text_IO.Put_Line ("3. Run Self-Healing");
      Ada.Text_IO.Put_Line ("4. Check Dependencies");
      Ada.Text_IO.Put_Line ("5. Health Check");
      Ada.Text_IO.Put_Line ("6. Back to Main Menu");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Enter your choice (1-6): ");
   end Display_Diagnostics_Menu;

   --  Handle diagnostics selection
   procedure Handle_Diagnostics_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
      Diag_Exit_Code : Integer;
      Heal_Exit_Code : Integer;
      Success : Boolean;
   begin
      case Choice is
         when '1' =>  -- Ping
            if Current_Platform = null then
               Ada.Text_IO.Put_Line ("Error: No platform selected!");
               return;
            end if;
            Success := Current_Platform.Ping;
            if Success then
               Ada.Text_IO.Put_Line ("Platform ping: SUCCESS");
            else
               Ada.Text_IO.Put_Line ("Platform ping: FAILED");
            end if;
            
         when '2' =>  -- Full Diagnostics
            Trigger.Diagnostics.System_Check.Run_Diagnostics (Config, Diag_Exit_Code);
            
         when '3' =>  -- Self-Healing
            Trigger.Diagnostics.Self_Healing.Run_Self_Healing (Config, Heal_Exit_Code);
            
         when '4' =>  -- Check Dependencies
            Trigger.Diagnostics.System_Check.Check_Dependencies (Diag_Exit_Code);
            
         when '5' =>  -- Health Check
            Trigger.Diagnostics.System_Check.Run_Health_Check (Config, Diag_Exit_Code);
            
         when '6' =>
            Ada.Text_IO.Put_Line ("Returning to main menu...");
            
         when others =>
            Ada.Text_IO.Put_Line ("Invalid choice. Please enter a number from 1 to 6.");
      end case;
   end Handle_Diagnostics_Selection;

   --  Handle platform selection
   procedure Handle_Platform_Selection (
      Choice : Character;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
   begin
      case Choice is
         when '1' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Platform set to Telegram");
            Config.Platform := Trigger.CLI.Argument_Parser.Platform_Telegram;
            Initialize_Platform (Config);
            
         when '2' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Platform set to Discord");
            Config.Platform := Trigger.CLI.Argument_Parser.Platform_Discord;
            Initialize_Platform (Config);
            
         when '3' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Platform set to Twitter/X");
            Config.Platform := Trigger.CLI.Argument_Parser.Platform_Twitter;
            Initialize_Platform (Config);
            
         when '4' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Returning to main menu...");
            
         when others =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Invalid choice. Please enter a number from 1 to 4.");
      end case;
   end Handle_Platform_Selection;

   --  Handle menu selection
   procedure Handle_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
   begin
      case Choice is
         when '1' =>  -- Select Platform
            Ada.Text_IO.New_Line;
            Display_Platform_Menu;
            declare
               Platform_Choice : Character;
            begin
               Ada.Text_IO.Get (Platform_Choice);
               --  Consume the newline
               while Ada.Text_IO.End_Of_Line loop
                  null;
               end loop;
               Handle_Platform_Selection (Platform_Choice, Config);
            end;
            
         when '2' =>  -- Platform Operations
            Ada.Text_IO.New_Line;
            Display_Platform_Operations_Menu;
            declare
               Op_Choice : Character;
            begin
               Ada.Text_IO.Get (Op_Choice);
               while Ada.Text_IO.End_Of_Line loop
                  null;
               end loop;
               Handle_Platform_Operations (Op_Choice, App, Config);
            end;
            
         when '3' =>  -- Account Management
            Ada.Text_IO.New_Line;
            Display_Account_Menu;
            declare
               Acct_Choice : Character;
            begin
               Ada.Text_IO.Get (Acct_Choice);
               while Ada.Text_IO.End_Of_Line loop
                  null;
               end loop;
               Handle_Account_Selection (Acct_Choice, App, Config);
            end;
            
         when '4' =>  -- Session Management
            Ada.Text_IO.New_Line;
            Display_Session_Menu;
            declare
               Sess_Choice : Character;
            begin
               Ada.Text_IO.Get (Sess_Choice);
               while Ada.Text_IO.End_Of_Line loop
                  null;
               end loop;
               Handle_Session_Selection (Sess_Choice, App, Config);
            end;
            
         when '5' =>  -- Reporting Settings
            Ada.Text_IO.New_Line;
            Display_Reporting_Menu;
            declare
               Rpt_Choice : Character;
            begin
               Ada.Text_IO.Get (Rpt_Choice);
               while Ada.Text_IO.End_Of_Line loop
                  null;
               end loop;
               Handle_Reporting_Selection (Rpt_Choice, App, Config);
            end;
            
         when '6' =>  -- Proxy Settings
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Proxy Settings");
            Ada.Text_IO.Put_Line ("---------------");
            Ada.Text_IO.Put_Line ("[Placeholder: Interactive proxy settings would be here]");
            Ada.Text_IO.Put_Line ("Use CLI flags: --proxy, --no-proxy");
            
         when '7' =>  -- Diagnostics
            Ada.Text_IO.New_Line;
            Display_Diagnostics_Menu;
            declare
               Diag_Choice : Character;
            begin
               Ada.Text_IO.Get (Diag_Choice);
               while Ada.Text_IO.End_Of_Line loop
                  null;
               end loop;
               Handle_Diagnostics_Selection (Diag_Choice, App, Config);
            end;
            
         when '8' =>  -- Start Reporting
            if Current_Platform = null then
               Ada.Text_IO.New_Line;
               Ada.Text_IO.Put_Line ("Error: No platform selected!");
               Ada.Text_IO.Put_Line ("Please select a platform first.");
            elsif Length (Current_Channel) = 0 then
               Ada.Text_IO.New_Line;
               Ada.Text_IO.Put_Line ("Error: No channel selected!");
               Ada.Text_IO.Put_Line ("Please set a channel first.");
            else
               Ada.Text_IO.New_Line;
               Ada.Text_IO.Put_Line ("Starting Reporting...");
               Ada.Text_IO.Put_Line ("Platform: " & 
                  Platform_Types.Platform_Type'Image (Current_Platform.Get_Platform));
               Ada.Text_IO.Put_Line ("Channel: " & To_String (Current_Channel));
               Ada.Text_IO.Put_Line ("Count: " & Integer'Image (Config.Report_Count));
               Ada.Text_IO.Put_Line ("Reason: " & 
                  Trigger.CLI.Argument_Parser.Report_Reason'Image (Config.Report_Reason));
               Ada.Text_IO.New_Line;
               
               --  Convert CLI Report_Reason to Platform_Types.Report_Reason
               declare
                  Core_Reason : Platform_Types.Report_Reason;
                  Messages : Platform_Interface.Message_Array;
                  Results : Platform_Interface.Report_Array;
                  Success_Count : Integer := 0;
                  Channel_Name : constant String := To_String (Current_Channel);
               begin
                  --  Map CLI reason to core reason
                  case Config.Report_Reason is
                     when Trigger.CLI.Argument_Parser.Reason_Spam =>
                        Core_Reason := Platform_Types.Spam;
                     when Trigger.CLI.Argument_Parser.Reason_Violence =>
                        Core_Reason := Platform_Types.Violence;
                     when Trigger.CLI.Argument_Parser.Reason_Pornography =>
                        Core_Reason := Platform_Types.Sexual_Content;
                     when Trigger.CLI.Argument_Parser.Reason_Copyright =>
                        Core_Reason := Platform_Types.Copyright_Infringement;
                     when Trigger.CLI.Argument_Parser.Reason_Privacy =>
                        Core_Reason := Platform_Types.Custom_Reason;  -- No Privacy in Platform_Types
                     when Trigger.CLI.Argument_Parser.Reason_Scam =>
                        Core_Reason := Platform_Types.Scam;
                     when Trigger.CLI.Argument_Parser.Reason_Other =>
                        Core_Reason := Platform_Types.Custom_Reason;
                  end case;
                  
                  --  Get messages from the channel
                  Ada.Text_IO.Put_Line ("Fetching messages...");
                  Messages := Current_Platform.Get_Messages (
                     Current_Session, Channel_Name, Config.Report_Count);
                  
                  --  Report each message
                  Ada.Text_IO.Put_Line ("Reporting messages...");
                  Results := Current_Platform.Report_Messages (
                     Current_Session, Messages, Core_Reason, "Reported via Trigger TUI");
                  
                  --  Display results
                  for I in 1..Config.Report_Count loop
                     if Results (I).Success then
                        Success_Count := Success_Count + 1;
                        Ada.Text_IO.Put_Line ("  [" & Integer'Image (I) & "] " & 
                           "SUCCESS - " & Results (I).Message);
                     else
                        Ada.Text_IO.Put_Line ("  [" & Integer'Image (I) & "] " & 
                           "FAILED - " & Results (I).Message);
                     end if;
                  end loop;
                  
                  Ada.Text_IO.New_Line;
                  Ada.Text_IO.Put_Line ("Reporting complete: " & 
                     Integer'Image (Success_Count) & "/" & 
                     Integer'Image (Config.Report_Count) & " successful");
               end;
            end if;
            
         when '0' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Exiting...");
            
         when others =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Invalid choice. Please enter a number from 0 to 8.");
      end case;
   end Handle_Selection;

   --  Run the ADI TUI main menu
   procedure Run (
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
      Choice : Character;
      Local_Config : Trigger.CLI.Argument_Parser.Configuration_Type := Config;
   begin
      --  Initialize platform if one is already selected
      Initialize_Platform (Local_Config);
      
      loop
         Display_Main_Menu;
         
         --  Read user input
         begin
            Ada.Text_IO.Get (Choice);
            --  Consume the newline
            while Ada.Text_IO.End_Of_Line loop
               null;
            end loop;
         exception
            when others =>
               --  Clear input buffer on error
               Ada.Text_IO.Skip_Line;
               Choice := ' ';
         end;
         
         Handle_Selection (Choice, App, Local_Config);
         
         --  Exit on choice 0
         exit when Choice = '0';
      end loop;
   end Run;

end Trigger.TUI.Main_Menu;
