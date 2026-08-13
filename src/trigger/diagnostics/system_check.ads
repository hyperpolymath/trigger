--  Trigger - Diagnostics System Check Specification
--  
--  Provides comprehensive self-diagnostic capabilities.
--  
--  Author: hyperpolymath

with Ada.Strings.Unbounded;
with Trigger.CLI.Argument_Parser;

package Trigger.Diagnostics.System_Check is

   --  Check status type
   type Check_Status is (Status_OK, Status_Warning, Status_Error);

   --  Diagnostic result type
   type Diagnostic_Result is tagged record
      Status : Check_Status;
      Description : Ada.Strings.Unbounded.Unbounded_String;
      Details : Ada.Strings.Unbounded.Unbounded_String;
      Suggestion : Ada.Strings.Unbounded.Unbounded_String;
      Can_Fix : Boolean := False;
   end record;

   --  Run comprehensive self-diagnostics
   procedure Run_Diagnostics (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

   --  Check for required dependencies
   procedure Check_Dependencies (Exit_Code : out Integer);

   --  Validate configuration files
   procedure Check_Configuration (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

   --  Verify session files
   procedure Check_Sessions (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

   --  Run a quick health check
   procedure Run_Health_Check (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

   --  Check GNAT compiler availability
   function Check_GNAT_Available return Diagnostic_Result;

   --  Check Zig compiler availability
   function Check_Zig_Available return Diagnostic_Result;

   --  Check Idris2 compiler availability (optional)
   function Check_Idris2_Available return Diagnostic_Result;

   --  Check configuration file validity
   function Check_Config_File (Config_Path : String) return Diagnostic_Result;

   --  Check session directory
   function Check_Session_Directory (Session_Dir : String) return Diagnostic_Result;

   --  Check disk space
   function Check_Disk_Space return Diagnostic_Result;

   --  Display diagnostic result
   procedure Display_Result (Result : Diagnostic_Result);

end Trigger.Diagnostics.System_Check;
