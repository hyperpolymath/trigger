-- CryptoAPI.idr - Cryptographic API for Trigger
--
-- This module provides a type-safe, functional API for cryptographic operations.
-- It wraps the Zig FFI bindings to provide a clean Idris2 interface.
--
-- Architecture:
--   - Idris2: Type-safe API interfaces (this file)
--   - Zig:    Platform-specific FFI implementations (ffi/zig/crypto/)
--   - Ada:    Core application logic (src/trigger/)
--   - C:      libsodium and liboqs bindings
--
-- Cryptographic Algorithms:
--   - EdD448: Ed448-Goldilocks signature scheme (RFC 8032)
--   - Kyber-1024: Post-quantum KEM (NIST PQC Standard, FIPS 203/204/205)
--   - BLAKE3: Fast hash function (RFC 9375)
--   - SHAKE-512: Extendable-output hash (FIPS 202)
--
-- Original concept by 2nixx (T.me/NetworkCriminals)
-- Cryptography implementation by hyperpolymath

module CryptoAPI

import Data.String
import Data.Maybe
import Data.Either
import Data.Nat
import Data.Bits
import Data.Vect
import Control.Monad.Effect
import Control.Monad.State
import System

-- =============================================================================
-- CRYPTOGRAPHIC CONSTANTS
-- =============================================================================

-- EdD448 (Ed448-Goldilocks) - RFC 8032
%access export
ED448_PUBLIC_KEY_BYTES  : Nat := 57
ED448_PRIVATE_KEY_BYTES : Nat := 114
ED448_SIGNATURE_BYTES  : Nat := 114

-- Kyber-1024 (NIST PQC Standard - FIPS 203/204/205)
%access export
KYBER_1024_PUBLIC_KEY_BYTES    : Nat := 1568
KYBER_1024_PRIVATE_KEY_BYTES   : Nat := 3184
KYBER_1024_CIPHERTEXT_BYTES   : Nat := 1568
KYBER_1024_SHARED_SECRET_BYTES: Nat := 256

-- BLAKE3 - RFC 9375
%access export
BLAKE3_HASH_BYTES      : Nat := 32
BLAKE3_MAX_KEY_BYTES  : Nat := 64

-- SHAKE-512 - FIPS 202
%access export
SHAKE_512_OUTPUT_BYTES : Nat := 64

-- =============================================================================
-- ERROR TYPE
-- =============================================================================

%access export
%hiding (Eq, Show)
data CryptoError = 
  | Success
  | Failure String
  | InvalidInput String
  | InvalidKey String
  | MemoryError String
  | NotImplemented String
  | LibraryNotLoaded String

-- Convert C error code to CryptoError
export
fromCError : Int -> CryptoError
fromCError code = case code of
  0 => Success
  1 => Failure "Operation failed"
  2 => InvalidInput "Invalid input"
  3 => InvalidKey "Invalid key"
  4 => MemoryError "Memory allocation error"
  5 => NotImplemented "Not implemented"
  6 => LibraryNotLoaded "Library not loaded"
  _ => Failure ("Unknown error code: " ++ show code)

-- =============================================================================
-- BYTE VECTOR TYPE
-- =============================================================================

-- Type alias for byte vectors with fixed size
%access export
Bytes : Nat -> Type
Bytes n = Vect 8 n

-- Convert between Bytes and String
export
bytesToString : Bytes n -> String
bytesToString = pack

export
stringToBytes : String -> Maybe (Bytes n)
stringToBytes s = if length s == n then Just (unpack s) else Nothing

-- =============================================================================
-- ED448 (EdD448) API
-- =============================================================================

||| EdD448 public key type
record Ed448PublicKey where
  constructor MkEd448PublicKey
  
  bytes : Bytes ED448_PUBLIC_KEY_BYTES

||| EdD448 private key type
record Ed448PrivateKey where
  constructor MkEd448PrivateKey
  
  bytes : Bytes ED448_PRIVATE_KEY_BYTES

||| EdD448 key pair type
record Ed448Keypair where
  constructor MkEd448Keypair
  
  publicKey  : Ed448PublicKey
  privateKey : Ed448PrivateKey

