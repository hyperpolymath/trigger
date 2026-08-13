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
      Procedure_Access : access procedure
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

   --  Get current test registry
   function Get_Registry return Test_Registry;

   --  Output formats
   type Output_Format_Type is (
      Format_Text,
      Format_JSON,
      Format_JUnit,
      Format_TAP
   );

end Test_Harness;
