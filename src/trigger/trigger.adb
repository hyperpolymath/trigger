--  Trigger - Main Application Entry Point
--  
--  Telegram channel reporting utility with multi-account management
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)
--  Rewritten in Ada/SPARK by hyperpolymath
--  
--  This is the main entry point for the Trigger application.
--  It provides an interactive TUI for managing Telegram accounts
--  and reporting channels.

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Exceptions;

with Trigger.Config;
with Trigger.Session.Session_Manager;
with Trigger.Session.Account_Types;
with Trigger.Reporting.Reporter;
with Trigger.Utils.Logging;
with Trigger.Utils.Terminal;

procedure Trigger is

   --  Main application type
   type Application is tagged private;

   --  Application state
   type App_State is (State_Main_Menu, State_Add_Account, State_List_Accounts,
                     State_Remove_Account, State_Reporting, State_Set_API,
                     State_Exit);

   --  Main application record
   type Application is tagged record
      Config      : Config.Configuration;
      Session_Mgr : Session_Manager.Session_Manager_Type;
      Logger      : Logging.Logger_Type;
      Current_State : App_State := State_Main_Menu;
   end record;

   --  Initialize the application
   procedure Initialize (App : in out Application);

   --  Run the main application loop
   procedure Run (App : in out Application);

   --  Display the main menu
   procedure Display_Main_Menu;

   --  Clean up resources
   procedure Cleanup (App : in out Application);

   --  Exception handler
   procedure Handle_Exception (E : Exception_Occurrence);

   --  ============================================================
   --  Main Program
   --  ============================================================

   Main_App : Application;

begin
   Terminal.Initialize;
   
   begin
      Initialize (Main_App);
      Run (Main_App);
      Cleanup (Main_App);
   exception
      when E : others =>
         Handle_Exception (E);
         Cleanup (Main_App);
   end;
   
   Terminal.Restore;

end Trigger;

--  ============================================================
--  Implementation
--  ============================================================

procedure Initialize (App : in out Application) is
begin
   --  Initialize logging
   Logging.Initialize (App.Logger);
   
   --  Load configuration
   Config.Load (App.Config);
   
   --  Initialize session manager
   Session_Manager.Initialize (App.Session_Mgr, App.Config.Session_Directory);
   
   Logging.Info (App.Logger, "Trigger initialized successfully");
end Initialize;

