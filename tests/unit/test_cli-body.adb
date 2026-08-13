--  Trigger - Unit Tests for CLI Argument Parser (Body)
--
--  Tests for the CLI argument parser module.
--
--  Author: hyperpolymath

with Trigger.CLI.Argument_Parser;

package body Test_CLI is

   use Test_Harness;
   use Trigger.CLI.Argument_Parser;

   --  Test procedures
   procedure Test_Help_Flag is
      Config : Configuration_Type;
      Args : constant String := "--help";
   begin
      --  Parse arguments with help flag
      Config := Parse_Arguments (Args);
      Assert_True (Config.Show_Help, "Help flag was parsed correctly");
      Assert_False (Config.Show_Version, "Version flag should not be set");
   end Test_Help_Flag;

   procedure Test_Version_Flag is
      Config : Configuration_Type;
      Args : constant String := "--version";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (Config.Show_Version, "Version flag was parsed correctly");
      Assert_False (Config.Show_Help, "Help flag should not be set");
   end Test_Version_Flag;

   procedure Test_Config_Flag is
      Config : Configuration_Type;
      Args : constant String := "--config test_config.adoc --save-config";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (To_String (Config.Config_File) = "test_config.adoc",
                  "Config file path was parsed correctly");
      Assert_True (Config.Save_Config, "Save config flag was parsed correctly");
   end Test_Config_Flag;

   procedure Test_Platform_Flag is
      Config : Configuration_Type;
      Args : constant String := "--platform discord";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (Config.Platform = Platform_Discord, 
                  "Platform flag was parsed as Discord");
   end Test_Platform_Flag;

   procedure Test_Log_Level_Flag is
      Config : Configuration_Type;
      Args : constant String := "--log-level debug";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (Config.Log_Level = Log_Debug, 
                  "Log level flag was parsed as Debug");
   end Test_Log_Level_Flag;

   procedure Test_Account_Flag is
      Config : Configuration_Type;
      Args : constant String := "--account test_account --list-accounts";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (To_String (Config.Specific_Account) = "test_account",
                  "Account name was parsed correctly");
      Assert_True (Config.List_Accounts, "List accounts flag was parsed correctly");
   end Test_Account_Flag;

   procedure Test_Channel_Flag is
      Config : Configuration_Type;
      Args : constant String := "--channel test_channel";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (Config.Mode = Mode_Execute,
                  "Channel flag sets execute mode");
   end Test_Channel_Flag;

   procedure Test_Diagnose_Flag is
      Config : Configuration_Type;
      Args : constant String := "--diagnose";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (Config.Mode = Mode_Diagnose, 
                  "Diagnose mode was set correctly");
   end Test_Diagnose_Flag;

   procedure Test_Self_Heal_Flag is
      Config : Configuration_Type;
      Args : constant String := "--self-heal";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (Config.Mode = Mode_Self_Heal, 
                  "Self-heal mode was set correctly");
   end Test_Self_Heal_Flag;

   procedure Test_TUI_Mode is
      Config : Configuration_Type;
      Args : constant String := "--tui";
   begin
      Config := Parse_Arguments (Args);
      Assert_True (Config.Mode = Mode_TUI, 
                  "TUI mode was set correctly");
   end Test_TUI_Mode;

   --  Register all tests
   procedure Register_CLI_Tests is
   begin
      --  CLI tests are Provisionally-Proven (type-safe framework)
      --  Using Ceremonial category for CLI/UX testing
      Register_Test (CLI_Registry, "CLI", "Test_Help_Flag", "Unit", Test_Help_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_Version_Flag", "Unit", Test_Version_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_Config_Flag", "Unit", Test_Config_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_Platform_Flag", "Unit", Test_Platform_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_Log_Level_Flag", "Unit", Test_Log_Level_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_Account_Flag", "Unit", Test_Account_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_Channel_Flag", "Unit", Test_Channel_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_Diagnose_Flag", "Unit", Test_Diagnose_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_Self_Heal_Flag", "Unit", Test_Self_Heal_Flag'Access,
                    Status_Provisionally_Proven, Category_Ceremonial);
      Register_Test (CLI_Registry, "CLI", "Test_TUI_Mode", "Unit", Test_TUI_Mode'Access,
                    Status_Provisionally_Proven, Category_Epistemic);
   end Register_CLI_Tests;

   --  Run all CLI tests
   procedure Run_All_CLI_Tests is
   begin
      Register_CLI_Tests;
      Run_Test_Suite (CLI_Registry, "CLI");
   end Run_All_CLI_Tests;

begin
   --  Auto-register tests when package is elaborated
   Register_CLI_Tests;

end Test_CLI;
