--  Trigger - Cryptography Package Specification
--  
--  Provides AES encryption/decryption for session data.
--  
--  In a full implementation, this would use SPARK-verified
--  cryptographic primitives or FFI to a verified library.
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)

package Trigger.Utils.Crypto is

   --  Crypto utils type
   type Crypto_Utils_Type is tagged private;

   --  Initialize crypto with salt
   procedure Initialize (
      Crypto : out Crypto_Utils_Type;
      Salt : String
   );

   --  Finalize crypto
   procedure Finalize (Crypto : in out Crypto_Utils_Type);

   --  Encrypt data
   function Encrypt (
      Crypto : Crypto_Utils_Type;
      Data : String;
      Password : String := "ripper_default"
   ) return String;

   --  Decrypt data
   function Decrypt (
      Crypto : Crypto_Utils_Type;
      Data : String;
      Password : String := "ripper_default"
   ) return String;

private

   --  Placeholder type - in real implementation would hold key material
   type Crypto_Utils_Type is tagged record
      Salt : String (1 .. 16) := (others => ' ');
      Initialized : Boolean := False;
   end record;

end Trigger.Utils.Crypto;
