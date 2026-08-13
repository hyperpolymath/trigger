--  Trigger - CLI Man Page Generator Specification
--  
--  Generates and displays the man page for the CLI.
--  
--  Author: hyperpolymath

package Trigger.CLI.Man_Page is

   --  Display the man page
   procedure Display_Man_Page;

   --  Get the man page text as a string
   function Get_Man_Page_Text return String;

end Trigger.CLI.Man_Page;
