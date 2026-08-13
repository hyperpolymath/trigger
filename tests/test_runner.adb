--  Trigger - Test Runner
--
--  Main test runner for all test suites using the comprehensive test harness.
--
--  Author: hyperpolymath

with Ada.Text_IO;
with Test_Harness;

--  Import all test suites
with Test_Cryptography;
with Test_CLI;
with Test_Diagnostics;
with Test_TUI;
with Test_CLI_Crypto_Integration;
with Test_System;
with Test_Security;
with Test_Benchmark;

procedure Test_Runner is

   use Test_Harness;

   --  Get the global registry
   Registry : Test_Registry := Get_Registry;

begin
   Ada.Text_IO.Put_Line ("========================================");
   Ada.Text_IO.Put_Line ("Trigger - Comprehensive Test Runner");
   Ada.Text_IO.Put_Line ("========================================");
   Ada.Text_IO.New_Line;
   
   Ada.Text_IO.Put_Line ("Provenance Classification:");
   Ada.Text_IO.Put_Line ("  Actually-Proven: Full proof ladder with machine-checked proofs");
   Ada.Text_IO.Put_Line ("  Provisionally-Proven: Type-safe framework with example-based tests");
   Ada.Text_IO.Put_Line ("  Unproven: Regular tests without type-safety guarantees");
   Ada.Text_IO.New_Line;
   
   Ada.Text_IO.Put_Line ("Type-Safe Categories:");
   Ada.Text_IO.Put_Line ("  Tropical: Resource bounds (performance/benchmark)");
   Ada.Text_IO.Put_Line ("  Epistemic: Information-theoretic access control");
   Ada.Text_IO.Put_Line ("  Choreographic: Multi-party session types");
   Ada.Text_IO.Put_Line ("  Dependent: Dependent type verification");
   Ada.Text_IO.Put_Line ("  Effects: Effect system properties");
   Ada.Text_IO.Put_Line ("  Decorative: Type-level annotations");
   Ada.Text_IO.Put_Line ("  Ceremonial: Protocol/ritual types");
   Ada.Text_IO.Put_Line ("  Dyadic: Binary relation types");
   Ada.Text_IO.Put_Line ("  Echo-Types: Stand-in contract for echo-types integration");
   Ada.Text_IO.New_Line;
   
   Ada.Text_IO.Put_Line ("========================================");
   Ada.Text_IO.Put_Line ("Running all registered tests...");
   Ada.Text_IO.Put_Line ("========================================");
   Ada.Text_IO.New_Line;
   
   --  Run all tests
   Run_All_Tests (Registry, "text", Verbose => True);

end Test_Runner;
