--  Trigger - Security Tests
--
--  Security-focused tests for the Trigger application.
--
--  Author: hyperpolymath

with Test_Harness;

package Test_Security is

   use Test_Harness;

   --  Registry for security tests
   Security_Registry : Test_Registry := Get_Registry;

   --  Test procedures
   procedure Test_Secure_Configuration;
   procedure Test_Secure_Session_Management;
   procedure Test_Input_Validation;
   procedure Test_Crypto_Operations;
   procedure Test_Access_Control;
   procedure Test_Audit_Logging;

   --  Register all tests
   procedure Register_Security_Tests;

   --  Run all security tests
   procedure Run_All_Security_Tests;

end Test_Security;
