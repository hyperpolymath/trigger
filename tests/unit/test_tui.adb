--  Trigger - Unit Tests for TUI Module
--
--  Tests for the ADI TUI module.
--
--  Author: hyperpolymath

with Test_Harness;

package Test_TUI is

   use Test_Harness;

   --  Registry for TUI tests
   TUI_Registry : Test_Registry := Get_Registry;

   --  Test procedures
   procedure Test_Main_Menu_Display;
   procedure Test_Platform_Selection;
   procedure Test_Account_Management;
   procedure Test_Session_Management;
   procedure Test_Reporting_Flow;
   procedure Test_Diagnostics_Menu;

   --  Register all tests
   procedure Register_TUI_Tests;

   --  Run all TUI tests
   procedure Run_All_TUI_Tests;

end Test_TUI;
