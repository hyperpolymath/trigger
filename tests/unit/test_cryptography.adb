--  Trigger - Unit Tests for Cryptography Module
--
--  Tests for the cryptography module implementation using the test harness.
--
--  Author: hyperpolymath

with Ada.Text_IO;
with Test_Harness;

package Test_Cryptography is

   use Test_Harness;

   --  Registry for cryptography tests
   Crypto_Registry : Test_Registry := Get_Registry;

   --  Individual test procedures
   
   procedure Test_Crypto_Initialization;
   procedure Test_Ed448_Signing;
   procedure Test_Ed448_Verification;
   procedure Test_Blake3_Hashing;
   procedure Test_Shake512_Hashing;
   procedure Test_Hybrid_Encryption;
   procedure Test_Key_Generation;
   procedure Test_Secure_Wipe;
   procedure Test_Constant_Time_Compare;

   --  Register all tests
   procedure Register_Crypto_Tests;

   --  Run all cryptography tests
   procedure Run_All_Crypto_Tests;

end Test_Cryptography;
