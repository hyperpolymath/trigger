--  Trigger - CLI Help Generator Specification
--  
--  Generates and displays help text for the CLI.
--  
--  Author: hyperpolymath

package Trigger.CLI.Help_Generator is

   --  Display the help message
   procedure Display_Help;

   --  Get the help text as a string
   function Get_Help_Text return String;

end Trigger.CLI.Help_Generator;
