--  Trigger - TUI Main Menu Specification
--  
--  Provides the ADI (Advanced Dialog Interface) TUI for interactive use.
--  Supports multi-platform social media management (Telegram, Discord, Twitter).
--  
--  This TUI integrates with the Platform_Factory to create platform instances
--  and perform actual operations on selected platforms.
--  
--  Author: hyperpolymath

with Trigger.Core.Application;
with Trigger.CLI.Argument_Parser;
with Platform_Types;
with Platform_Interface;

package Trigger.TUI.Main_Menu is

   --  Maximum number of accounts to display
   Max_Accounts : constant Integer := 10;

   --  Maximum number of messages to display
   Max_Messages : constant Integer := 20;

   --  Run the ADI TUI main menu
   procedure Run (
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Display the main menu
   procedure Display_Main_Menu;

   --  Display platform selection menu
   procedure Display_Platform_Menu;

   --  Display platform-specific menu
   procedure Display_Platform_Operations_Menu;

   --  Display account management menu
   procedure Display_Account_Menu;

   --  Display session management menu
   procedure Display_Session_Menu;

   --  Display reporting menu
   procedure Display_Reporting_Menu;

   --  Display diagnostics menu
   procedure Display_Diagnostics_Menu;

   --  Handle menu selection
   procedure Handle_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Handle platform selection
   procedure Handle_Platform_Selection (
      Choice : Character;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Handle platform operations selection
   procedure Handle_Platform_Operations (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Handle account management selection
   procedure Handle_Account_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Handle session management selection
   procedure Handle_Session_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Handle reporting selection
   procedure Handle_Reporting_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Handle diagnostics selection
   procedure Handle_Diagnostics_Selection (
      Choice : Character;
      App : in out Trigger.Core.Application.Application_Type;
      Config : in out Trigger.CLI.Argument_Parser.Configuration_Type
   );

   --  Convert CLI Platform_Type to Core Platform_Type
   function CLI_Platform_To_Core_Platform (
      CLI_Platform : Trigger.CLI.Argument_Parser.Platform_Type
   ) return Platform_Types.Platform_Type;

end Trigger.TUI.Main_Menu;
