--  Trigger - Main Application Entry Point
--  
--  Telegram channel reporting utility with multi-account management
--  
--  Author: hyperpolymath
--  
--  This is the main entry point for the Trigger application.
--  It provides both a comprehensive CLI and an ADI TUI (Advanced Dialog Interface).

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.Exceptions;

with Trigger.CLI.Argument_Parser;
with Trigger.CLI.Help_Generator;
with Trigger.CLI.Man_Page;
with Trigger.CLI.Version_Info;
with Trigger.TUI.Main_Menu;
with Trigger.Core.Application;
with Trigger.Diagnostics.System_Check;
with Trigger.Diagnostics.Self_Healing;

procedure Trigger is

   --  Application state
   App : Trigger.Core.Application.Application_Type;

begin
   --  Initialize application
   Trigger.Core.Application.Initialize (App);

   --  Parse command line arguments
   declare
      use Trigger.CLI;
      Args : Argument_Parser.Argument_List;
      Config : Argument_Parser.Configuration_Type;
      Mode : Argument_Parser.Execution_Mode;
      Exit_Code : Integer := 0;
   begin
      --  Parse arguments
      Argument_Parser.Parse_Arguments (Args, Config, Mode, Exit_Code);

      case Mode is
         when Argument_Parser.Mode_Help =>
            Help_Generator.Display_Help;
            
         when Argument_Parser.Mode_Man =>
            Man_Page.Display_Man_Page;
            
         when Argument_Parser.Mode_Version =>
            Version_Info.Display_Version;
            
         when Argument_Parser.Mode_License =>
            Version_Info.Display_License;
            
         when Argument_Parser.Mode_Diagnose =>
            System_Check.Run_Diagnostics (Config, Exit_Code);
            
         when Argument_Parser.Mode_Self_Heal =>
            Self_Healing.Run_Self_Healing (Config, Exit_Code);
            
         when Argument_Parser.Mode_Check_Deps =>
            System_Check.Check_Dependencies (Exit_Code);
            
         when Argument_Parser.Mode_Check_Config =>
            System_Check.Check_Configuration (Config, Exit_Code);
            
         when Argument_Parser.Mode_Check_Sessions =>
            System_Check.Check_Sessions (Config, Exit_Code);
            
         when Argument_Parser.Mode_Health =>
            System_Check.Run_Health_Check (Config, Exit_Code);
            
         when Argument_Parser.Mode_Fix_Config =>
            Self_Healing.Fix_Configuration (Config, Exit_Code);
            
         when Argument_Parser.Mode_Fix_Permissions =>
            Self_Healing.Fix_Permissions (Config, Exit_Code);
            
         when Argument_Parser.Mode_Fix_Sessions =>
            Self_Healing.Fix_Sessions (Config, Exit_Code);
            
         when Argument_Parser.Mode_TUI =>
            --  Launch ADI TUI
            Trigger.TUI.Main_Menu.Run (App, Config);
            
         when Argument_Parser.Mode_Execute =>
            --  Execute reporting operation
            Trigger.Core.Application.Execute_Reporting (App, Args, Config, Exit_Code);
            
         when Argument_Parser.Mode_Invalid =>
            Ada.Text_IO.Put_Line ("Error: Invalid arguments");
            Ada.Text_IO.Put_Line ("Try 'trigger --help' for usage information");
            Exit_Code := 1;
      end case;

      --  Cleanup and exit
      Trigger.Core.Application.Finalize (App);
      
      --  Exit with appropriate code
      if Exit_Code /= 0 then
         Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      else
         Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Success);
      end if;
      
   exception
      when E : others =>
         Ada.Text_IO.Put_Line ("ERROR: " & Ada.Exceptions.Exception_Message (E));
         Trigger.Core.Application.Finalize (App);
         Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end;

end Trigger;
