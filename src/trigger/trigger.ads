--  Trigger - Main Application Specification
--  
--  Telegram channel reporting utility with multi-account management
--  
--  Author: hyperpolymath

package Trigger is

   --  Application version information
   Version_Major : constant Integer := 1;
   Version_Minor : constant Integer := 0;
   Version_Patch : constant Integer := 0;
   Version_String : constant String := "1.0.0";

   --  Application name
   App_Name : constant String := "Trigger";
   App_Acronym : constant String := "TRG";

   --  Build information
   Build_Date : constant String := "2026-08-13";
   Build_Author : constant String := "hyperpolymath";

   --  Contact information
   Author_Name : constant String := "hyperpolymath";
   Author_Email : constant String := "hyperpolymath@users.noreply.github.com";
   Project_URL : constant String := "https://github.com/hyperpolymath/trigger";

   --  Exit codes
   Exit_Success : constant Integer := 0;
   Exit_General_Error : constant Integer := 1;
   Exit_Config_Error : constant Integer := 2;
   Exit_Auth_Error : constant Integer := 3;
   Exit_Network_Error : constant Integer := 4;
   Exit_API_Error : constant Integer := 5;
   Exit_Session_Error : constant Integer := 6;
   Exit_Validation_Error : constant Integer := 7;
   Exit_Dependency_Missing : constant Integer := 8;

   --  File paths
   Default_Config_File : constant String := "config.json";
   Default_Session_Dir : constant String := "./sessions";
   Default_Log_File : constant String := "trigger.log";

   --  Original attribution (required)
   Original_Concept : constant String := "Ripper";
   Original_Author : constant String := "2nixx (T.me/NetworkCriminals)";

end Trigger;
