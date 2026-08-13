--  Trigger - Diagnostics Self-Healing Implementation
--  
--  Provides automatic issue detection and repair capabilities.
--  
--  Author: hyperpolymath

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Directories;

package body Trigger.Diagnostics.Self_Healing is

   use Ada.Strings.Unbounded;

   --  Display healing result
   procedure Display_Result (Result : Healing_Result) is
   begin
      if Result.Success then
         Ada.Text_IO.Put_Line ("[FIXED] " & To_String (Result.Action));
      else
         Ada.Text_IO.Put_Line ("[FAILED] " & To_String (Result.Action));
      end if;
      
      if Length (Result.Message) > 0 then
         Ada.Text_IO.Put_Line ("    " & To_String (Result.Message));
      end if;
   end Display_Result;

   --  Create missing configuration file
   function Create_Missing_Config (Config_Path : String) return Healing_Result is
      Result : Healing_Result;
   begin
      Result.Action := To_Unbounded_String ("Create configuration file: " & Config_Path);
      
      begin
         --  Check if file exists
         if Ada.Directories.Exists (Config_Path) then
            Result.Success := True;
            Result.Message := To_Unbounded_String ("Configuration file already exists");
            return Result;
         end if;
         
         --  Create default configuration
         declare
            File : Ada.Text_IO.File_Type;
         begin
            Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Config_Path);
            Ada.Text_IO.Put_Line (File, "{");
            Ada.Text_IO.Put_Line (File, "  ""api_id"": 0,");
            Ada.Text_IO.Put_Line (File, "  ""api_hash"": """,");
            Ada.Text_IO.Put_Line (File, "  ""session_dir"": ""sessions"",");
            Ada.Text_IO.Put_Line (File, "  ""log_level"": ""info"",");
            Ada.Text_IO.Put_Line (File, "  ""accounts"": []");
            Ada.Text_IO.Put_Line (File, "}");
            Ada.Text_IO.Close (File);
            
            Result.Success := True;
            Result.Message := To_Unbounded_String ("Default configuration file created");
         exception
            when E : others =>
               Result.Success := False;
               Result.Message := To_Unbounded_String ("Error creating configuration file: " & 
                        Ada.Exceptions.Exception_Message (E));
               if Ada.Text_IO.Is_Open (File) then
                  Ada.Text_IO.Close (File);
               end if;
         end;
      exception
         when E : others =>
            Result.Success := False;
            Result.Message := To_Unbounded_String ("Error: " & Ada.Exceptions.Exception_Message (E));
      end;
      
      return Result;
   end Create_Missing_Config;

   --  Create missing session directory
   function Create_Missing_Session_Dir (Session_Dir : String) return Healing_Result is
      Result : Healing_Result;
   begin
      Result.Action := To_Unbounded_String ("Create session directory: " & Session_Dir);
      
      begin
         --  Check if directory exists
         if Ada.Directories.Exists (Session_Dir) then
            Result.Success := True;
            Result.Message := To_Unbounded_String ("Session directory already exists");
            return Result;
         end if;
         
         --  Create directory
         Ada.Directories.Create_Directory (New_Directory => Session_Dir);
         Result.Success := True;
         Result.Message := To_Unbounded_String ("Session directory created");
      exception
         when E : others =>
            Result.Success := False;
            Result.Message := To_Unbounded_String ("Error creating session directory: " & 
                     Ada.Exceptions.Exception_Message (E));
      end;
      
      return Result;
   end Create_Missing_Session_Dir;

   --  Validate configuration values
   function Validate_Config_Values return Healing_Result is
      Result : Healing_Result;
   begin
      Result.Action := To_Unbounded_String ("Validate configuration values");
      Result.Success := True;
      Result.Message := To_Unbounded_String ("Configuration values validated (placeholder)");
      return Result;
   end Validate_Config_Values;

   --  Fix configuration file issues
   procedure Fix_Configuration (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   ) is
      use type Ada.Strings.Unbounded.Unbounded_String;
   begin
      Ada.Text_IO.Put_Line ("Fixing configuration file issues...");
      Ada.Text_IO.Put_Line ("");
      
      --  Check and create config file if needed
      if Length (Config.Config_File) > 0 then
         declare
            Result : Healing_Result := Create_Missing_Config (To_String (Config.Config_File));
         begin
            Display_Result (Result);
            if not Result.Success then
               Exit_Code := 1;
               return;
            end if;
         end;
      else
         declare
            Result : Healing_Result := Create_Missing_Config ("config.json");
         begin
            Display_Result (Result);
            if not Result.Success then
               Exit_Code := 1;
               return;
            end if;
         end;
      end if;
      
      --  Validate configuration values
      declare
         Result : Healing_Result := Validate_Config_Values;
      begin
         Display_Result (Result);
      end;
      
      Ada.Text_IO.Put_Line ("");
      Exit_Code := 0;
   end Fix_Configuration;

   --  Fix file and directory permissions
   procedure Fix_Permissions (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   ) is
      use type Ada.Strings.Unbounded.Unbounded_String;
   begin
      Ada.Text_IO.Put_Line ("Fixing file and directory permissions...");
      Ada.Text_IO.Put_Line ("");
      
      --  For now, just report that we would fix permissions
      Ada.Text_IO.Put_Line ("[INFO] Permission fixing would be implemented for production use");
      
      Ada.Text_IO.Put_Line ("");
      Exit_Code := 0;
   end Fix_Permissions;

   --  Repair corrupted session files
   procedure Fix_Sessions (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   ) is
      use type Ada.Strings.Unbounded.Unbounded_String;
   begin
      Ada.Text_IO.Put_Line ("Repairing corrupted session files...");
      Ada.Text_IO.Put_Line ("");
      
      --  Check and create session directory if needed
      if Length (Config.Session_Dir) > 0 then
         declare
            Result : Healing_Result := Create_Missing_Session_Dir (To_String (Config.Session_Dir));
         begin
            Display_Result (Result);
         end;
      else
         declare
            Result : Healing_Result := Create_Missing_Session_Dir ("sessions");
         begin
            Display_Result (Result);
         end;
      end if;
      
      --  For now, we don't actually repair session files
      --  This would be implemented in a real version
      Ada.Text_IO.Put_Line ("[INFO] Session file repair would be implemented for production use");
      
      Ada.Text_IO.Put_Line ("");
      Exit_Code := 0;
   end Fix_Sessions;

   --  Run self-healing
   procedure Run_Self_Healing (
      Config : Argument_Parser.Configuration_Type;
      Exit_Code : out Integer
   ) is
   begin
      Ada.Text_IO.Put_Line ("Running self-healing...");
      Ada.Text_IO.Put_Line ("");
      
      --  Fix configuration
      Ada.Text_IO.Put_Line ("=== Configuration Fixes ===");
      Fix_Configuration (Config, Exit_Code);
      if Exit_Code /= 0 then
         return;
      end if;
      
      --  Fix permissions
      Ada.Text_IO.Put_Line ("=== Permission Fixes ===");
      Fix_Permissions (Config, Exit_Code);
      if Exit_Code /= 0 then
         return;
      end if;
      
      --  Fix sessions
      Ada.Text_IO.Put_Line ("=== Session Fixes ===");
      Fix_Sessions (Config, Exit_Code);
      if Exit_Code /= 0 then
         return;
      end if;
      
      Ada.Text_IO.Put_Line ("");
      Ada.Text_IO.Put_Line ("Self-healing completed");
   end Run_Self_Healing;

end Trigger.Diagnostics.Self_Healing;
