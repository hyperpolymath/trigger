--  Trigger - Unit Tests for CLI Argument Parser
--
--  Tests for the CLI argument parser module.
--
--  Author: hyperpolymath

with Test_Harness;

package Test_CLI is

   use Test_Harness;

   --  Registry for CLI tests
   CLI_Registry : Test_Registry := Get_Registry;

   --  Test procedures
   procedure Test_Help_Flag;
   procedure Test_Version_Flag;
   procedure Test_Config_Flag;
   procedure Test_Platform_Flag;
   procedure Test_Log_Level_Flag;
   procedure Test_Account_Flag;
   procedure Test_Channel_Flag;
   procedure Test_Diagnose_Flag;
   procedure Test_Self_Heal_Flag;
   procedure Test_TUI_Mode;

   --  Register all tests
   procedure Register_CLI_Tests;

   --  Run all CLI tests
   procedure Run_All_CLI_Tests;

end Test_CLI;