procedure Display_Main_Menu is
begin
   Terminal.Clear_Screen;
   
   Ada.Text_IO.Put_Line (Terminal.Color_Red & "   ██████╗ ██╗██████╗ ██████╗ ███████╗██████╗" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Red & "   ██╔══██╗██║██╔══██╗██╔══██╗██╔════╝██╔══██╗" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Red & "   ██████╔╝██║██████╔╝██████╔╝█████╗  ██████╔╝" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Red & "   ██╔══██╗██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Red & "   ██║  ██║██║██║     ██║     ███████╗██║  ██║" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Red & "   ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝" & Terminal.Color_Reset);
   Ada.Text_IO.New_Line;
   
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ╔═══════════════════════════════════════════════╗" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ║ " & Terminal.Color_Red & "        Written by T.me/NetworkCriminals               " & Terminal.Color_Yellow & "║" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ╠═══════════════════════════════════════════════╣" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ║  " & Terminal.Color_Cyan & "1." & Terminal.Color_White & " Add Account                         " & Terminal.Color_Yellow & "║" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ║  " & Terminal.Color_Cyan & "2." & Terminal.Color_White & " List Accounts                       " & Terminal.Color_Yellow & "║" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ║  " & Terminal.Color_Cyan & "3." & Terminal.Color_White & " Remove Account                      " & Terminal.Color_Yellow & "║" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ║  " & Terminal.Color_Cyan & "4." & Terminal.Color_White & " Start Reporting                     " & Terminal.Color_Yellow & "║" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ║  " & Terminal.Color_Cyan & "5." & Terminal.Color_White & " Set API Credentials                 " & Terminal.Color_Yellow & "║" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ║  " & Terminal.Color_Red & "6." & Terminal.Color_White & " Exit                               " & Terminal.Color_Yellow & "║" & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "  ╚═══════════════════════════════════════════════╝" & Terminal.Color_Reset);
   Ada.Text_IO.New_Line;
end Display_Main_Menu;

procedure Handle_Exception (E : Exception_Occurrence) is
   Message : constant String := Ada.Exceptions.Exception_Message (E);
begin
   Ada.Text_IO.Put_Line (Terminal.Color_Red & "[ERROR] " & Message & Terminal.Color_Reset);
   Ada.Text_IO.Put_Line (Terminal.Color_Red & "[!] Interrupted by user" & Terminal.Color_Reset);
exception
   when others =>
      Ada.Text_IO.Put_Line (Terminal.Color_Red & "[CRITICAL] Unknown exception occurred" & Terminal.Color_Reset);
end Handle_Exception;

procedure Cleanup (App : in out Application) is
begin
   Session_Manager.Finalize (App.Session_Mgr);
   Config.Save (App.Config);
   Logging.Finalize (App.Logger);
end Cleanup;

procedure Run (App : in out Application) is
   Choice : String (1 .. 10);
   Last  : Natural;
   Phone : Ada.Strings.Unbounded.Unbounded_String;
   Channel : Ada.Strings.Unbounded.Unbounded_String;
   Count : Integer;
   Delay : Float;
   Option : Ada.Strings.Unbounded.Unbounded_String;
   API_ID : Integer;
   API_Hash : Ada.Strings.Unbounded.Unbounded_String;
begin
   loop
      Display_Main_Menu;
      
      Ada.Text_IO.Put (Terminal.Color_Cyan & "Select option (1-6): " & Terminal.Color_Reset);
      Ada.Text_IO.Get_Line (Choice, Last);
      
      case Choice (1 .. Last) is
         when "1" =>
            --  Add Account
            App.Current_State := State_Add_Account;
            Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "--- Add Account ---" & Terminal.Color_Reset);
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "Phone number with country code: " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (Phone);
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "API ID: " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (Choice, Last);
            API_ID := Integer'Value (Choice (1 .. Last));
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "API Hash: " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (API_Hash);
            
            --  Create session and add account
            declare
               Session_Name : constant String := 
                 Session_Manager.Generate_Session_Name (Ada.Strings.Unbounded.To_String (Phone));
               Success : Boolean;
               Error_Msg : Ada.Strings.Unbounded.Unbounded_String;
            begin
               Session_Manager.Create_Session (
                  App.Session_Mgr,
                  API_ID,
                  Ada.Strings.Unbounded.To_String (API_Hash),
                  Ada.Strings.Unbounded.To_String (Phone),
                  Session_Name,
                  Success,
                  Error_Msg
               );
               
               if Success then
                  Session_Manager.Add_Account (
                     App.Session_Mgr,
                     Ada.Strings.Unbounded.To_String (Phone),
                     Session_Name
                  );
                  Logging.Success (App.Logger, "Account " & Ada.Strings.Unbounded.To_String (Phone) & " added successfully");
               else
                  Logging.Fail (App.Logger, "Failed to add account: " & Ada.Strings.Unbounded.To_String (Error_Msg));
               end if;
            end;
            
            Ada.Text_IO.Put_Line (Terminal.Color_Cyan & "Press Enter to continue..." & Terminal.Color_Reset);
            Ada.Text_IO.Skip_Line;

         when "2" =>
            --  List Accounts
            App.Current_State := State_List_Accounts;
            Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "--- List Accounts ---" & Terminal.Color_Reset);
            
            declare
               Accounts : Session_Manager.Account_List := 
                 Session_Manager.Get_Accounts (App.Session_Mgr);
            begin
               if Accounts'Length = 0 then
                  Logging.Warning (App.Logger, "No accounts found");
               else
                  Logging.Info (App.Logger, "Found " & Integer'Image (Accounts'Length) & " account(s)");
                  for I in Accounts'Range loop
                     declare
                        Status : constant String := 
                          (if Accounts (I).Is_Active then "Active" else "Inactive");
                     begin
                        Logging.Info (App.Logger, "  " & Accounts (I).Phone & " | " & 
                                   Status & " | Reports: " & Integer'Image (Accounts (I).Report_Count));
                     end;
                  end loop;
               end if;
            end;
            
            Ada.Text_IO.Put_Line (Terminal.Color_Cyan & "Press Enter to continue..." & Terminal.Color_Reset);
            Ada.Text_IO.Skip_Line;

         when "3" =>
            --  Remove Account
            App.Current_State := State_Remove_Account;
            Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "--- Remove Account ---" & Terminal.Color_Reset);
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "Phone number to remove: " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (Phone);
            
            if Session_Manager.Remove_Account (
               App.Session_Mgr,
               Ada.Strings.Unbounded.To_String (Phone)
            ) then
               Logging.Success (App.Logger, "Account " & Ada.Strings.Unbounded.To_String (Phone) & " removed");
            else
               Logging.Fail (App.Logger, "Account " & Ada.Strings.Unbounded.To_String (Phone) & " not found");
            end if;
            
            Ada.Text_IO.Put_Line (Terminal.Color_Cyan & "Press Enter to continue..." & Terminal.Color_Reset);
            Ada.Text_IO.Skip_Line;

         when "4" =>
            --  Start Reporting
            App.Current_State := State_Reporting;
            Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "--- Start Reporting ---" & Terminal.Color_Reset);
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "Channel username (without @): " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (Channel);
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "Number of messages to report (default 3): " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (Choice, Last);
            if Last > 0 then
               Count := Integer'Value (Choice (1 .. Last));
            else
               Count := 3;
            end if;
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "Delay between reports in seconds (default 2.0): " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (Choice, Last);
            if Last > 0 then
               Delay := Float'Value (Choice (1 .. Last));
            else
               Delay := 2.0;
            end if;
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "Report option (spam, violence, etc.): " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (Option);
            
            --  Start reporting with all active accounts
            declare
               Active_Accounts : Session_Manager.Account_List := 
                 Session_Manager.Get_Active_Accounts (App.Session_Mgr);
               Success_Count : Integer := 0;
            begin
               if Active_Accounts'Length = 0 then
                  Logging.Error (App.Logger, "No active accounts found. Add an account first.");
               else
                  Logging.Info (App.Logger, "Starting reporting on " & 
                             Ada.Strings.Unbounded.To_String (Channel) & 
                             " with " & Integer'Image (Active_Accounts'Length) & " account(s)");
                  
                  for I in Active_Accounts'Range loop
                     declare
                        Client : Reporter.Telegram_Client_Type;
                        Reporter : Reporter.Reporter_Type;
                        Result : Boolean;
                        Stats : Reporter.Report_Stats;
                     begin
                        Logging.Info (App.Logger, "Using account: " & Active_Accounts (I).Phone);
                        
                        --  Initialize client for this account
                        Reporter.Initialize (
                           Client,
                           Reporter,
                           App.Config.API_ID,
                           App.Config.API_Hash,
                           Active_Accounts (I).Session_Name,
                           App.Logger
                        );
                        
                        --  Report last messages
                        Reporter.Report_Last_Messages (
                           Reporter,
                           Client,
                           Ada.Strings.Unbounded.To_String (Channel),
                           Count,
                           Delay,
                           Ada.Strings.Unbounded.To_String (Option),
                           Result,
                           Stats
                        );
                        
                        if Result then
                           Success_Count := Success_Count + 1;
                           Session_Manager.Mark_Account_Used (
                              App.Session_Mgr,
                              Active_Accounts (I).Phone
                           );
                        end if;
                        
                        Logging.Info (App.Logger,
                           "Account " & Active_Accounts (I).Phone & ": " &
                           Integer'Image (Stats.Report_Count) & " reports, " &
                           Integer'Image (Stats.Error_Count) & " errors");
                        
                        Reporter.Finalize (Client);
                     exception
                        when E : others =>
                           Logging.Error (App.Logger, "Error with " & Active_Accounts (I).Phone & ": " &
                                       Ada.Exceptions.Exception_Message (E));
                     end;
                  end loop;
                  
                  Logging.Success (App.Logger, "Completed: " & 
                                 Integer'Image (Success_Count) & "/" & 
                                 Integer'Image (Active_Accounts'Length) & " accounts succeeded");
               end if;
            end;
            
            Ada.Text_IO.Put_Line (Terminal.Color_Cyan & "Press Enter to continue..." & Terminal.Color_Reset);
            Ada.Text_IO.Skip_Line;

         when "5" =>
            --  Set API Credentials
            App.Current_State := State_Set_API;
            Ada.Text_IO.Put_Line (Terminal.Color_Yellow & "--- Set API Credentials ---" & Terminal.Color_Reset);
            Ada.Text_IO.Put_Line (Terminal.Color_White & "You can get these from https://my.telegram.org/apps" & Terminal.Color_Reset);
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "API ID: " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (Choice, Last);
            App.Config.API_ID := Integer'Value (Choice (1 .. Last));
            
            Ada.Text_IO.Put (Terminal.Color_Cyan & "API Hash: " & Terminal.Color_Reset);
            Ada.Text_IO.Get_Line (API_Hash);
            App.Config.API_Hash := Ada.Strings.Unbounded.To_Unbounded_String (API_Hash);
            
            Logging.Success (App.Logger, "API credentials saved");
            
            Ada.Text_IO.Put_Line (Terminal.Color_Cyan & "Press Enter to continue..." & Terminal.Color_Reset);
            Ada.Text_IO.Skip_Line;

         when "6" =>
            --  Exit
            App.Current_State := State_Exit;
            Logging.Info (App.Logger, "Exiting Trigger");
            exit;

         when others =>
            Ada.Text_IO.Put_Line (Terminal.Color_Red & "Invalid option. Please choose 1-6." & Terminal.Color_Reset);
            Ada.Text_IO.Put_Line (Terminal.Color_Cyan & "Press Enter to continue..." & Terminal.Color_Reset);
            Ada.Text_IO.Skip_Line;
      end case;
   end loop;
end Run;
