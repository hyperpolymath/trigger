--  Trigger - System Tests
--
--  System-level tests for the Trigger application.
--
--  Author: hyperpolymath

with Test_Harness;

package Test_System is

   use Test_Harness;

   --  Registry for system tests
   System_Registry : Test_Registry := Get_Registry;

   --  Test procedures
   procedure Test_Application_Startup;
   procedure Test_Application_Shutdown;
   procedure Test_Configuration_Loading;
   procedure Test_Configuration_Saving;
   procedure Test_Session_Persistence;
   procedure Test_Multi_Account_Management;

   --  Register all tests
   procedure Register_System_Tests;

   --  Run all system tests
   procedure Run_All_System_Tests;

end Test_System;
