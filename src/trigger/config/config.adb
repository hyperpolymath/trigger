--  Trigger - Configuration Package Implementation
--  
--  Manages application configuration including API credentials,
--  session settings, proxy configuration, and logging preferences.

with Ada.Text_IO;
with Ada.Direct_IO;
with Ada.Strings.Unbounded;

package body Trigger.Config is

   --  JSON parsing would be implemented here
   --  For now, using a simple text-based format
   --  In a full implementation, this would use a proper JSON parser

   procedure Load (Config : out Configuration) is
      File : Ada.Text_IO.File_Type;
      Found : Boolean := False;
   begin
      --  Try to open config file
      begin
         Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Config_File_Name);
         Found := True;
         Ada.Text_IO.Close (File);
      exception
         when Ada.Text_IO.Name_Error =>
            Found := False;
      end;

      if Found then
         --  In a full implementation, parse JSON here
         --  For now, use defaults
         Config := Get_Default;
      else
         Config := Get_Default;
      end if;
   end Load;

   procedure Save (Config : Configuration) is
      File : Ada.Text_IO.File_Type;
   begin
      Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Config_File_Name);
      
      --  In a full implementation, write JSON here
      --  For now, write a simple representation
      Ada.Text_IO.Put_Line (File, "{");
      Ada.Text_IO.Put_Line (File, "  \"telethon\": {");
      Ada.Text_IO.Put_Line (File, "    \"api_id\": " & Integer'Image (Config.API_ID) & ",");
      Ada.Text_IO.Put_Line (File, "    \"api_hash\": \"" & 
                           Ada.Strings.Unbounded.To_String (Config.API_Hash) & "\"");
      Ada.Text_IO.Put_Line (File, "  },");
      Ada.Text_IO.Put_Line (File, "  \"report\": {");
      Ada.Text_IO.Put_Line (File, "    \"default_delay\": " & Float'Image (Config.Default_Delay) & ",");
      Ada.Text_IO.Put_Line (File, "    \"max_messages\": " & Integer'Image (Config.Default_Message_Count) & ",");
      Ada.Text_IO.Put_Line (File, "    \"option\": \"" & 
                           Ada.Strings.Unbounded.To_String (Config.Default_Report_Option) & "\"");
      Ada.Text_IO.Put_Line (File, "  },");
      Ada.Text_IO.Put_Line (File, "  \"proxy\": {");
      Ada.Text_IO.Put_Line (File, "    \"enabled\": " & Boolean'Image (Config.Proxy_Enabled) & ",");
      Ada.Text_IO.Put_Line (File, "    \"type\": \"" & 
                           Ada.Strings.Unbounded.To_String (Config.Proxy_Type) & "\",");
      Ada.Text_IO.Put_Line (File, "    \"host\": \"" & 
                           Ada.Strings.Unbounded.To_String (Config.Proxy_Host) & "\",");
      Ada.Text_IO.Put_Line (File, "    \"port\": " & Integer'Image (Config.Proxy_Port));
      Ada.Text_IO.Put_Line (File, "  },");
      Ada.Text_IO.Put_Line (File, "  \"crypto\": {");
      Ada.Text_IO.Put_Line (File, "    \"encrypt_sessions\": " & Boolean'Image (Config.Encrypt_Sessions) & ",");
      Ada.Text_IO.Put_Line (File, "    \"salt\": \"" & 
                           Ada.Strings.Unbounded.To_String (Config.Crypto_Salt) & "\"");
      Ada.Text_IO.Put_Line (File, "  },");
      Ada.Text_IO.Put_Line (File, "  \"logging\": {");
      Ada.Text_IO.Put_Line (File, "    \"level\": \"" & 
                           Ada.Strings.Unbounded.To_String (Config.Log_Level) & "\",");
      Ada.Text_IO.Put_Line (File, "    \"colorized\": " & Boolean'Image (Config.Log_Colorized));
      Ada.Text_IO.Put_Line (File, "  }");
      Ada.Text_IO.Put_Line (File, "}");
      
      Ada.Text_IO.Close (File);
   exception
      when E : others =>
         if Ada.Text_IO.Is_Open (File) then
            Ada.Text_IO.Close (File);
         end if;
         raise;
   end Save;

   function Get_Default return Configuration is
   begin
      return Configuration'(Ada.Strings.Unbounded.To_Unbounded_String (Default_Session_Directory));
   end Get_Default;

end Trigger.Config;
