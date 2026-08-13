--  Trigger - Core Application Package Specification
--  
--  Provides the main application type and lifecycle management.
--  
--  Author: hyperpolymath

with Ada.Strings.Unbounded;
with Trigger.CLI.Argument_Parser;

package Trigger.Core.Application is

   --  Application type
   type Application_Type is tagged private;

   --  Initialize the application
   procedure Initialize (App : out Application_Type);

   --  Finalize the application
   procedure Finalize (App : in out Application_Type);

   --  Execute reporting operation
   procedure Execute_Reporting (
      App : in out Application_Type;
      Args : Argument_Parser.Argument_List;
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   );

private

   --  Application record
   type Application_Type is tagged record
      --  Configuration from CLI
      Config : Argument_Parser.Configuration_Type;
      
      --  Application state
      Is_Initialized : Boolean := False;
      
      --  Component states
      Session_Manager_Initialized : Boolean := False;
      Reporter_Initialized : Boolean := False;
   end record;

end Trigger.Core.Application;
