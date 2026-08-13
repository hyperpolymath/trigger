--  Trigger - CLI Version Information Implementation
--  
--  Displays version and license information.
--  
--  Author: hyperpolymath

with Ada.Text_IO;
with Trigger;

package body Trigger.CLI.Version_Info is

   procedure Display_Version is
   begin
      Ada.Text_IO.Put_Line (Get_Version_String);
   end Display_Version;

   procedure Display_License is
   begin
      Ada.Text_IO.Put_Line (Get_License_Text);
   end Display_License;

   function Get_Version_String return String is
   begin
      return 
        Trigger.App_Name & " version " & Trigger.Version_String & ASCII.LF & 
        "Build date: " & Trigger.Build_Date & ASCII.LF & 
        "Author: " & Trigger.Author_Name & " <" & Trigger.Author_Email & ">" & ASCII.LF & 
        "Project URL: " & Trigger.Project_URL & ASCII.LF & 
        "" & ASCII.LF & 
        "Original concept: " & Trigger.Original_Concept & 
        " by " & Trigger.Original_Author & ASCII.LF & 
        "" & ASCII.LF & 
        "License: MPL-2.0 (code) / CC-BY-SA-4.0 (docs)";
   end Get_Version_String;

   function Get_License_Text return String is
   begin
      return 
        "Trigger - License Information" & ASCII.LF & 
        "==============================" & ASCII.LF & 
        "" & ASCII.LF & 
        "Code License:" & ASCII.LF & 
        "-------------" & ASCII.LF & 
        "Mozilla Public License Version 2.0" & ASCII.LF & 
        "" & ASCII.LF & 
        "This Source Code Form is subject to the terms of the Mozilla Public" & ASCII.LF & 
        "License, v. 2.0. If a copy of the MPL was not distributed with this file," & ASCII.LF & 
        "You can obtain one at https://www.mozilla.org/MPL/2.0/." & ASCII.LF & 
        "" & ASCII.LF & 
        "See the LICENSE file in the root directory for the full MPL-2.0 text." & ASCII.LF & 
        "" & ASCII.LF & 
        "Documentation License:" & ASCII.LF & 
        "---------------------" & ASCII.LF & 
        "Creative Commons Attribution-ShareAlike 4.0 International" & ASCII.LF & 
        "" & ASCII.LF & 
        "This documentation is licensed under the Creative Commons" & ASCII.LF & 
        "Attribution-ShareAlike 4.0 International License." & ASCII.LF & 
        "" & ASCII.LF & 
        "To view a copy of this license, visit" & ASCII.LF & 
        "https://creativecommons.org/licenses/by-sa/4.0/" & ASCII.LF & 
        "" & ASCII.LF & 
        "or see the LICENSES/ directory for both license texts." & ASCII.LF & 
        "" & ASCII.LF & 
        "Original Attribution:" & ASCII.LF & 
        "--------------------" & ASCII.LF & 
        "This project implements functionality originally designed in " & 
        Trigger.Original_Concept & " by " & Trigger.Original_Author & "." & ASCII.LF & 
        "The original concept and feature set are acknowledged with gratitude." & ASCII.LF & 
        "This implementation is a complete rewrite in Ada/SPARK with Zig FFI bindings," & ASCII.LF & 
        "and does not contain any code from the original project.";
   end Get_License_Text;

end Trigger.CLI.Version_Info;
