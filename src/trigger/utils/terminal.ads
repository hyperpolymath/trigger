--  Trigger - Terminal Utilities Specification
--  
--  Provides terminal color support and utilities for TUI applications.
--  
--  Original concept by 2nixx (T.me/NetworkCriminals)

package Trigger.Utils.Terminal is

   --  ANSI color codes
   Color_Reset : constant String := ASCII.ESC & "[0m";
   Color_Black : constant String := ASCII.ESC & "[30m";
   Color_Red : constant String := ASCII.ESC & "[31m";
   Color_Green : constant String := ASCII.ESC & "[32m";
   Color_Yellow : constant String := ASCII.ESC & "[33m";
   Color_Blue : constant String := ASCII.ESC & "[34m";
   Color_Magenta : constant String := ASCII.ESC & "[35m";
   Color_Cyan : constant String := ASCII.ESC & "[36m";
   Color_White : constant String := ASCII.ESC & "[37m";

   Color_Bold : constant String := ASCII.ESC & "[1m";
   Color_Dim : constant String := ASCII.ESC & "[2m";
   Color_Underline : constant String := ASCII.ESC & "[4m";

   --  Initialize terminal
   procedure Initialize;

   --  Restore terminal state
   procedure Restore;

   --  Clear screen
   procedure Clear_Screen;

   --  Check if colors are supported
   function Colors_Supported return Boolean;

end Trigger.Utils.Terminal;
