--  Trigger - Unit Tests for Diagnostics Module
--
--  Tests for the diagnostics and self-healing modules.
--
--  Author: hyperpolymath

with Test_Harness;

package Test_Diagnostics is

   use Test_Harness;

   --  Registry for diagnostics tests
   Diag_Registry : Test_Registry := Get_Registry;

   --  Test procedures
   procedure Test_Check_Dependencies;
   procedure Test_Check_Configuration;
   procedure Test_Check_Sessions;
   procedure Test_Health_Check;
   procedure Test_Self_Heal_Config;
   procedure Test_Self_Heal_Permissions;
   procedure Test_Self_Heal_Sessions;

   --  Register all tests
   procedure Register_Diagnostics_Tests;

   --  Run all diagnostics tests
   procedure Run_All_Diagnostics_Tests;

end Test_Diagnostics;
