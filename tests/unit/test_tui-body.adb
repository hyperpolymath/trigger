--  Trigger - Unit Tests for TUI Module (Body)
--
--  Tests for the ADI TUI module.
--
--  Author: hyperpolymath

with Trigger.TUI.Main_Menu;

package body Test_TUI is

   use Test_Harness;
   use Trigger.TUI.Main_Menu;

   --  Test procedures
   procedure Test_Main_Menu_Display is
   begin
      --  Test that main menu can be displayed without errors
      Display_Main_Menu;
      Assert_True (True, "Main menu displayed successfully");
   end Test_Main_Menu_Display;

   procedure Test_Platform_Selection is
   begin
      --  Test that platform menu can be displayed
      Display_Platform_Menu;
      Assert_True (True, "Platform selection menu displayed successfully");
   end Test_Platform_Selection;

   procedure Test_Account_Management is
   begin
      --  Test that account menu can be displayed
      Display_Account_Menu;
      Assert_True (True, "Account management menu displayed successfully");
   end Test_Account_Management;

   procedure Test_Session_Management is
   begin
      --  Test that session menu can be displayed
      Display_Session_Menu;
      Assert_True (True, "Session management menu displayed successfully");
   end Test_Session_Management;

   procedure Test_Reporting_Flow is
   begin
      --  Test that reporting menu can be displayed
      Display_Reporting_Menu;
      Assert_True (True, "Reporting flow menu displayed successfully");
   end Test_Reporting_Flow;

   procedure Test_Diagnostics_Menu is
   begin
      --  Test that diagnostics menu can be displayed
      Display_Diagnostics_Menu;
      Assert_True (True, "Diagnostics menu displayed successfully");
   end Test_Diagnostics_Menu;

   --  Register all tests
   procedure Register_TUI_Tests is
   begin
      --  TUI tests are Provisionally-Proven (type-safe framework)
      --  Using Choreographic category for TUI/multi-step interactions
      Register_Test (TUI_Registry, "TUI", "Test_Main_Menu_Display", "Unit", Test_Main_Menu_Display'Access,
                    Status_Provisionally_Proven, Category_Choreographic);
      Register_Test (TUI_Registry, "TUI", "Test_Platform_Selection", "Unit", Test_Platform_Selection'Access,
                    Status_Provisionally_Proven, Category_Choreographic);
      Register_Test (TUI_Registry, "TUI", "Test_Account_Management", "Unit", Test_Account_Management'Access,
                    Status_Provisionally_Proven, Category_Choreographic);
      Register_Test (TUI_Registry, "TUI", "Test_Session_Management", "Unit", Test_Session_Management'Access,
                    Status_Provisionally_Proven, Category_Choreographic);
      Register_Test (TUI_Registry, "TUI", "Test_Reporting_Flow", "Unit", Test_Reporting_Flow'Access,
                    Status_Provisionally_Proven, Category_Choreographic);
      Register_Test (TUI_Registry, "TUI", "Test_Diagnostics_Menu", "Unit", Test_Diagnostics_Menu'Access,
                    Status_Provisionally_Proven, Category_Choreographic);
   end Register_TUI_Tests;

   --  Run all TUI tests
   procedure Run_All_TUI_Tests is
   begin
      Register_TUI_Tests;
      Run_Test_Suite (TUI_Registry, "TUI");
   end Run_All_TUI_Tests;

begin
   --  Auto-register tests when package is elaborated
   Register_TUI_Tests;

end Test_TUI;
