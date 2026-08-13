--  Trigger - Cryptography FFI Bindings Specification
--  
--  Ada bindings for cryptographic operations via Zig FFI
--  
--  This package provides the interface for calling cryptographic functions
--  implemented in Zig through C-exported symbols. The Zig implementation
--  wraps libsodium (for EdD448, BLAKE3, SHAKE-512) and liboqs (for Kyber-1024).
--  
--  Author: hyperpolymath
--  Architecture: Ada/SPARK <- Idris2 <- Zig (FFI) <- libsodium/liboqs
--  License: MPL-2.0
--  SPDX-License-Identifier: MPL-2.0

package Trigger.FFI.Crypto is

   --  =========================================================================
   --  CRYPTOGRAPHIC CONSTANTS
   --  =========================================================================

   --  EdD448 (Ed448-Goldilocks)
   ED448_PUBLIC_KEY_BYTES : constant := 57;
   ED448_PRIVATE_KEY_BYTES : constant := 114;
   ED448_SIGNATURE_BYTES : constant := 114;

   --  Kyber-1024 (NIST PQC Round 3 KEM)
   KYBER_1024_PUBLIC_KEY_BYTES : constant := 1568;
   KYBER_1024_PRIVATE_KEY_BYTES : constant := 3184;
   KYBER_1024_CIPHERTEXT_BYTES : constant := 1568;
   KYBER_1024_SHARED_SECRET_BYTES : constant := 256;

   --  BLAKE3
   BLAKE3_HASH_BYTES : constant := 32;  -- 256-bit hash
   BLAKE3_HASH_HEX_BYTES : constant := 64;  -- Hex representation

   --  SHAKE-512 (XOF from SHA-3)
   SHAKE_512_OUTPUT_BYTES : constant := 64;  -- 512-bit output
   SHAKE_512_OUTPUT_HEX_BYTES : constant := 128;  -- Hex representation

   --  Maximum salt length
   MAX_SALT_LENGTH : constant := 64;

   --  =========================================================================
   --  ERROR CODES
   --  =========================================================================

   type Error_Code is (Success, Failure, Invalid_Input, Invalid_Key, 
                       Memory_Error, Not_Implemented, Library_Not_Loaded);

   --  =========================================================================
   --  ED448 (EdD448) FUNCTIONS
   --  =========================================================================

   --  Generate Ed448 key pair
   --  @param Public_Key  Output buffer for public key (must be >= ED448_PUBLIC_KEY_BYTES)
   --  @param Private_Key Output buffer for private key (must be >= ED448_PRIVATE_KEY_BYTES)
   --  @return Error_Code indicating success or failure
   function Ed448_Generate_Keypair (
      Public_Key : System.Address;
      Private_Key : System.Address
   ) return Error_Code
     with Import, Convention => C, External_Name => "ed448_generate_keypair";

   --  Sign a message with Ed448
   --  @param Signature    Output buffer for signature (must be >= ED448_SIGNATURE_BYTES)
   --  @param Message      Input message bytes
   --  @param Message_Len  Length of message
   --  @param Private_Key  Signing private key
   --  @return Error_Code indicating success or failure
   function Ed448_Sign (
      Signature : System.Address;
      Message : System.Address;
      Message_Len : Integer;
      Private_Key : System.Address
   ) return Error_Code
     with Import, Convention => C, External_Name => "ed448_sign";

   --  Verify Ed448 signature
   --  @param Signature   Input signature bytes
   --  @param Message     Input message bytes
   --  @param Message_Len Length of message
   --  @param Public_Key  Verification public key
   --  @return Error_Code indicating success or failure
   function Ed448_Verify (
      Signature : System.Address;
      Message : System.Address;
      Message_Len : Integer;
      Public_Key : System.Address
   ) return Error_Code
     with Import, Convention => C, External_Name => "ed448_verify";

   --  =========================================================================
   --  KYBER-1024 FUNCTIONS
   --  =========================================================================

   --  Generate Kyber-1024 key pair
   --  @param Public_Key  Output buffer for public key (must be >= KYBER_1024_PUBLIC_KEY_BYTES)
   --  @param Private_Key Output buffer for private key (must be >= KYBER_1024_PRIVATE_KEY_BYTES)
   --  @return Error_Code indicating success or failure
   function Kyber_1024_Generate_Keypair (
      Public_Key : System.Address;
      Private_Key : System.Address
   ) return Error_Code
     with Import, Convention => C, External_Name => "kyber_1024_generate_keypair";

   --  Encapsulate (encrypt) with Kyber-1024
   --  @param Ciphertext        Output buffer for ciphertext (must be >= KYBER_1024_CIPHERTEXT_BYTES)
   --  @param Shared_Secret     Output buffer for shared secret (must be >= KYBER_1024_SHARED_SECRET_BYTES)
   --  @param Recipient_Public_Key  Recipient's public key
   --  @return Error_Code indicating success or failure
   function Kyber_1024_Encapsulate (
      Ciphertext : System.Address;
      Shared_Secret : System.Address;
      Recipient_Public_Key : System.Address
   ) return Error_Code
     with Import, Convention => C, External_Name => "kyber_1024_encapsulate";

   --  Decapsulate (decrypt) with Kyber-1024
   --  @param Shared_Secret     Output buffer for shared secret (must be >= KYBER_1024_SHARED_SECRET_BYTES)
   --  @param Ciphertext        Input ciphertext
   --  @param Recipient_Private_Key  Recipient's private key
   --  @return Error_Code indicating success or failure
   function Kyber_1024_Decapsulate (
      Shared_Secret : System.Address;
      Ciphertext : System.Address;
      Recipient_Private_Key : System.Address
   ) return Error_Code
     with Import, Convention => C, External_Name => "kyber_1024_decapsulate";

   --  =========================================================================
   --  BLAKE3 FUNCTIONS
   --  =========================================================================

   --  Hash data with BLAKE3 (256-bit output)
   --  @param Hash      Output buffer for hash (must be >= BLAKE3_HASH_BYTES)
   --  @param Data      Input data bytes
   --  @param Data_Len  Length of data
   --  @return Error_Code indicating success or failure
   function BLAKE3_Hash (
      Hash : System.Address;
      Data : System.Address;
      Data_Len : Integer
   ) return Error_Code
     with Import, Convention => C, External_Name => "blake3_hash";

   --  =========================================================================
   --  SHAKE-512 FUNCTIONS
   --  =========================================================================

   --  Hash data with SHAKE-512 (512-bit output)
   --  @param Hash      Output buffer for hash (must be >= SHAKE_512_OUTPUT_BYTES)
   --  @param Data      Input data bytes
   --  @param Data_Len  Length of data
   --  @return Error_Code indicating success or failure
   function SHAKE_512_Hash (
      Hash : System.Address;
      Data : System.Address;
      Data_Len : Integer
   ) return Error_Code
     with Import, Convention => C, External_Name => "shake_512_hash";

   --  =========================================================================
   --  UTILITY FUNCTIONS
   --  =========================================================================

   --  Generate a cryptographically secure salt
   --  @param Salt     Output buffer for salt
   --  @param Length   Length of salt to generate
   --  @return Error_Code indicating success or failure
   function Generate_Salt (
      Salt : System.Address;
      Length : Integer
   ) return Error_Code
     with Import, Convention => C, External_Name => "crypto_generate_salt";

   --  Derive a key from password and salt using BLAKE3
   --  @param Derived_Key    Output buffer for derived key
   --  @param Derived_Key_Len Length of derived key
   --  @param Password       Input password bytes
   --  @param Password_Len   Length of password
   --  @param Salt           Input salt bytes
   --  @param Salt_Len       Length of salt
   --  @return Error_Code indicating success or failure
   function Derive_Key (
      Derived_Key : System.Address;
      Derived_Key_Len : Integer;
      Password : System.Address;
      Password_Len : Integer;
      Salt : System.Address;
      Salt_Len : Integer
   ) return Error_Code
     with Import, Convention => C, External_Name => "crypto_derive_key";

   --  Securely wipe memory (best effort)
   --  @param Data    Buffer to wipe
   --  @param Length  Length to wipe
   procedure Secure_Wipe (
      Data : System.Address;
      Length : Integer
   )
     with Import, Convention => C, External_Name => "crypto_secure_wipe";

   --  =========================================================================
   --  HYBRID ENCRYPTION (EdD448 + Kyber-1024)
   --  =========================================================================

   --  Hybrid encrypt: Use Kyber for key exchange + EdD448 for authentication
   --  @param Ciphertext        Output buffer for ciphertext
   --  @param Ciphertext_Len    Output length of ciphertext
   --  @param Tag              Output buffer for authentication tag
   --  @param Tag_Len           Output length of tag
   --  @param Plaintext        Input plaintext
   --  @param Plaintext_Len    Length of plaintext
   --  @param Ed448_Public_Key   Sender's Ed448 public key
   --  @param Ed448_Private_Key  Sender's Ed448 private key
   --  @param Kyber_Public_Key   Recipient's Kyber public key
   --  @return Error_Code indicating success or failure
   function Hybrid_Encrypt (
      Ciphertext : System.Address;
      Ciphertext_Len : System.Address;
      Tag : System.Address;
      Tag_Len : System.Address;
      Plaintext : System.Address;
      Plaintext_Len : Integer;
      Ed448_Public_Key : System.Address;
      Ed448_Private_Key : System.Address;
      Kyber_Public_Key : System.Address
   ) return Error_Code
     with Import, Convention => C, External_Name => "hybrid_encrypt";

   --  Hybrid decrypt: Verify signature + Decrypt using Kyber
   --  @param Plaintext        Output buffer for plaintext
   --  @param Plaintext_Len    Output length of plaintext
   --  @param Ciphertext        Input ciphertext
   --  @param Ciphertext_Len    Length of ciphertext
   --  @param Tag              Input authentication tag
   --  @param Tag_Len           Length of tag
   --  @param Ed448_Public_Key   Sender's Ed448 public key
   --  @param Ed448_Private_Key  Recipient's Ed448 private key
   --  @param Kyber_Private_Key  Recipient's Kyber private key
   --  @return Error_Code indicating success or failure
   function Hybrid_Decrypt (
      Plaintext : System.Address;
      Plaintext_Len : System.Address;
      Ciphertext : System.Address;
      Ciphertext_Len : Integer;
      Tag : System.Address;
      Tag_Len : Integer;
      Ed448_Public_Key : System.Address;
      Ed448_Private_Key : System.Address;
      Kyber_Private_Key : System.Address
   ) return Error_Code
     with Import, Convention => C, External_Name => "hybrid_decrypt";

end Trigger.FFI.Crypto;
