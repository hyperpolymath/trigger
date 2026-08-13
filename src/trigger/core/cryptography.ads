--  Trigger - Core Cryptography Specification
--  
--  Provides cryptographic operations using EdD448 + Kyber-1024 + BLAKE3 + SHAKE-512.
--  
--  Author: hyperpolymath
--  
--  Architecture: Ada/SPARK <- Idris2 <- Zig (FFI) <- libsodium/liboqs
--  
--  Implementation Status:
--  - FFI bindings: Available via Trigger.FFI.Crypto
--  - Zig implementation: ffi/zig/crypto/crypto.zig
--  - Ada implementation: Placeholder (uses FFI when available)
--  
--  For production use:
--  1. Install libsodium (EdD448, BLAKE3, SHAKE-512)
--  2. Install liboqs with Kyber-1024 support
--  3. Update Zig FFI to call actual library functions
--  4. Update Ada implementation to use FFI calls

with Ada.Strings.Unbounded;

package Trigger.Core.Cryptography is

   --  Cryptographic algorithms supported
   type Algorithm_Type is (
      Alg_EdD448,
      Alg_Kyber_1024,
      Alg_BLAKE3,
      Alg_SHAKE_512,
      Alg_Combined
   );

   --  Encryption result type
   type Encryption_Result is tagged record
      Success : Boolean;
      Ciphertext : Ada.Strings.Unbounded.Unbounded_String;
      Tag : Ada.Strings.Unbounded.Unbounded_String;
      Error : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   --  Decryption result type
   type Decryption_Result is tagged record
      Success : Boolean;
      Plaintext : Ada.Strings.Unbounded.Unbounded_String;
      Error : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   --  Hash result type
   type Hash_Result is tagged record
      Success : Boolean;
      Hash : Ada.Strings.Unbounded.Unbounded_String;
      Error : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   --  Key generation result type
   type Key_Result is tagged record
      Success : Boolean;
      Public_Key : Ada.Strings.Unbounded.Unbounded_String;
      Private_Key : Ada.Strings.Unbounded.Unbounded_String;
      Error : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   --  Generate EdD448 key pair
   function Generate_EdD448_Keys return Key_Result;

   --  Generate Kyber-1024 key pair
   function Generate_Kyber_1024_Keys return Key_Result;

   --  Encrypt using EdD448
   function EdD448_Encrypt (
      Plaintext : String;
      Public_Key : String;
      Private_Key : String
   ) return Encryption_Result;

   --  Decrypt using EdD448
   function EdD448_Decrypt (
      Ciphertext : String;
      Public_Key : String;
      Private_Key : String
   ) return Decryption_Result;

   --  Encrypt using Kyber-1024
   function Kyber_1024_Encrypt (
      Plaintext : String;
      Public_Key : String;
      Private_Key : String
   ) return Encryption_Result;

   --  Decrypt using Kyber-1024
   function Kyber_1024_Decrypt (
      Ciphertext : String;
      Public_Key : String;
      Private_Key : String
   ) return Decryption_Result;

   --  Hash using BLAKE3
   function BLAKE3_Hash (Data : String) return Hash_Result;

   --  Hash using SHAKE-512
   function SHAKE_512_Hash (Data : String) return Hash_Result;

   --  Combined encryption (EdD448 + Kyber-1024 hybrid)
   function Combined_Encrypt (
      Plaintext : String;
      EdD448_Public : String;
      EdD448_Private : String;
      Kyber_Public : String;
      Kyber_Private : String
   ) return Encryption_Result;

   --  Combined decryption
   function Combined_Decrypt (
      Ciphertext : String;
      Tag : String;
      EdD448_Public : String;
      EdD448_Private : String;
      Kyber_Public : String;
      Kyber_Private : String
   ) return Decryption_Result;

   --  Generate a cryptographically secure salt
   function Generate_Salt (Length : Integer) return String;

   --  Derive a key from password and salt using BLAKE3
   function Derive_Key (
      Password : String;
      Salt : String
   ) return String;

   --  Securely wipe a string from memory (best effort)
   procedure Secure_Wipe (Data : in out String);

end Trigger.Core.Cryptography;
