--  Trigger - Test Harness
--  
--  Comprehensive test harness for all test suites.
--  
--  Author: hyperpolymath
--  
--  This test harness provides:
--  - Test discovery and execution
--  - Test result aggregation
--  - Test coverage tracking
--  - Test timing and benchmarks
--  - Structured output (text, JSON, JUnit)

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Calendar;
with Ada.Real_Time;

package Test_Harness is

   --  Test result type
   type Test_Result is (
      Result_Pass,
      Result_Fail,
      Result_Skip,
      Result_Error,
      Result_Timeout
   );

   --  Test status type
   type Test_Status is tagged record
      Name : Ada.Strings.Unbounded.Unbounded_String;
      Category : Ada.Strings.Unbounded.Unbounded_String;
      Result : Test_Result;
      Message : Ada.Strings.Unbounded.Unbounded_String;
      Start_Time : Ada.Calendar.Time;
      End_Time : Ada.Calendar.Time;
      Duration : Duration;
      Provenance : Provenance_Status := Status_Unproven;
      Type_Safe_Category : Type_Safe_Category := Category_Dependent;
   end record;

   --  Test suite type
   type Test_Suite is tagged record
      Name : Ada.Strings.Unbounded.Unbounded_String;
      Tests : Positive;
      Passed : Positive;
      Failed : Positive;
      Skipped : Positive;
      Errors : Positive;
      Timeouts : Positive;
      Total_Time : Duration;
      Results : Positive;
   end record;

   --  Test registry
   type Test_Registry is tagged private;

   --  Register a test
   procedure Register_Test (
      Registry : in out Test_Registry;
      Suite : String;
      Name : String;
      Category : String;
      Procedure_Access : access procedure;
      Provenance : Provenance_Status := Status_Unproven;
      Type_Safe_Cat : Type_Safe_Category := Category_Dependent
   );

   --  Run all registered tests
   procedure Run_All_Tests (
      Registry : Test_Registry;
      Output_Format : String := "text";
      Verbose : Boolean := False
   );

   --  Run a specific test suite
   procedure Run_Test_Suite (
      Registry : Test_Registry;
      Suite_Name : String;
      Output_Format : String := "text";
      Verbose : Boolean := False
   );

   --  Run a specific test
   procedure Run_Single_Test (
      Registry : Test_Registry;
      Suite_Name : String;
      Test_Name : String;
      Output_Format : String := "text";
      Verbose : Boolean := False
   );

   --  Assertion procedures
   procedure Assert (
      Condition : Boolean;
      Message : String;
      File : String := "";
      Line : Integer := 0
   );

   procedure Assert_Equal (
      Actual : Integer;
      Expected : Integer;
      Message : String := "Values are equal";
      File : String := "";
      Line : Integer := 0
   );

   procedure Assert_Equal (
      Actual : String;
      Expected : String;
      Message : String := "Strings are equal";
      File : String := "";
      Line : Integer := 0
   );

   procedure Assert_Not_Equal (
      Actual : Integer;
      Expected : Integer;
      Message : String := "Values are not equal";
      File : String := "";
      Line : Integer := 0
   );

   procedure Assert_True (
      Condition : Boolean;
      Message : String := "Condition is true";
      File : String := "";
      Line : Integer := 0
   );

   procedure Assert_False (
      Condition : Boolean;
      Message : String := "Condition is false";
      File : String := "";
      Line : Integer := 0
   );

   --  Test category type
   type Test_Category is (
      Category_Unit,
      Category_Integration,
      Category_System,
      Category_Benchmark,
      Category_Security,
      Category_Acceptance,
      Category_Property
   );

   --  Provenance classification (from proven-tests-and-benches standards)
   type Provenance_Status is (
      Status_Actually_Proven,
      Status_Provisionally_Proven,
      Status_Unproven
   );

   --  Type-safe test categories (from proven-tests-and-benches standards)
   type Type_Safe_Category is (
      Category_Tropical,
      Category_Epistemic,
      Category_Choreographic,
      Category_Dependent,
      Category_Effects,
      Category_Decorative,
      Category_Ceremonial,
      Category_Dyadic,
      Category_Echo_Types
   );

   --  Get current test registry
   function Get_Registry return Test_Registry;

   --  Output formats
   type Output_Format_Type is (
      Format_Text,
      Format_JSON,
      Format_JUnit,
      Format_TAP
   );

   --  Helper functions for provenance display
   function Provenance_Status_To_String (Status : Provenance_Status) return String;
   function Type_Safe_Category_To_String (Cat : Type_Safe_Category) return String;

end Test_Harness;
