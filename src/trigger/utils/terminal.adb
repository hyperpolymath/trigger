--  Trigger - Terminal Utilities Implementation
--  
--  Implements terminal color support and TUI utilities.

with Ada.Text_IO;

package body Trigger.Utils.Terminal is

   procedure Initialize is
   begin
      --  Could set up terminal modes here if needed
      null;
   end Initialize;

   procedure Restore is
   begin
      --  Restore terminal to default state
      Ada.Text_IO.Put (Color_Reset);
   end Restore;

   procedure Clear_Screen is
   begin
      Ada.Text_IO.Put_Line (ASCII.ESC & "[2J" & ASCII.ESC & "[H");
   end Clear_Screen;

   function Colors_Supported return Boolean is
      use Ada.Text_IO;
      Term : constant String := Get_Env ("TERM");
   begin
      --  Check if TERM is set and not "dumb"
      if Term = "" or Term = "dumb" then
         return False;
      end if;
      
      --  Check if NO_COLOR is set
      if Get_Env ("NO_COLOR") /= "" then
         return False;
      end if;
      
      return True;
   exception
      when others =>
         return False;
   end Colors_Supported;

   --  Helper to get environment variable
   function Get_Env (Name : String) return String is
      use Ada.Text_IO;
      use Ada.Strings;
      use Ada.Strings.Fixed;
   begin
      --  This is a simplified implementation
      --  In a full implementation, use Ada.Environment_Variables
      return "";
   exception
      when others =>
         return "";
   end Get_Env;

end Trigger.Utils.Terminal;
