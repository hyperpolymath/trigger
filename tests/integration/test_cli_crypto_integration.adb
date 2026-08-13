--  Trigger - Integration Tests for CLI and Cryptography
--
--  Tests for the integration between CLI and cryptography modules.
--
--  Author: hyperpolymath

with Test_Harness;

package Test_CLI_Crypto_Integration is

   use Test_Harness;

   --  Registry for integration tests
   Integration_Registry : Test_Registry := Get_Registry;

   --  Test procedures
   procedure Test_CLI_Config_With_Crypto;
   procedure Test_CLI_Commands_With_Crypto;
   procedure Test_Platform_Selection_With_Crypto;

   --  Register all tests
   procedure Register_CLI_Crypto_Tests;

   --  Run all integration tests
   procedure Run_All_CLI_Crypto_Tests;

end Test_CLI_Crypto_Integration;
