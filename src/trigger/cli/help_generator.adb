--  Trigger - CLI Help Generator Implementation
--  
--  Generates and displays help text for the CLI.
--  
--  Author: hyperpolymath

with Ada.Text_IO;

package body Trigger.CLI.Help_Generator is

   procedure Display_Help is
   begin
      Ada.Text_IO.Put_Line (Get_Help_Text);
   end Display_Help;

   function Get_Help_Text return String is
   begin
      return 
        "Usage: trigger [OPTIONS] [COMMAND]" & ASCII.LF & 
        "" & ASCII.LF & 
        "Telegram channel reporting utility with multi-account management." & ASCII.LF & 
        "" & ASCII.LF & 
        "Informational Options:" & ASCII.LF & 
        "  -h, --help           Show this help message and exit" & ASCII.LF & 
        "  --man                Display the full man page and exit" & ASCII.LF & 
        "  -v, --version        Show version information and exit" & ASCII.LF & 
        "  --license            Show license information and exit" & ASCII.LF & 
        "" & ASCII.LF & 
        "Configuration Options:" & ASCII.LF & 
        "  -c FILE, --config FILE     Use the specified configuration file" & ASCII.LF & 
        "  --save-config              Save the current configuration to file" & ASCII.LF & 
        "  --reset-config             Reset configuration to default values" & ASCII.LF & 
        "" & ASCII.LF & 
        "API Credentials Options:" & ASCII.LF & 
        "  -a ID, --api-id ID          Set the Telegram API ID" & ASCII.LF & 
        "  --api-hash HASH            Set the Telegram API hash" & ASCII.LF & 
        "  --set-credentials         Set API credentials interactively" & ASCII.LF & 
        "" & ASCII.LF & 
        "Platform Selection Options:" & ASCII.LF & 
        "  -P PLATFORM, --platform PLATFORM    Set the platform (telegram, discord, twitter)" & ASCII.LF & 
        "  --list-platforms          List all supported platforms and exit" & ASCII.LF & 
        "  --discord-token TOKEN     Set the Discord bot/user token" & ASCII.LF & 
        "  --twitter-token TOKEN     Set the Twitter bearer token" & ASCII.LF & 
        "" & ASCII.LF & 
        "Session Options:" & ASCII.LF & 
        "  -s DIR, --session-dir DIR  Set the directory for session files" & ASCII.LF & 
        "  --list-sessions            List all session files" & ASCII.LF & 
        "  --clean-sessions           Remove invalid or corrupted session files" & ASCII.LF & 
        "" & ASCII.LF & 
        "Proxy Options:" & ASCII.LF & 
        "  -p URL, --proxy URL        Set the proxy URL (socks5:// or http://)" & ASCII.LF & 
        "  --no-proxy                 Disable proxy usage" & ASCII.LF & 
        "" & ASCII.LF & 
        "Logging Options:" & ASCII.LF & 
        "  -l LEVEL, --log-level LEVEL  Set the log level (debug, info, warning, error)" & ASCII.LF & 
        "  --log-file FILE            Log output to the specified file" & ASCII.LF & 
        "  --no-color                 Disable colored output" & ASCII.LF & 
        "  --quiet                    Suppress all output except errors" & ASCII.LF & 
        "" & ASCII.LF & 
        "Account Options:" & ASCII.LF & 
        "  -A PHONE, --account PHONE   Use the specified account (phone number)" & ASCII.LF & 
        "  --all-accounts             Use all active accounts" & ASCII.LF & 
        "  --list-accounts            List all configured accounts" & ASCII.LF & 
        "  --add-account              Add a new account interactively" & ASCII.LF & 
        "  --remove-account PHONE     Remove the specified account" & ASCII.LF & 
        "" & ASCII.LF & 
        "Reporting Options:" & ASCII.LF & 
        "  -C CHANNEL, --channel CHANNEL    Set the target channel for reporting" & ASCII.LF & 
        "  --list-channels            List recent channels" & ASCII.LF & 
        "  -n N, --report-count N     Number of messages to report (default: 3)" & ASCII.LF & 
        "  --delay SECONDS            Delay between reports in seconds (default: 2.0)" & ASCII.LF & 
        "  --reason REASON            Report reason (spam, violence, pornography," & ASCII.LF & 
        "                               copyright, privacy, scam, other) (default: spam)" & ASCII.LF & 
        "  --dry-run                  Show what would be reported without reporting" & ASCII.LF & 
        "" & ASCII.LF & 
        "Encryption Options:" & ASCII.LF & 
        "  -e, --encrypt               Enable session encryption" & ASCII.LF & 
        "  --decrypt                  Decrypt session files" & ASCII.LF & 
        "  --salt SALT                Set the encryption salt" & ASCII.LF & 
        "  --password PASS            Set the encryption password" & ASCII.LF & 
        "" & ASCII.LF & 
        "Diagnostic and Healing Options:" & ASCII.LF & 
        "  --diagnose                 Run comprehensive self-diagnostics" & ASCII.LF & 
        "  --self-heal                Attempt to automatically fix detected issues" & ASCII.LF & 
        "  --check-deps               Check for required dependencies" & ASCII.LF & 
        "  --check-config             Validate configuration files" & ASCII.LF & 
        "  --check-sessions           Verify session files" & ASCII.LF & 
        "  --health                   Run a quick health check" & ASCII.LF & 
        "  --fix-config               Fix configuration file issues" & ASCII.LF & 
        "  --fix-permissions          Fix file and directory permissions" & ASCII.LF & 
        "  --fix-sessions             Repair corrupted session files" & ASCII.LF & 
        "" & ASCII.LF & 
        "Commands:" & ASCII.LF & 
        "  Without any arguments or with --tui flag, trigger launches the ADI TUI" & ASCII.LF & 
        "  (Advanced Dialog Interface) for interactive use." & ASCII.LF & 
        "" & ASCII.LF & 
        "Environment Variables:" & ASCII.LF & 
        "  TRIGGER_CONFIG        Path to the configuration file (default: ./config.json)" & ASCII.LF & 
        "  TRIGGER_SESSION_DIR   Directory for session files (default: ./sessions)" & ASCII.LF & 
        "  TRIGGER_LOG_LEVEL     Log level (default: info)" & ASCII.LF & 
        "  TRIGGER_API_ID        Telegram API ID" & ASCII.LF & 
        "  TRIGGER_API_HASH      Telegram API hash" & ASCII.LF & 
        "  TRIGGER_PROXY         Proxy URL" & ASCII.LF & 
        "  NO_COLOR              If set, disables colored output" & ASCII.LF & 
        "" & ASCII.LF & 
        "Examples:" & ASCII.LF & 
        "  trigger --help" & ASCII.LF & 
        "  trigger --version" & ASCII.LF & 
        "  trigger --api-id 12345 --api-hash abcdef --save-config" & ASCII.LF & 
        "  trigger --dry-run --channel spam_channel --report-count 5" & ASCII.LF & 
        "  trigger --all-accounts --channel spam_channel" & ASCII.LF & 
        "  trigger --diagnose" & ASCII.LF & 
        "  trigger --self-heal" & ASCII.LF & 
        "  trigger --tui" & ASCII.LF & 
        "" & ASCII.LF & 
        "Report bugs at: https://github.com/hyperpolymath/trigger/issues";
   end Get_Help_Text;

end Trigger.CLI.Help_Generator;
