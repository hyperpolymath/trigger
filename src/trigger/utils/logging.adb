--  Trigger - Logging Package Implementation
--  
--  Implements logging with different levels and optional colors.

with Ada.Text_IO;
with Ada.Calendar;
with Ada.Strings.Fixed;

with Trigger.Utils.Terminal;

package body Trigger.Utils.Logging is

   --  Convert log level to string
   function Level_To_String (Level : Log_Level) return String is
   begin
      case Level is
         when Debug => return "DEBUG";
         when Info => return "INFO";
         when Warning => return "WARNING";
         when Error => return "ERROR";
      end case;
   end Level_To_String;

   --  Get color for log level
   function Level_To_Color (Level : Log_Level) return String is
   begin
      case Level is
         when Debug => return Terminal.Color_Cyan;
         when Info => return Terminal.Color_Green;
         when Warning => return Terminal.Color_Yellow;
         when Error => return Terminal.Color_Red;
      end case;
   end Level_To_Color;

   procedure Initialize (Logger : out Logger_Type) is
   begin
      Logger.Current_Level := Info;
      Logger.Colorized := True;
   end Initialize;

   procedure Finalize (Logger : in out Logger_Type) is
   begin
      --  Flush any buffered output
      null;
   end Finalize;

   procedure Set_Level (Logger : in out Logger_Type; Level : Log_Level) is
   begin
      Logger.Current_Level := Level;
   end Set_Level;

   procedure Set_Colorized (Logger : in out Logger_Type; Enabled : Boolean) is
   begin
      Logger.Colorized := Enabled and Terminal.Colors_Supported;
   end Set_Colorized;

   procedure Log (Logger : Logger_Type; Level : Log_Level; Message : String) is
      Timestamp : constant String := 
         Ada.Calendar.Formatting.Image (
            Ada.Calendar.Clock,
            "%Y-%m-%d %H:%M:%S"
         );
      Level_Str : constant String := Level_To_String (Level);
      Prefix : constant String := "[" & Timestamp & "] [" & Level_Str & "]";
      Color : constant String := (if Logger.Colorized then Level_To_Color (Level) else "");
      Reset : constant String := (if Logger.Colorized then Terminal.Color_Reset else "");
   begin
      --  Check if we should log this level
      if Level >= Logger.Current_Level then
         Ada.Text_IO.Put_Line (Color & Prefix & " " & Message & Reset);
      end if;
   end Log;

   procedure Debug (Logger : Logger_Type; Message : String) is
   begin
      if Logger.Current_Level <= Debug then
         Log (Logger, Debug, Message);
      end if;
   end Debug;

   procedure Info (Logger : Logger_Type; Message : String) is
   begin
      if Logger.Current_Level <= Info then
         Log (Logger, Info, Message);
      end if;
   end Info;

   procedure Warning (Logger : Logger_Type; Message : String) is
   begin
      if Logger.Current_Level <= Warning then
         Log (Logger, Warning, Message);
      end if;
   end Warning;

   procedure Error (Logger : Logger_Type; Message : String) is
   begin
      if Logger.Current_Level <= Error then
         Log (Logger, Error, Message);
      end if;
   end Error;

   procedure Success (Logger : Logger_Type; Message : String) is
      Color : constant String := (if Logger.Colorized then Terminal.Color_Green else "");
      Reset : constant String := (if Logger.Colorized then Terminal.Color_Reset else "");
   begin
      if Logger.Current_Level <= Info then
         Info (Logger, Color & Message & Reset);
      end if;
   end Success;

   procedure Fail (Logger : Logger_Type; Message : String) is
      Color : constant String := (if Logger.Colorized then Terminal.Color_Red else "");
      Reset : constant String := (if Logger.Colorized then Terminal.Color_Reset else "");
   begin
      if Logger.Current_Level <= Error then
         Error (Logger, color & Message & Reset);
      end if;
   end Fail;

end Trigger.Utils.Logging;
