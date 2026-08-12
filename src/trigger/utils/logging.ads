--  Trigger - Logging Package Specification
--  
--  Provides logging functionality with different log levels and colors.
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)

with Ada.Text_IO;

package Trigger.Utils.Logging is

   --  Log level type
   type Log_Level is (Debug, Info, Warning, Error);

   --  Logger type
   type Logger_Type is tagged private;

   --  Initialize the logger
   procedure Initialize (Logger : out Logger_Type);

   --  Finalize the logger
   procedure Finalize (Logger : in out Logger_Type);

   --  Set log level
   procedure Set_Level (Logger : in out Logger_Type; Level : Log_Level);

   --  Set colorized output
   procedure Set_Colorized (Logger : in out Logger_Type; Enabled : Boolean);

   --  Log messages at different levels
   procedure Debug (Logger : Logger_Type; Message : String);
   procedure Info (Logger : Logger_Type; Message : String);
   procedure Warning (Logger : Logger_Type; Message : String);
   procedure Error (Logger : Logger_Type; Message : String);

   --  Success and failure messages (convenience)
   procedure Success (Logger : Logger_Type; Message : String);
   procedure Fail (Logger : Logger_Type; Message : String);

private

   --  Logger record
   type Logger_Type is tagged record
      Current_Level : Log_Level := Info;
      Colorized : Boolean := True;
   end record;

end Trigger.Utils.Logging;
