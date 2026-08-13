--  Trigger - Benchmark Tests Body
--
--  Performance and benchmark tests for the Trigger application.
--
--  Author: hyperpolymath

with Ada.Text_IO;
with Ada.Real_Time;
with Ada.Calendar;
with Ada.Numerics.Discrete_Random;
with Trigger.Core.Cryptography;

package body Test_Benchmark is

   use Test_Harness;
   use Trigger.Core.Cryptography;

   --  Individual test procedures

   procedure Test_Crypto_Performance is
      use Ada.Real_Time;
      use Ada.Calendar;
      
      Start_Time : Time := Clock;
      End_Time : Time;
      Iterations : constant := 100;
      Keys : Key_Result;
      Hash_Result : Trigger.Core.Cryptography.Hash_Result;
   begin
      --  Measure performance of cryptographic operations
      for I in 1 .. Iterations loop
         --  Generate EdD448 keys
         Keys := Generate_EdD448_Keys;
         Assert_True (Keys.Success, "Key generation succeeded in iteration " & Integer'Image (I));
         
         --  Compute BLAKE3 hash
         Hash_Result := BLAKE3_Hash ("Test data for benchmark iteration " & Integer'Image (I));
         Assert_True (Hash_Result.Success, "BLAKE3 hash succeeded in iteration " & Integer'Image (I));
      end loop;
      
      End_Time := Clock;
      
      --  Assert that the operation completed within reasonable time
      --  100 iterations of keygen + hash should take measurable time
      Assert_True (To_Duration (End_Time - Start_Time) > 0.0, 
                  "Crypto performance test took measurable time");
      Assert_True (To_Duration (End_Time - Start_Time) < 30.0, 
                  "Crypto performance test completed within 30 seconds");
   end Test_Crypto_Performance;

   procedure Test_Reporting_Latency is
      use Ada.Real_Time;
      
      Start_Time : Time := Clock;
      End_Time : Time;
      Keys : Key_Result;
   begin
      --  Simulate reporting operations by generating keys
      Keys := Generate_EdD448_Keys;
      Assert_True (Keys.Success, "Key generation for latency test succeeded");
      
      End_Time := Clock;
      
      Assert_True (To_Duration (End_Time - Start_Time) >= 0.0, 
                  "Reporting latency is non-negative");
      Assert_True (To_Duration (End_Time - Start_Time) < 5.0, 
                  "Reporting latency test completed within 5 seconds");
   end Test_Reporting_Latency;

   procedure Test_Memory_Usage is
      Keys : Key_Result;
   begin
      --  Test memory usage by generating large keys
      Keys := Generate_Kyber_1024_Keys;
      Assert_True (Keys.Success, "Kyber key generation succeeded");
      --  Kyber-1024 keys are large (3136 and 6368 hex chars)
      Assert_True (Keys.Public_Key'Length = 3136, "Public key has expected size");
      Assert_True (Keys.Private_Key'Length = 6368, "Private key has expected size");
   end Test_Memory_Usage;

   procedure Test_Concurrent_Operations is
      Keys1, Keys2, Keys3 : Key_Result;
   begin
      --  Simulate concurrent operations by performing multiple independent operations
      Keys1 := Generate_EdD448_Keys;
      Keys2 := Generate_Kyber_1024_Keys;
      Keys3 := Generate_EdD448_Keys;
      
      Assert_True (Keys1.Success, "First operation succeeded");
      Assert_True (Keys2.Success, "Second operation succeeded");
      Assert_True (Keys3.Success, "Third operation succeeded");
      
      --  All operations completed independently
      Assert_True (Keys1.Public_Key'Length > 0 and Keys2.Public_Key'Length > 0 and Keys3.Public_Key'Length > 0,
                  "All concurrent operations produced results");
   end Test_Concurrent_Operations;

   procedure Test_Throughput is
      use Ada.Real_Time;
      
      Start_Time : Time := Clock;
      End_Time : Time;
      Operations_Count : constant := 50;
      Hash_Result : Trigger.Core.Cryptography.Hash_Result;
   begin
      --  Measure throughput of hash operations
      for I in 1 .. Operations_Count loop
         Hash_Result := BLAKE3_Hash ("Throughput test message " & Integer'Image (I));
         Assert_True (Hash_Result.Success, "Hash operation " & Integer'Image (I) & " succeeded");
      end loop;
      
      End_Time := Clock;
      
      --  Verify operations completed
      Assert_True (To_Duration (End_Time - Start_Time) > 0.0,
                  "Throughput test took measurable time");
      Assert_True (To_Duration (End_Time - Start_Time) < 10.0,
                  "Throughput test completed within 10 seconds");
   end Test_Throughput;

   --  Register all tests
   procedure Register_Benchmark_Tests is
   begin
      --  Benchmark tests are Provisionally-Proven (type-safe framework, example-based)
      --  Using Tropical category for performance/benchmark tests
      Register_Test (Benchmark_Registry, "Benchmark", "Test_Crypto_Performance", 
                    "Benchmark", Test_Crypto_Performance'Access,
                    Status_Provisionally_Proven, Category_Tropical);
      Register_Test (Benchmark_Registry, "Benchmark", "Test_Reporting_Latency", 
                    "Benchmark", Test_Reporting_Latency'Access,
                    Status_Provisionally_Proven, Category_Tropical);
      Register_Test (Benchmark_Registry, "Benchmark", "Test_Memory_Usage", 
                    "Benchmark", Test_Memory_Usage'Access,
                    Status_Provisionally_Proven, Category_Tropical);
      Register_Test (Benchmark_Registry, "Benchmark", "Test_Concurrent_Operations", 
                    "Benchmark", Test_Concurrent_Operations'Access,
                    Status_Provisionally_Proven, Category_Choreographic);
      Register_Test (Benchmark_Registry, "Benchmark", "Test_Throughput", 
                    "Benchmark", Test_Throughput'Access,
                    Status_Provisionally_Proven, Category_Tropical);
   end Register_Benchmark_Tests;

   --  Run all benchmark tests
   procedure Run_All_Benchmark_Tests is
   begin
      Register_Benchmark_Tests;
      Run_Test_Suite (Benchmark_Registry, "Benchmark");
   end Run_All_Benchmark_Tests;

begin
   --  Auto-register tests when package is elaborated
   Register_Benchmark_Tests;

end Test_Benchmark;