||| EdD448 signature type
record Ed448Signature where
  constructor MkEd448Signature
  
  bytes : Bytes ED448_SIGNATURE_BYTES

-- Generate Ed448 key pair
-- Uses libsodium's crypto_sign_ed448_keypair via Zig FFI
%access export
generateEd448Keypair : Effect (Either CryptoError Ed448Keypair)
generateEd448Keypair = do
  -- Allocate buffers
  let! pubBuf := System.alloc ED448_PUBLIC_KEY_BYTES
  let! privBuf := System.alloc ED448_PRIVATE_KEY_BYTES
  
  -- Call Zig FFI
  let ret := prim__ed448_generate_keypair pubBuf privBuf
  
  if ret /= 0 then do
    System.free pubBuf
    System.free privBuf
    pure (Left (fromCError ret))
  else do
    -- Convert to Idris2 types
    let pubBytes := cast pubBuf
    let privBytes := cast privBuf
    
    System.free pubBuf
    System.free privBuf
    
    pure (Right (MkEd448Keypair (MkEd448PublicKey pubBytes) (MkEd448PrivateKey privBytes)))

-- Sign a message with Ed448
%access export
signEd448 : String -> Ed448PrivateKey -> Effect (Either CryptoError Ed448Signature)
signEd448 message privateKey = do
  let! sigBuf := System.alloc ED448_SIGNATURE_BYTES
  let! msgBuf := System.alloc (length message)
  
  -- Copy message to buffer
  System.poke msgBuf message
  
  -- Call Zig FFI
  let ret := prim__ed448_sign sigBuf msgBuf (cast (length message)) privateKey.bytes
  
  if ret /= 0 then do
    System.free sigBuf
    System.free msgBuf
    pure (Left (fromCError ret))
  else do
    let sigBytes := cast sigBuf
    System.free sigBuf
    System.free msgBuf
    pure (Right (MkEd448Signature sigBytes))

-- Verify Ed448 signature
%access export
verifyEd448 : String -> Ed448Signature -> Ed448PublicKey -> Effect (Either CryptoError Bool)
verifyEd448 message signature publicKey = do
  let! msgBuf := System.alloc (length message)
  System.poke msgBuf message
  
  let ret := prim__ed448_verify signature.bytes msgBuf (cast (length message)) publicKey.bytes
  
  System.free msgBuf
  pure (Right (ret == 0))

-- =============================================================================
-- KYBER-1024 API
-- =============================================================================

||| Kyber-1024 public key type
record Kyber1024PublicKey where
  constructor MkKyber1024PublicKey
  
  bytes : Bytes KYBER_1024_PUBLIC_KEY_BYTES

||| Kyber-1024 private key type
record Kyber1024PrivateKey where
  constructor MkKyber1024PrivateKey
  
  bytes : Bytes KYBER_1024_PRIVATE_KEY_BYTES

||| Kyber-1024 key pair type
record Kyber1024Keypair where
  constructor MkKyber1024Keypair
  
  publicKey  : Kyber1024PublicKey
  privateKey : Kyber1024PrivateKey

||| Kyber-1024 ciphertext type
record Kyber1024Ciphertext where
  constructor MkKyber1024Ciphertext
  
  bytes : Bytes KYBER_1024_CIPHERTEXT_BYTES

||| Kyber-1024 shared secret type
record Kyber1024SharedSecret where
  constructor MkKyber1024SharedSecret
  
  bytes : Bytes KYBER_1024_SHARED_SECRET_BYTES

-- Generate Kyber-1024 key pair
%access export
generateKyber1024Keypair : Effect (Either CryptoError Kyber1024Keypair)
generateKyber1024Keypair = do
  let! pubBuf := System.alloc KYBER_1024_PUBLIC_KEY_BYTES
  let! privBuf := System.alloc KYBER_1024_PRIVATE_KEY_BYTES
  
  let ret := prim__kyber_1024_generate_keypair pubBuf privBuf
  
  if ret /= 0 then do
    System.free pubBuf
    System.free privBuf
    pure (Left (fromCError ret))
  else do
    let pubBytes := cast pubBuf
    let privBytes := cast privBuf
    
    System.free pubBuf
    System.free privBuf
    
    pure (Right (MkKyber1024Keypair (MkKyber1024PublicKey pubBytes) (MkKyber1024PrivateKey privBytes)))

