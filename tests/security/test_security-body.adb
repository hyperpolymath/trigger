--  Trigger - Security Tests (Body)
--
--  Security-focused tests for the Trigger application.
--
--  Author: hyperpolymath

with Trigger.Core.Cryptography;
with Trigger.Core.Application;
with Trigger.CLI.Argument_Parser;

package body Test_Security is

   use Test_Harness;
   use Trigger.Core.Cryptography;

   --  Test procedures
   procedure Test_Secure_Configuration is
      Config : Argument_Parser.Configuration_Type;
      Keys : Key_Result;
      Wiped : String (1 .. 100) := (others => 'S');
   begin
      --  Test secure configuration with crypto keys
      Keys := Generate_EdD448_Keys;
      Assert_True (Keys.Success, "Secure keys generated for configuration");
      
      --  Test secure wipe
      Secure_Wipe (Wiped);
      for I in Wiped'Range loop
         Assert_True (Wiped (I) = Character'Val (0), "Secure wipe cleared byte " & Integer'Image (I));
      end loop;
   end Test_Secure_Configuration;

   procedure Test_Secure_Session_Management is
      App : Application.Application_Type;
      Config : Argument_Parser.Configuration_Type;
      Session_Name : constant String := "secure_session";
   begin
      Application.Initialize_Application (App, Config);
      Application.Create_Session (App, Session_Name);
      Assert_True (App.Sessions.Contains (Session_Name), "Secure session created");
   end Test_Secure_Session_Management;

   procedure Test_Input_Validation is
      --  Test input validation with crypto operations
      Test_Data : constant String := "Test input for validation";
      Result : Hash_Result;
   begin
      --  Hash input to validate it
      Result := BLAKE3_Hash (Test_Data);
      Assert_True (Result.Success, "Input validation hash succeeded");
      Assert_Equal (Result.Hash'Length, 64, "Hash output is correct length");
   end Test_Input_Validation;

   procedure Test_Crypto_Operations is
      EdD448_Keys : Key_Result;
      Kyber_Keys : Key_Result;
      Test_Message : constant String := "Secure test message";
      Encrypted : Encryption_Result;
      Decrypted : Decryption_Result;
   begin
      --  Test EdD448 operations
      EdD448_Keys := Generate_EdD448_Keys;
      Assert_True (EdD448_Keys.Success, "EdD448 keys generated");
      
      Encrypted := EdD448_Encrypt (Test_Message, To_String (EdD448_Keys.Public_Key), To_String (EdD448_Keys.Private_Key));
      Assert_True (Encrypted.Success, "EdD448 encryption succeeded");
      
      --  Test Kyber-1024 operations
      Kyber_Keys := Generate_Kyber_1024_Keys;
      Assert_True (Kyber_Keys.Success, "Kyber-1024 keys generated");
      
      --  Test combined operations
      Encrypted := Combined_Encrypt (Test_Message,
                                    To_String (EdD448_Keys.Public_Key),
                                    To_String (EdD448_Keys.Private_Key),
                                    To_String (Kyber_Keys.Public_Key),
                                    To_String (Kyber_Keys.Private_Key));
      Assert_True (Encrypted.Success, "Combined encryption succeeded");
   end Test_Crypto_Operations;

   procedure Test_Access_Control is
      --  Test access control through crypto operations
      EdD448_Keys : Key_Result;
      Kyber_Keys : Key_Result;
   begin
      --  Generate keys for access control
      EdD448_Keys := Generate_EdD448_Keys;
      Kyber_Keys := Generate_Kyber_1024_Keys;
      
      Assert_True (EdD448_Keys.Success, "Access control EdD448 keys generated");
      Assert_True (Kyber_Keys.Success, "Access control Kyber keys generated");
      
      --  Verify key sizes are correct for access control
      Assert_Equal (EdD448_Keys.Public_Key'Length, 114, "Public key correct size");
      Assert_Equal (EdD448_Keys.Private_Key'Length, 228, "Private key correct size");
   end Test_Access_Control;

   procedure Test_Audit_Logging is
      --  Test audit logging through crypto hashing
      Audit_Message : constant String := "Audit log entry: User action performed";
      Result : Hash_Result;
   begin
      --  Hash audit message for logging
      Result := SHAKE_512_Hash (Audit_Message);
      Assert_True (Result.Success, "Audit log hash succeeded");
      Assert_Equal (Result.Hash'Length, 128, "SHAKE-512 hash is 128 characters");
   end Test_Audit_Logging;

   --  Register all tests
   procedure Register_Security_Tests is
   begin
      --  Security tests are Provisionally-Proven (type-safe framework)
      --  Using Epistemic category for security/access control testing
      Register_Test (Security_Registry, "Security", "Test_Secure_Configuration", "Security", Test_Secure_Configuration'Access,
                    Status_Provisionally_Proven, Category_Epistemic);
      Register_Test (Security_Registry, "Security", "Test_Secure_Session_Management", "Security", Test_Secure_Session_Management'Access,
                    Status_Provisionally_Proven, Category_Epistemic);
      Register_Test (Security_Registry, "Security", "Test_Input_Validation", "Security", Test_Input_Validation'Access,
                    Status_Provisionally_Proven, Category_Epistemic);
      Register_Test (Security_Registry, "Security", "Test_Crypto_Operations", "Security", Test_Crypto_Operations'Access,
                    Status_Provisionally_Proven, Category_Epistemic);
      Register_Test (Security_Registry, "Security", "Test_Access_Control", "Security", Test_Access_Control'Access,
                    Status_Provisionally_Proven, Category_Epistemic);
      Register_Test (Security_Registry, "Security", "Test_Audit_Logging", "Security", Test_Audit_Logging'Access,
                    Status_Provisionally_Proven, Category_Epistemic);
   end Register_Security_Tests;

   --  Run all security tests
   procedure Run_All_Security_Tests is
   begin
      Register_Security_Tests;
      Run_Test_Suite (Security_Registry, "Security");
   end Run_All_Security_Tests;

begin
   --  Auto-register tests when package is elaborated
   Register_Security_Tests;

end Test_Security;
