--  Trigger - Main Application Specification
--  
--  Telegram channel reporting utility with multi-account management
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)
--  Rewritten in Ada/SPARK by hyperpolymath

with Ada.Strings.Unbounded;

package Trigger is

   --  Application version information
   Version_Major : constant Integer := 1;
   Version_Minor : constant Integer := 0;
   Version_Patch : constant Integer := 0;
   Version_String : constant String := "1.0.0";

   --  Application name
   App_Name : constant String := "Trigger";

   --  Original author attribution
   Original_Author : constant String := "2nixx (T.me/NetworkCriminals)";
   Original_Project : constant String := "Ripper";

end Trigger;