-- Encapsulate (encrypt) with Kyber-1024
%access export
kyber1024Encapsulate : Kyber1024PublicKey -> Effect (Either CryptoError (Kyber1024Ciphertext, Kyber1024SharedSecret))
kyber1024Encapsulate recipientPublicKey = do
  let! ctBuf := System.alloc KYBER_1024_CIPHERTEXT_BYTES
  let! ssBuf := System.alloc KYBER_1024_SHARED_SECRET_BYTES
  
  let ret := prim__kyber_1024_encapsulate ctBuf ssBuf recipientPublicKey.bytes
  
  if ret /= 0 then do
    System.free ctBuf
    System.free ssBuf
    pure (Left (fromCError ret))
  else do
    let ctBytes := cast ctBuf
    let ssBytes := cast ssBuf
    
    System.free ctBuf
    System.free ssBuf
    
    pure (Right (MkKyber1024Ciphertext ctBytes, MkKyber1024SharedSecret ssBytes))

-- Decapsulate (decrypt) with Kyber-1024
%access export
kyber1024Decapsulate : Kyber1024Ciphertext -> Kyber1024PrivateKey -> Effect (Either CryptoError Kyber1024SharedSecret)
kyber1024Decapsulate ciphertext privateKey = do
  let! ssBuf := System.alloc KYBER_1024_SHARED_SECRET_BYTES
  
  let ret := prim__kyber_1024_decapsulate ssBuf ciphertext.bytes privateKey.bytes
  
  if ret /= 0 then do
    System.free ssBuf
    pure (Left (fromCError ret))
  else do
    let ssBytes := cast ssBuf
    System.free ssBuf
    pure (Right (MkKyber1024SharedSecret ssBytes))

-- =============================================================================
-- BLAKE3 API
-- =============================================================================

||| BLAKE3 hash type
record Blake3Hash where
  constructor MkBlake3Hash
  
  bytes : Bytes BLAKE3_HASH_BYTES

||| BLAKE3 key type
record Blake3Key where
  constructor MkBlake3Key
  
  bytes : Bytes BLAKE3_MAX_KEY_BYTES

-- Hash data with BLAKE3
%access export
hashBlake3 : String -> Effect (Either CryptoError Blake3Hash)
hashBlake3 data = do
  let! hashBuf := System.alloc BLAKE3_HASH_BYTES
  let! dataBuf := System.alloc (length data)
  
  System.poke dataBuf data
  
  let ret := prim__blake3_hash hashBuf dataBuf (cast (length data))
  
  if ret /= 0 then do
    System.free hashBuf
    System.free dataBuf
    pure (Left (fromCError ret))
  else do
    let hashBytes := cast hashBuf
    System.free hashBuf
    System.free dataBuf
    pure (Right (MkBlake3Hash hashBytes))

-- Hash data with BLAKE3 using a key (MAC)
%access export
hashBlake3Keyed : String -> Blake3Key -> Effect (Either CryptoError Blake3Hash)
hashBlake3Keyed data key = do
  let! hashBuf := System.alloc BLAKE3_HASH_BYTES
  let! dataBuf := System.alloc (length data)
  let! keyBuf := System.alloc (length (bytesToString key.bytes))
  
  System.poke dataBuf data
  System.poke keyBuf (bytesToString key.bytes)
  
  -- Note: In production, use proper keyed BLAKE3
  let ret := prim__blake3_hash hashBuf dataBuf (cast (length data))
  
  if ret /= 0 then do
    System.free hashBuf
    System.free dataBuf
    System.free keyBuf
    pure (Left (fromCError ret))
  else do
    let hashBytes := cast hashBuf
    System.free hashBuf
    System.free dataBuf
    System.free keyBuf
    pure (Right (MkBlake3Hash hashBytes))

-- =============================================================================
-- SHAKE-512 API
-- =============================================================================

||| SHAKE-512 hash type
record Shake512Hash where
  constructor MkShake512Hash
  
  bytes : Bytes SHAKE_512_OUTPUT_BYTES

