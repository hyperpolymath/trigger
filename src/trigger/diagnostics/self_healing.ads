--  Trigger - Diagnostics Self-Healing Specification
--  
--  Provides automatic issue detection and repair capabilities.
--  
--  Author: hyperpolymath

with Ada.Strings.Unbounded;
with Trigger.CLI.Argument_Parser;

package Trigger.Diagnostics.Self_Healing is

   --  Self-healing result type
   type Healing_Result is tagged record
      Success : Boolean;
      Action : Ada.Strings.Unbounded.Unbounded_String;
      Message : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   --  Run self-healing
   procedure Run_Self_Healing (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

   --  Fix configuration file issues
   procedure Fix_Configuration (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

   --  Fix file and directory permissions
   procedure Fix_Permissions (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

   --  Repair corrupted session files
   procedure Fix_Sessions (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

   --  Create missing configuration file
   function Create_Missing_Config (Config_Path : String) return Healing_Result;

   --  Create missing session directory
   function Create_Missing_Session_Dir (Session_Dir : String) return Healing_Result;

   --  Validate configuration values
   function Validate_Config_Values return Healing_Result;

   --  Display healing result
   procedure Display_Result (Result : Healing_Result);

end Trigger.Diagnostics.Self_Healing;
