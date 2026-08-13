--  Trigger - Test Harness Body
--
--  Implementation of the comprehensive test harness.
--
--  Author: hyperpolymath

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Calendar;
with Ada.Real_Time;
with Ada.Exceptions;

package body Test_Harness is

   use Ada.Strings.Unbounded;

   --  Internal test entry type
   type Test_Entry is record
      Suite : Unbounded_String;
      Name : Unbounded_String;
      Category : Unbounded_String;
      Procedure : access procedure;
      Line : Integer;
      File : Unbounded_String;
      Provenance : Provenance_Status := Status_Unproven;
      Type_Safe_Cat : Type_Safe_Category := Category_Dependent;
   end record;

   --  Test registry implementation
   type Test_Registry is tagged record
      Entries : access Test_Entry_Array;
      Count : Natural := 0;
      Capacity : Positive := 100;
   end record;

   type Test_Entry_Array is array (Positive range <>) of Test_Entry;

   --  Global registry instance
   Global_Registry : Test_Registry;

   --  Current test context for assertions
   Current_Test_Status : access Test_Status := null;
   Current_Test_Start : Ada.Calendar.Time;

   --  Initialize the registry
   procedure Initialize_Registry (Registry : in out Test_Registry) is
      use type Ada.Strings.Unbounded.Unbounded_String;
   begin
      if Registry.Entries = null then
         Registry.Entries := new Test_Entry_Array (1 .. Registry.Capacity);
      end if;
   end Initialize_Registry;

   --  Register a test
   procedure Register_Test (
      Registry : in out Test_Registry;
      Suite : String;
      Name : String;
      Category : String;
      Procedure_Access : access procedure;
      Provenance : Provenance_Status := Status_Unproven;
      Type_Safe_Cat : Type_Safe_Category := Category_Dependent
   ) is
   begin
      Initialize_Registry (Registry);
      
      if Registry.Count >= Registry.Capacity then
         --  Resize the array (simple implementation: double the capacity)
         declare
            New_Capacity : constant Positive := Registry.Capacity * 2;
            New_Entries : constant access Test_Entry_Array := 
              new Test_Entry_Array (1 .. New_Capacity);
         begin
            New_Entries (1 .. Registry.Count) := Registry.Entries (1 .. Registry.Count);
            Free (Registry.Entries);
            Registry.Entries := New_Entries;
            Registry.Capacity := New_Capacity;
         end;
      end if;
      
      Registry.Count := Registry.Count + 1;
      Registry.Entries (Registry.Count) := (
         To_Unbounded_String (Suite),
         To_Unbounded_String (Name),
         To_Unbounded_String (Category),
         Procedure_Access,
         0,
         To_Unbounded_String (""),
         Provenance,
         Type_Safe_Cat
      );
   end Register_Test;

   --  Run a single test and return its status
   function Run_Single_Test_Internal (
      Entry : Test_Entry
   ) return Test_Status is
      Start_Time : constant Ada.Calendar.Time := Ada.Calendar.Clock;
      Start_Real : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
      Result : Test_Result := Result_Pass;
      Message : Unbounded_String := Null_Unbounded_String;
      Exception_Occurred : Boolean := False;
      Exception_Message : Unbounded_String := Null_Unbounded_String;
   begin
      --  Set current test context for assertions
      Current_Test_Start := Start_Time;
      Current_Test_Status := new Test_Status'(
         To_Unbounded_String (To_String (Entry.Suite) & "." & To_String (Entry.Name)),
         Entry.Category,
         Result_Pass,
         Null_Unbounded_String,
         Start_Time,
         Start_Time,
         0.0,
         Entry.Provenance,
         Entry.Type_Safe_Cat
      );
      
      begin
         --  Call the test procedure
         Entry.Procedure.all;
         
         if Exception_Occurred then
            Result := Result_Error;
            Message := Exception_Message;
         end if;
      exception
         when E : others =>
            Result := Result_Error;
            Message := To_Unbounded_String ("Exception: " & Ada.Exceptions.Exception_Message (E));
      end;
      
      declare
         End_Time : constant Ada.Calendar.Time := Ada.Calendar.Clock;
         End_Real : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
         Duration : constant Duration := End_Time - Start_Time;
      begin
         --  Update the status
         if Current_Test_Status /= null then
            Current_Test_Status.Result := Result;
            Current_Test_Status.Message := Message;
            Current_Test_Status.End_Time := End_Time;
            Current_Test_Status.Duration := Duration;
         end if;
         
         return Test_Status'(
            Name => To_Unbounded_String (To_String (Entry.Suite) & "." & To_String (Entry.Name)),
            Category => Entry.Category,
            Result => Result,
            Message => Message,
            Start_Time => Start_Time,
            End_Time => End_Time,
            Duration => Duration,
            Provenance => Entry.Provenance,
            Type_Safe_Category => Entry.Type_Safe_Cat
         );
      end;
   end Run_Single_Test_Internal;

   --  Get the current test registry
   function Get_Registry return Test_Registry is
   begin
      return Global_Registry;
   end Get_Registry;

   --  Assertion procedure
   procedure Assert (
      Condition : Boolean;
      Message : String;
      File : String := "";
      Line : Integer := 0
   ) is
   begin
      if Condition then
         if Current_Test_Status /= null then
            --  Count pass
            null;
         end if;
      else
         if Current_Test_Status /= null then
            Current_Test_Status.Result := Result_Fail;
            Current_Test_Status.Message := To_Unbounded_String (Message);
            if File'Length > 0 then
               Append (Current_Test_Status.Message, " at " & File);
               if Line > 0 then
                  Append (Current_Test_Status.Message, ":" & Integer'Image (Line));
               end if;
            end if;
         end if;
      end if;
   end Assert;

   --  Assert equal for integers
   procedure Assert_Equal (
      Actual : Integer;
      Expected : Integer;
      Message : String := "Values are equal";
      File : String := "";
      Line : Integer := 0
   ) is
   begin
      Assert (Actual = Expected, Message & " (expected " & Integer'Image (Expected) & 
         ", got " & Integer'Image (Actual) & ")", File, Line);
   end Assert_Equal;

   --  Assert equal for strings
   procedure Assert_Equal (
      Actual : String;
      Expected : String;
      Message : String := "Strings are equal";
      File : String := "";
      Line : Integer := 0
   ) is
   begin
      Assert (Actual = Expected, Message & " (expected "" & Expected & """, got "" & Actual & """)", File, Line);
   end Assert_Equal;

   --  Assert not equal for integers
   procedure Assert_Not_Equal (
      Actual : Integer;
      Expected : Integer;
      Message : String := "Values are not equal";
      File : String := "";
      Line : Integer := 0
   ) is
   begin
      Assert (Actual /= Expected, Message & " (values are equal: " & Integer'Image (Actual) & ")", File, Line);
   end Assert_Not_Equal;

   --  Assert true
   procedure Assert_True (
      Condition : Boolean;
      Message : String := "Condition is true";
      File : String := "";
      Line : Integer := 0
   ) is
   begin
      Assert (Condition, Message, File, Line);
   end Assert_True;

   --  Assert false
   procedure Assert_False (
      Condition : Boolean;
      Message : String := "Condition is false";
      File : String := "";
      Line : Integer := 0
   ) is
   begin
      Assert (not Condition, Message, File, Line);
   end Assert_False;

   --  Run all registered tests
   procedure Run_All_Tests (
      Registry : Test_Registry;
      Output_Format : String := "text";
      Verbose : Boolean := False
   ) is
      Total_Tests : Natural := 0;
      Passed : Natural := 0;
      Failed : Natural := 0;
      Errors : Natural := 0;
      Skipped : Natural := 0;
      Timeouts : Natural := 0;
      Total_Time : Duration := 0.0;
      Start_Time : constant Ada.Calendar.Time := Ada.Calendar.Clock;
   begin
      if Verbose then
         Ada.Text_IO.Put_Line ("Running all registered tests...");
         Ada.Text_IO.Put_Line ("Total tests: " & Natural'Image (Registry.Count));
      end if;
      
      for I in 1 .. Registry.Count loop
         declare
            Status : Test_Status := Run_Single_Test_Internal (Registry.Entries (I));
         begin
            Total_Tests := Total_Tests + 1;
            Total_Time := Total_Time + Status.Duration;
            
            case Status.Result is
               when Result_Pass =>
                  Passed := Passed + 1;
               when Result_Fail =>
                  Failed := Failed + 1;
               when Result_Error =>
                  Errors := Errors + 1;
               when Result_Skip =>
                  Skipped := Skipped + 1;
               when Result_Timeout =>
                  Timeouts := Timeouts + 1;
            end case;
            
            --  Output based on format
            if Output_Format = "text" then
               case Status.Result is
                  when Result_Pass =>
                     Ada.Text_IO.Put_Line ("[PASS] " & To_String (Status.Name) & 
                                        " [" & Provenance_Status_To_String (Status.Provenance) & 
                                        "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                  when Result_Fail =>
                     Ada.Text_IO.Put_Line ("[FAIL] " & To_String (Status.Name) & ": " & 
                                        To_String (Status.Message) & 
                                        " [" & Provenance_Status_To_String (Status.Provenance) & 
                                        "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                  when Result_Error =>
                     Ada.Text_IO.Put_Line ("[ERROR] " & To_String (Status.Name) & ": " & 
                                        To_String (Status.Message) & 
                                        " [" & Provenance_Status_To_String (Status.Provenance) & 
                                        "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                  when Result_Skip =>
                     Ada.Text_IO.Put_Line ("[SKIP] " & To_String (Status.Name) & 
                                        " [" & Provenance_Status_To_String (Status.Provenance) & 
                                        "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                  when Result_Timeout =>
                     Ada.Text_IO.Put_Line ("[TIMEOUT] " & To_String (Status.Name) & 
                                        " [" & Provenance_Status_To_String (Status.Provenance) & 
                                        "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
               end case;
            end if;
         end;
      end loop;
      
      --  Output summary
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("========================================");
      Ada.Text_IO.Put_Line ("Test Summary:");
      Ada.Text_IO.Put_Line ("  Total:  " & Natural'Image (Total_Tests));
      Ada.Text_IO.Put_Line ("  Passed: " & Natural'Image (Passed));
      Ada.Text_IO.Put_Line ("  Failed: " & Natural'Image (Failed));
      Ada.Text_IO.Put_Line ("  Errors: " & Natural'Image (Errors));
      Ada.Text_IO.Put_Line ("  Skipped: " & Natural'Image (Skipped));
      Ada.Text_IO.Put_Line ("  Timeouts: " & Natural'Image (Timeouts));
      Ada.Text_IO.Put_Line ("  Total time: " & Duration'Image (Total_Time));
      Ada.Text_IO.Put_Line ("========================================");
      
      if Failed > 0 or Errors > 0 then
         Ada.Text_IO.Put_Line ("TESTS FAILED");
      else
         Ada.Text_IO.Put_Line ("ALL TESTS PASSED");
      end if;
   end Run_All_Tests;

   --  Run a specific test suite
   procedure Run_Test_Suite (
      Registry : Test_Registry;
      Suite_Name : String;
      Output_Format : String := "text";
      Verbose : Boolean := False
   ) is
      Total_Tests : Natural := 0;
      Passed : Natural := 0;
      Failed : Natural := 0;
      Errors : Natural := 0;
      Skipped : Natural := 0;
      Timeouts : Natural := 0;
   begin
      for I in 1 .. Registry.Count loop
         if To_String (Registry.Entries (I).Suite) = Suite_Name then
            declare
               Status : Test_Status := Run_Single_Test_Internal (Registry.Entries (I));
            begin
               Total_Tests := Total_Tests + 1;
               
               case Status.Result is
                  when Result_Pass =>
                     Passed := Passed + 1;
                  when Result_Fail =>
                     Failed := Failed + 1;
                  when Result_Error =>
                     Errors := Errors + 1;
                  when Result_Skip =>
                     Skipped := Skipped + 1;
                  when Result_Timeout =>
                     Timeouts := Timeouts + 1;
               end case;
               
               if Output_Format = "text" then
                  case Status.Result is
                     when Result_Pass =>
                        Ada.Text_IO.Put_Line ("[PASS] " & To_String (Status.Name) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                     when Result_Fail =>
                        Ada.Text_IO.Put_Line ("[FAIL] " & To_String (Status.Name) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                     when Result_Error =>
                        Ada.Text_IO.Put_Line ("[ERROR] " & To_String (Status.Name) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                     when Result_Skip =>
                        Ada.Text_IO.Put_Line ("[SKIP] " & To_String (Status.Name) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                     when Result_Timeout =>
                        Ada.Text_IO.Put_Line ("[TIMEOUT] " & To_String (Status.Name) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                  end case;
               end if;
            end;
         end if;
      end loop;
      
      if Total_Tests = 0 then
         Ada.Text_IO.Put_Line ("No tests found for suite: " & Suite_Name);
      else
         Ada.Text_IO.New_Line;
         Ada.Text_IO.Put_Line ("Suite Summary (" & Suite_Name & "):");
         Ada.Text_IO.Put_Line ("  Total:  " & Natural'Image (Total_Tests));
         Ada.Text_IO.Put_Line ("  Passed: " & Natural'Image (Passed));
         Ada.Text_IO.Put_Line ("  Failed: " & Natural'Image (Failed));
         Ada.Text_IO.Put_Line ("  Errors: " & Natural'Image (Errors));
         
         if Failed > 0 or Errors > 0 then
            Ada.Text_IO.Put_Line ("SUITE FAILED");
         else
            Ada.Text_IO.Put_Line ("SUITE PASSED");
         end if;
      end if;
   end Run_Test_Suite;

   --  Run a specific test
   procedure Run_Single_Test (
      Registry : Test_Registry;
      Suite_Name : String;
      Test_Name : String;
      Output_Format : String := "text";
      Verbose : Boolean := False
   ) is
      Found : Boolean := False;
   begin
      for I in 1 .. Registry.Count loop
         if To_String (Registry.Entries (I).Suite) = Suite_Name and then
            To_String (Registry.Entries (I).Name) = Test_Name then
            declare
               Status : Test_Status := Run_Single_Test_Internal (Registry.Entries (I));
            begin
               Found := True;
               
               if Output_Format = "text" then
                  case Status.Result is
                     when Result_Pass =>
                        Ada.Text_IO.Put_Line ("[PASS] " & To_String (Status.Name) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                     when Result_Fail =>
                        Ada.Text_IO.Put_Line ("[FAIL] " & To_String (Status.Name) & ": " & 
                                           To_String (Status.Message) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                     when Result_Error =>
                        Ada.Text_IO.Put_Line ("[ERROR] " & To_String (Status.Name) & ": " & 
                                           To_String (Status.Message) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                     when Result_Skip =>
                        Ada.Text_IO.Put_Line ("[SKIP] " & To_String (Status.Name) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                     when Result_Timeout =>
                        Ada.Text_IO.Put_Line ("[TIMEOUT] " & To_String (Status.Name) & 
                                           " [" & Provenance_Status_To_String (Status.Provenance) & 
                                           "/" & Type_Safe_Category_To_String (Status.Type_Safe_Category) & "]");
                  end case;
               end if;
               
               exit;
            end;
         end if;
      end loop;
      
      if not Found then
         Ada.Text_IO.Put_Line ("Test not found: " & Suite_Name & "." & Test_Name);
      end if;
   end Run_Single_Test;

   --  Convert provenance status to string
   function Provenance_Status_To_String (Status : Provenance_Status) return String is
   begin
      case Status is
         when Status_Actually_Proven =>
            return "Actually-Proven";
         when Status_Provisionally_Proven =>
            return "Provisionally-Proven";
         when Status_Unproven =>
            return "Unproven";
      end case;
   end Provenance_Status_To_String;

   --  Convert type-safe category to string
   function Type_Safe_Category_To_String (Cat : Type_Safe_Category) return String is
   begin
      case Cat is
         when Category_Tropical =>
            return "Tropical";
         when Category_Epistemic =>
            return "Epistemic";
         when Category_Choreographic =>
            return "Choreographic";
         when Category_Dependent =>
            return "Dependent";
         when Category_Effects =>
            return "Effects";
         when Category_Decorative =>
            return "Decorative";
         when Category_Ceremonial =>
            return "Ceremonial";
         when Category_Dyadic =>
            return "Dyadic";
         when Category_Echo_Types =>
            return "Echo-Types";
      end case;
   end Type_Safe_Category_To_String;

begin
   --  Initialize the global registry
   Initialize_Registry (Global_Registry);

end Test_Harness;