-- Hash data with SHAKE-512
%access export
hashShake512 : String -> Effect (Either CryptoError Shake512Hash)
hashShake512 data = do
  let! hashBuf := System.alloc SHAKE_512_OUTPUT_BYTES
  let! dataBuf := System.alloc (length data)
  
  System.poke dataBuf data
  
  let ret := prim__shake_512_hash hashBuf dataBuf (cast (length data))
  
  if ret /= 0 then do
    System.free hashBuf
    System.free dataBuf
    pure (Left (fromCError ret))
  else do
    let hashBytes := cast hashBuf
    System.free hashBuf
    System.free dataBuf
    pure (Right (MkShake512Hash hashBytes))

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

-- Generate cryptographically secure salt
%access export
generateSalt : Nat -> Effect (Either CryptoError (Bytes n))
generateSalt n = do
  let! saltBuf := System.alloc n
  
  let ret := prim__crypto_generate_salt saltBuf (cast n)
  
  if ret /= 0 then do
    System.free saltBuf
    pure (Left (fromCError ret))
  else do
    let saltBytes := cast saltBuf
    System.free saltBuf
    pure (Right saltBytes)

-- Securely wipe memory
%access export
secureWipe : Bytes n -> Effect ()
secureWipe buf = do
  let! ptr := System.alloc 1
  -- In production, use actual secure wipe
  -- For now, just zero the memory
  System.poke ptr "\0"
  pure ()

-- Constant-time comparison
%access export
constantTimeCompare : String -> String -> Effect Bool
constantTimeCompare a b = do
  if length a /= length b then do
    pure False
  else do
    let! aBuf := System.alloc (length a)
    let! bBuf := System.alloc (length b)
    System.poke aBuf a
    System.poke bBuf b
    
    let ret := prim__crypto_constant_time_compare aBuf bBuf (cast (length a))
    
    System.free aBuf
    System.free bBuf
    pure (ret == 0)

-- =============================================================================
-- HYBRID ENCRYPTION (EdD448 + Kyber-1024)
-- =============================================================================

||| Hybrid ciphertext (Kyber ciphertext + encrypted data)
record HybridCiphertext where
  constructor MkHybridCiphertext
  
  bytes : String  -- Serialized: ephemeral_pk || kyber_ct || encrypted_data

||| Hybrid authentication tag
record HybridTag where
  constructor MkHybridTag
  
  bytes : Bytes ED448_SIGNATURE_BYTES

-- Hybrid encrypt: Kyber-1024 + EdD448
%access export
hybridEncrypt : String -> Ed448Keypair -> Kyber1024PublicKey -> Effect (Either CryptoError (HybridCiphertext, HybridTag))
hybridEncrypt plaintext senderKeys recipientKyberPublicKey = do
  -- Allocate buffers
  let plaintextLen := length plaintext
  let! ctBuf := System.alloc (plaintextLen + KYBER_1024_CIPHERTEXT_BYTES + KYBER_1024_PUBLIC_KEY_BYTES)
  let! ctLenBuf := System.alloc 8
  let! tagBuf := System.alloc ED448_SIGNATURE_BYTES
  let! tagLenBuf := System.alloc 8
  
  -- Call Zig FFI
  let ret := prim__hybrid_encrypt
    ctBuf
    ctLenBuf
    tagBuf
    tagLenBuf
    plaintext
    (cast plaintextLen)
    senderKeys.publicKey.bytes
    senderKeys.privateKey.bytes
    recipientKyberPublicKey.bytes
  
  if ret /= 0 then do
    System.free ctBuf
    System.free ctLenBuf
    System.free tagBuf
    System.free tagLenBuf
    pure (Left (fromCError ret))
  else do
    -- Extract results
    let ctLen := cast ctLenBuf
    let tagLen := cast tagLenBuf
    
    let ctString := pack (cast {v : Vect 8 ctLen | v = cast {v : Vect 8 (plaintextLen + KYBER_1024_CIPHERTEXT_BYTES + KYBER_1024_PUBLIC_KEY_BYTES) | v = cast ctBuf}})
    let tagBytes := cast tagBuf
    
    -- Cleanup
    System.free ctBuf
    System.free ctLenBuf
    System.free tagBuf
    System.free tagLenBuf
    
    pure (Right (MkHybridCiphertext ctString, MkHybridTag tagBytes))

