--  Trigger - CLI Version Information Specification
--  
--  Displays version and license information.
--  
--  Author: hyperpolymath

package Trigger.CLI.Version_Info is

   --  Display version information
   procedure Display_Version;

   --  Display license information
   procedure Display_License;

   --  Get the version string
   function Get_Version_String return String;

   --  Get the license text
   function Get_License_Text return String;

end Trigger.CLI.Version_Info;
