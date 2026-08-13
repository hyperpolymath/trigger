--  Trigger - TUI Main Menu Implementation
--  
--  Provides the ADI (Advanced Dialog Interface) TUI for interactive use.
--  
--  Author: hyperpolymath

with Ada.Text_IO;
with Ada.Strings.Unbounded;

package body Trigger.TUI.Main_Menu is

   use Ada.Strings.Unbounded;

   --  Display the main menu
   procedure Display_Main_Menu is
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("         Trigger - ADI TUI");
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Telegram Channel Reporting Utility");
      Ada.Text_IO.Put_Line ("Multi-account management with persistent sessions");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Main Menu:");
      Ada.Text_IO.Put_Line ("---------");
      Ada.Text_IO.Put_Line ("1. Configure API Credentials");
      Ada.Text_IO.Put_Line ("2. Manage Accounts");
      Ada.Text_IO.Put_Line ("3. Manage Sessions");
      Ada.Text_IO.Put_Line ("4. Reporting Settings");
      Ada.Text_IO.Put_Line ("5. Proxy Settings");
      Ada.Text_IO.Put_Line ("6. Run Diagnostics");
      Ada.Text_IO.Put_Line ("7. Run Self-Healing");
      Ada.Text_IO.Put_Line ("8. Start Reporting");
      Ada.Text_IO.Put_Line ("9. Exit");
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put ("Enter your choice (1-9): ");
   end Display_Main_Menu;

   --  Handle menu selection
   procedure Handle_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
   begin
      case Choice is
         when '1' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("API Credentials Configuration");
            Ada.Text_IO.Put_Line ("-----------------------------");
            Ada.Text_IO.Put_Line ("[Placeholder: Interactive API credential setup would be here]");
            Ada.Text_IO.Put_Line ("Use CLI flags: --api-id, --api-hash, --set-credentials");
            
         when '2' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Account Management");
            Ada.Text_IO.Put_Line ("------------------");
            Ada.Text_IO.Put_Line ("[Placeholder: Interactive account management would be here]");
            Ada.Text_IO.Put_Line ("Use CLI flags: --add-account, --remove-account, --list-accounts");
            
         when '3' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Session Management");
            Ada.Text_IO.Put_Line ("-------------------");
            Ada.Text_IO.Put_Line ("[Placeholder: Interactive session management would be here]");
            Ada.Text_IO.Put_Line ("Use CLI flags: --list-sessions, --clean-sessions");
            
         when '4' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Reporting Settings");
            Ada.Text_IO.Put_Line ("------------------");
            Ada.Text_IO.Put_Line ("[Placeholder: Interactive reporting settings would be here]");
            Ada.Text_IO.Put_Line ("Use CLI flags: --channel, --report-count, --delay, --reason");
            
         when '5' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Proxy Settings");
            Ada.Text_IO.Put_Line ("---------------");
            Ada.Text_IO.Put_Line ("[Placeholder: Interactive proxy settings would be here]");
            Ada.Text_IO.Put_Line ("Use CLI flags: --proxy, --no-proxy");
            
         when '6' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Running Diagnostics...");
            declare
               Diag_Exit_Code : Integer;
            begin
               Trigger.Diagnostics.System_Check.Run_Diagnostics (Config, Diag_Exit_Code);
            end;
            
         when '7' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Running Self-Healing...");
            declare
               Heal_Exit_Code : Integer;
            begin
               Trigger.Diagnostics.Self_Healing.Run_Self_Healing (Config, Heal_Exit_Code);
            end;
            
         when '8' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Starting Reporting...");
            Ada.Text_IO.Put_Line ("[Placeholder: Reporting functionality would be here]");
            Ada.Text_IO.Put_Line ("Use CLI flags for non-interactive reporting");
            
         when '9' =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Exiting...");
            
         when others =>
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Invalid choice. Please enter a number from 1 to 9.");
      end case;
   end Handle_Selection;

   --  Run the ADI TUI main menu
   procedure Run (
      App : in out Trigger.Core.Application.Application_Type;
      Config : Trigger.CLI.Argument_Parser.Configuration_Type
   ) is
      Choice : Character;
      Local_Config : Trigger.CLI.Argument_Parser.Configuration_Type := Config;
   begin
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
         
         --  Exit on choice 9
         exit when Choice = '9';
      end loop;
   end Run;

end Trigger.TUI.Main_Menu;