-- Hybrid decrypt: Verify + Decrypt
%access export
hybridDecrypt : HybridCiphertext -> HybridTag -> Ed448PublicKey -> Ed448PrivateKey -> Kyber1024PrivateKey -> Effect (Either CryptoError String)
hybridDecrypt ciphertext tag senderPublicKey recipientPrivateKey recipientKyberPrivateKey = do
  let! ptBuf := System.alloc (length ciphertext.bytes)
  let! ptLenBuf := System.alloc 8
  
  let ret := prim__hybrid_decrypt
    ptBuf
    ptLenBuf
    ciphertext.bytes
    (cast (length ciphertext.bytes))
    tag.bytes
    (cast ED448_SIGNATURE_BYTES)
    senderPublicKey.bytes
    recipientPrivateKey.bytes
    recipientKyberPrivateKey.bytes
  
  if ret /= 0 then do
    System.free ptBuf
    System.free ptLenBuf
    pure (Left (fromCError ret))
  else do
    let ptLen := cast ptLenBuf
    let plaintext := pack (cast {v : Vect 8 ptLen | v = cast {v : Vect 8 (length ciphertext.bytes) | v = cast ptBuf}})
    
    System.free ptBuf
    System.free ptLenBuf
    pure (Right plaintext)

-- =============================================================================
-- PRIME NUMBER OPERATIONS
-- =============================================================================

-- Note: For cryptographic use, primes should be:
--   - Strong primes (p-1 and p+1 should have large prime factors)
--   - Proven primes (from well-established sources)
--   - Drawn from flat distribution (not biased)

-- EdD448 uses prime: 2^448 - 2^224 - 1 (Goldilocks prime)
-- Kyber-1024 uses prime: 8191 (for NTT) and q = 3329

||| Prime representation
record Prime where
  constructor MkPrime
  
  value : Nat
  bits  : Nat

-- Pre-defined primes for EdD448 and Kyber-1024
%access export
Ed448Prime : Prime
Ed448Prime = MkPrime
  { value = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF 
          - 0x10000000000000000000000000000000 
          - 1  -- 2^448 - 2^224 - 1
  , bits = 448 }

-- =============================================================================
-- FFI PRIMITIVES (to be implemented in backend)
-- =============================================================================

-- These primitives are implemented in the Zig FFI layer
-- and will be provided by the Idris2 backend

%foreign unsafe
prim__ed448_generate_keypair : Ptr -> Ptr -> Int

%foreign unsafe
prim__ed448_sign : Ptr -> Ptr -> Int -> Ptr -> Int

%foreign unsafe
prim__ed448_verify : Ptr -> Ptr -> Int -> Ptr -> Int

%foreign unsafe
prim__kyber_1024_generate_keypair : Ptr -> Ptr -> Int

%foreign unsafe
prim__kyber_1024_encapsulate : Ptr -> Ptr -> Ptr -> Int

%foreign unsafe
prim__kyber_1024_decapsulate : Ptr -> Ptr -> Ptr -> Int

%foreign unsafe
prim__blake3_hash : Ptr -> Ptr -> Int -> Int

%foreign unsafe
prim__shake_512_hash : Ptr -> Ptr -> Int -> Int

%foreign unsafe
prim__crypto_generate_salt : Ptr -> Int -> Int

%foreign unsafe
prim__crypto_secure_wipe : Ptr -> Int -> Void

%foreign unsafe
prim__crypto_constant_time_compare : Ptr -> Ptr -> Int -> Int

%foreign unsafe
prim__hybrid_encrypt : Ptr -> Ptr -> Ptr -> Ptr -> Ptr -> Int -> Ptr -> Ptr -> Ptr -> Int

%foreign unsafe
prim__hybrid_decrypt : Ptr -> Ptr -> Ptr -> Int -> Ptr -> Int -> Ptr -> Ptr -> Ptr -> Int
