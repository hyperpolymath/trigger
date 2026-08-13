--  Trigger - Integration Tests for CLI and Cryptography (Body)
--
--  Tests for the integration between CLI and cryptography modules.
--
--  Author: hyperpolymath

with Trigger.CLI.Argument_Parser;
with Trigger.Core.Cryptography;

package body Test_CLI_Crypto_Integration is

   use Test_Harness;
   use Trigger.CLI.Argument_Parser;
   use Trigger.Core.Cryptography;

   --  Test procedures
   procedure Test_CLI_Config_With_Crypto is
      Config : Configuration_Type;
      Keys : Key_Result;
      Args : constant String := "--config crypto_config.adoc --api-id 12345";
   begin
      --  Parse CLI config
      Config := Parse_Arguments (Args);
      Assert_True (To_String (Config.Config_File) = "crypto_config.adoc",
                  "Config file parsed correctly");
      Assert_True (Config.API_ID = 12345,
                  "API ID parsed correctly");
      
      --  Generate crypto keys
      Keys := Generate_EdD448_Keys;
      Assert_True (Keys.Success, "Crypto keys generated for CLI config");
   end Test_CLI_Config_With_Crypto;

   procedure Test_CLI_Commands_With_Crypto is
      Config : Configuration_Type;
      Keys : Key_Result;
      Hash_Result : Hash_Result;
      Args : constant String := "--platform telegram --log-level info";
   begin
      --  Parse CLI commands
      Config := Parse_Arguments (Args);
      Assert_True (Config.Platform = Platform_Telegram,
                  "Platform parsed correctly");
      Assert_True (Config.Log_Level = Log_Info,
                  "Log level parsed correctly");
      
      --  Test crypto operations with CLI config
      Keys := Generate_Kyber_1024_Keys;
      Assert_True (Keys.Success, "Kyber keys generated for CLI commands");
      
      --  Hash the CLI config
      Hash_Result := BLAKE3_Hash ("platform=" & Platform_Type'Image (Config.Platform));
      Assert_True (Hash_Result.Success, "Config hash computed successfully");
   end Test_CLI_Commands_With_Crypto;

   procedure Test_Platform_Selection_With_Crypto is
      Config : Configuration_Type;
      EdD448_Keys : Key_Result;
      Kyber_Keys : Key_Result;
      Args : constant String := "--platform discord --diagnose";
   begin
      --  Parse platform selection
      Config := Parse_Arguments (Args);
      Assert_True (Config.Platform = Platform_Discord,
                  "Platform selection parsed correctly");
      Assert_True (Config.Mode = Mode_Diagnose,
                  "Diagnose mode set correctly");
      
      --  Generate platform-specific crypto keys
      EdD448_Keys := Generate_EdD448_Keys;
      Assert_True (EdD448_Keys.Success, "EdD448 keys generated for platform");
      
      Kyber_Keys := Generate_Kyber_1024_Keys;
      Assert_True (Kyber_Keys.Success, "Kyber keys generated for platform");
   end Test_Platform_Selection_With_Crypto;

   --  Register all tests
   procedure Register_CLI_Crypto_Tests is
   begin
      --  Integration tests are Provisionally-Proven (type-safe framework)
      --  Using Dyadic category for integration between two components
      Register_Test (Integration_Registry, "Integration", "Test_CLI_Config_With_Crypto", 
                    "Integration", Test_CLI_Config_With_Crypto'Access,
                    Status_Provisionally_Proven, Category_Dyadic);
      Register_Test (Integration_Registry, "Integration", "Test_CLI_Commands_With_Crypto", 
                    "Integration", Test_CLI_Commands_With_Crypto'Access,
                    Status_Provisionally_Proven, Category_Dyadic);
      Register_Test (Integration_Registry, "Integration", "Test_Platform_Selection_With_Crypto", 
                    "Integration", Test_Platform_Selection_With_Crypto'Access,
                    Status_Provisionally_Proven, Category_Dyadic);
   end Register_CLI_Crypto_Tests;

   --  Run all integration tests
   procedure Run_All_CLI_Crypto_Tests is
   begin
      Register_CLI_Crypto_Tests;
      Run_Test_Suite (Integration_Registry, "Integration");
   end Run_All_CLI_Crypto_Tests;

begin
   --  Auto-register tests when package is elaborated
   Register_CLI_Crypto_Tests;

end Test_CLI_Crypto_Integration;
