--  Trigger - Benchmark Tests
--
--  Performance and benchmark tests for the Trigger application.
--
--  Author: hyperpolymath

with Test_Harness;

package Test_Benchmark is

   use Test_Harness;

   --  Registry for benchmark tests
   Benchmark_Registry : Test_Registry := Get_Registry;

   --  Test procedures
   procedure Test_Crypto_Performance;
   procedure Test_Reporting_Latency;
   procedure Test_Memory_Usage;
   procedure Test_Concurrent_Operations;
   procedure Test_Throughput;

   --  Register all tests
   procedure Register_Benchmark_Tests;

   --  Run all benchmark tests
   procedure Run_All_Benchmark_Tests;

end Test_Benchmark;
