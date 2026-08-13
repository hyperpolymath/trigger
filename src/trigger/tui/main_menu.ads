--  Trigger - TUI Main Menu Specification
--  
--  Provides the ADI (Advanced Dialog Interface) TUI for interactive use.
--  
--  Author: hyperpolymath

with Trigger.Core.Application;
with Trigger.CLI.Argument_Parser;

package Trigger.TUI.Main_Menu is

   --  Run the ADI TUI main menu
   procedure Run (
      App : in out Trigger.Core.Application.Application_Type;
      Config : Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Display the main menu
   procedure Display_Main_Menu;

   --  Handle menu selection
   procedure Handle_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

end Trigger.TUI.Main_Menu;
