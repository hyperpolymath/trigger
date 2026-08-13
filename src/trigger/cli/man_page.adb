--  Trigger - CLI Man Page Implementation
--  
--  Generates and displays the man page for the CLI.
--  
--  Author: hyperpolymath

with Ada.Text_IO;

package body Trigger.CLI.Man_Page is

   procedure Display_Man_Page is
   begin
      Ada.Text_IO.Put_Line (Get_Man_Page_Text);
   end Display_Man_Page;

   function Get_Man_Page_Text return String is
   begin
      return 
        "trigger(1) - Trigger User Manual" & ASCII.LF & 
        "" & ASCII.LF & 
        "NAME" & ASCII.LF & 
        "       trigger - Multi-platform social media reporting utility with multi-account management" & ASCII.LF & 
        "" & ASCII.LF & 
        "SYNOPSIS" & ASCII.LF & 
        "       trigger [OPTIONS] [COMMAND]" & ASCII.LF & 
        "" & ASCII.LF & 
        "DESCRIPTION" & ASCII.LF & 
        "       trigger is a multi-platform social media reporting utility featuring multi-account" & ASCII.LF & 
        "       management, persistent sessions, proxy support, configurable reporting" & ASCII.LF & 
        "       options, automatic rate limit handling, and an interactive TUI." & ASCII.LF & 
        "" & ASCII.LF & 
        "       Supported platforms: Telegram, Discord, Twitter/X" & ASCII.LF & 
        "" & ASCII.LF & 
        "       This implementation uses Ada/SPARK for the core application, Zig for FFI" & ASCII.LF & 
        "       bindings, and Idris2 for API layer abstractions following the unified-hexadeca-api." & ASCII.LF & 
        "" & ASCII.LF & 
        "ORIGINAL ATTRIBUTION" & ASCII.LF & 
        "       This project implements functionality originally designed in Ripper by" & ASCII.LF & 
        "       2nixx (Telegram: https://t.me/NetworkCriminals). The original concept and" & ASCII.LF & 
        "       feature set are acknowledged with gratitude." & ASCII.LF & 
        "" & ASCII.LF & 
        "OPTIONS" & ASCII.LF & 
        "   Informational Options:" & ASCII.LF & 
        "       -h, --help           Show this help message and exit" & ASCII.LF & 
        "       --man                Display the full man page and exit" & ASCII.LF & 
        "       -v, --version        Show version information and exit" & ASCII.LF & 
        "       --license            Show license information and exit" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Configuration Options:" & ASCII.LF & 
        "       -c FILE, --config FILE     Use the specified configuration file instead of" & ASCII.LF & 
        "                                 the default" & ASCII.LF & 
        "       --save-config              Save the current configuration to the specified file" & ASCII.LF & 
        "       --reset-config             Reset configuration to default values" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Platform Selection Options:" & ASCII.LF & 
        "       -P PLATFORM, --platform PLATFORM    Set the platform (telegram, discord, twitter)" & ASCII.LF & 
        "       --list-platforms          List all supported platforms and exit" & ASCII.LF & 
        "       --discord-token TOKEN     Set the Discord bot/user token" & ASCII.LF & 
        "       --twitter-token TOKEN     Set the Twitter bearer token" & ASCII.LF & 
        "" & ASCII.LF & 
        "   API Credentials Options:" & ASCII.LF & 
        "       -a ID, --api-id ID          Set the Telegram API ID" & ASCII.LF & 
        "       --api-hash HASH            Set the Telegram API hash" & ASCII.LF & 
        "       --set-credentials         Set API credentials interactively" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Session Options:" & ASCII.LF & 
        "       -s DIR, --session-dir DIR  Set the directory for session files" & ASCII.LF & 
        "       --list-sessions            List all session files" & ASCII.LF & 
        "       --clean-sessions           Remove invalid or corrupted session files" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Proxy Options:" & ASCII.LF & 
        "       -p URL, --proxy URL        Set the proxy URL (socks5:// or http://)" & ASCII.LF & 
        "       --no-proxy                 Disable proxy usage" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Logging Options:" & ASCII.LF & 
        "       -l LEVEL, --log-level LEVEL  Set the log level. Valid values: debug, info," & ASCII.LF & 
        "                                 warning, error. Default: info" & ASCII.LF & 
        "       --log-file FILE            Log output to the specified file instead of stdout" & ASCII.LF & 
        "       --no-color                 Disable colored output" & ASCII.LF & 
        "       --quiet                    Suppress all output except errors" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Account Options:" & ASCII.LF & 
        "       -A PHONE, --account PHONE   Use the specified account (phone number)" & ASCII.LF & 
        "       --all-accounts             Use all active accounts" & ASCII.LF & 
        "       --list-accounts            List all configured accounts" & ASCII.LF & 
        "       --add-account              Add a new account interactively" & ASCII.LF & 
        "       --remove-account PHONE     Remove the specified account" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Reporting Options:" & ASCII.LF & 
        "       -C CHANNEL, --channel CHANNEL    Set the target channel for reporting" & ASCII.LF & 
        "       --list-channels            List recent channels" & ASCII.LF & 
        "       -n N, --report-count N     Number of messages to report. Default: 3" & ASCII.LF & 
        "       --delay SECONDS            Delay between reports in seconds. Default: 2.0" & ASCII.LF & 
        "       --reason REASON            Report reason. Valid values: spam, violence," & ASCII.LF & 
        "                                 pornography, copyright, privacy, scam, other. Default: spam" & ASCII.LF & 
        "       --dry-run                  Show what would be reported without actually reporting" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Encryption Options:" & ASCII.LF & 
        "       -e, --encrypt               Enable session encryption" & ASCII.LF & 
        "       --decrypt                  Decrypt session files" & ASCII.LF & 
        "       --salt SALT                Set the encryption salt" & ASCII.LF & 
        "       --password PASS            Set the encryption password" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Diagnostic and Healing Options:" & ASCII.LF & 
        "       --diagnose                 Run comprehensive self-diagnostics" & ASCII.LF & 
        "       --self-heal                Attempt to automatically fix detected issues" & ASCII.LF & 
        "       --check-deps               Check for required dependencies" & ASCII.LF & 
        "       --check-config             Validate configuration files" & ASCII.LF & 
        "       --check-sessions           Verify session files" & ASCII.LF & 
        "       --health                   Run a quick health check" & ASCII.LF & 
        "       --fix-config               Fix configuration file issues" & ASCII.LF & 
        "       --fix-permissions          Fix file and directory permissions" & ASCII.LF & 
        "       --fix-sessions             Repair corrupted session files" & ASCII.LF & 
        "" & ASCII.LF & 
        "COMMANDS" & ASCII.LF & 
        "       Without any arguments or with --tui flag, trigger launches the ADI TUI" & ASCII.LF & 
        "       (Advanced Dialog Interface) for interactive use." & ASCII.LF & 
        "" & ASCII.LF & 
        "EXIT CODES" & ASCII.LF & 
        "       0   Success" & ASCII.LF & 
        "       1   General error" & ASCII.LF & 
        "       2   Configuration error" & ASCII.LF & 
        "       3   Authentication error" & ASCII.LF & 
        "       4   Network error" & ASCII.LF & 
        "       5   API error" & ASCII.LF & 
        "       6   Session error" & ASCII.LF & 
        "       7   Validation error" & ASCII.LF & 
        "       8   Dependency missing" & ASCII.LF & 
        "" & ASCII.LF & 
        "ENVIRONMENT VARIABLES" & ASCII.LF & 
        "       TRIGGER_CONFIG        Path to the configuration file. Default: ./config.json" & ASCII.LF & 
        "       TRIGGER_SESSION_DIR   Directory for session files. Default: ./sessions" & ASCII.LF & 
        "       TRIGGER_LOG_LEVEL     Log level. Default: info" & ASCII.LF & 
        "       TRIGGER_API_ID        Telegram API ID" & ASCII.LF & 
        "       TRIGGER_API_HASH      Telegram API hash" & ASCII.LF & 
        "       TRIGGER_PLATFORM      Social media platform (telegram, discord, twitter)" & ASCII.LF & 
        "       TRIGGER_DISCORD_TOKEN Discord bot/user token" & ASCII.LF & 
        "       TRIGGER_TWITTER_TOKEN Twitter bearer token" & ASCII.LF & 
        "       TRIGGER_PROXY         Proxy URL" & ASCII.LF & 
        "       NO_COLOR              If set to any value, disables colored output" & ASCII.LF & 
        "" & ASCII.LF & 
        "FILES" & ASCII.LF & 
        "       ~/.config/trigger/config.json   User-specific configuration file" & ASCII.LF & 
        "       ./config.json                 Local configuration file" & ASCII.LF & 
        "       ./sessions/                    Session files for authenticated accounts" & ASCII.LF & 
        "       ./trigger.log                  Default log file" & ASCII.LF & 
        "" & ASCII.LF & 
        "EXAMPLES" & ASCII.LF & 
        "   Basic Usage:" & ASCII.LF & 
        "       Launch the interactive TUI:" & ASCII.LF & 
        "           trigger" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Show help:" & ASCII.LF & 
        "           trigger --help" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Show version:" & ASCII.LF & 
        "           trigger --version" & ASCII.LF & 
        "" & ASCII.LF & 
        "       List supported platforms:" & ASCII.LF & 
        "           trigger --list-platforms" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Platform Selection:" & ASCII.LF & 
        "       Set platform to Discord:" & ASCII.LF & 
        "           trigger --platform discord --discord-token YOUR_TOKEN" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Set platform to Twitter:" & ASCII.LF & 
        "           trigger --platform twitter --twitter-token YOUR_TOKEN" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Configuration:" & ASCII.LF & 
        "       Set Telegram API credentials:" & ASCII.LF & 
        "           trigger --api-id 12345 --api-hash abcdef123456 --save-config" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Or interactively:" & ASCII.LF & 
        "           trigger --set-credentials" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Reporting:" & ASCII.LF & 
        "       Dry run (preview what would be reported):" & ASCII.LF & 
        "           trigger --dry-run --channel spam_channel --report-count 5" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Report from all accounts:" & ASCII.LF & 
        "           trigger --all-accounts --channel spam_channel --report-count 5" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Report with specific account and proxy:" & ASCII.LF & 
        "           trigger -A +1234567890 -p socks5://127.0.0.1:1080 -C spam_channel" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Report with custom settings:" & ASCII.LF & 
        "           trigger --channel test_channel \\" & ASCII.LF & 
        "                  --report-count 10 \\" & ASCII.LF & 
        "                  --delay 3.0 \\" & ASCII.LF & 
        "                  --reason spam \\" & ASCII.LF & 
        "                  --all-accounts" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Report on Discord platform:" & ASCII.LF & 
        "           trigger --platform discord --discord-token YOUR_TOKEN" & ASCII.LF & 
        "                  --channel general --report-count 5" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Session Management:" & ASCII.LF & 
        "       List sessions:" & ASCII.LF & 
        "           trigger --list-sessions" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Clean invalid sessions:" & ASCII.LF & 
        "           trigger --clean-sessions" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Diagnostics:" & ASCII.LF & 
        "       Run full diagnostics:" & ASCII.LF & 
        "           trigger --diagnose" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Run health check:" & ASCII.LF & 
        "           trigger --health" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Attempt self-healing:" & ASCII.LF & 
        "           trigger --self-heal" & ASCII.LF & 
        "" & ASCII.LF & 
        "   Encryption:" & ASCII.LF & 
        "       Encrypt all sessions:" & ASCII.LF & 
        "           trigger --encrypt --salt my_salt --password my_pass --all-accounts" & ASCII.LF & 
        "" & ASCII.LF & 
        "DIAGNOSTICS" & ASCII.LF & 
        "       Trigger includes comprehensive self-diagnostic capabilities that check:" & ASCII.LF & 
        "       GNAT compiler availability, Zig compiler availability, Idris2 compiler" & ASCII.LF & 
        "       availability (optional), Configuration file validity, Session directory" & ASCII.LF & 
        "       existence and permissions, Session file integrity, Platform API connectivity," & ASCII.LF & 
        "       Disk space availability." & ASCII.LF & 
        "" & ASCII.LF & 
        "SELF-HEALING" & ASCII.LF & 
        "       Trigger can automatically fix common issues:" & ASCII.LF & 
        "       Create missing configuration file, Create missing session directory," & ASCII.LF & 
        "       Fix file permissions, Repair corrupted session files, Validate configuration values." & ASCII.LF & 
        "" & ASCII.LF & 
        "FAULT-TOLERANCE" & ASCII.LF & 
        "       Trigger is designed for fault-tolerant operation:" & ASCII.LF & 
        "       Automatic retry with exponential backoff for rate-limited operations," & ASCII.LF & 
        "       Session state persistence for recovery after crashes, Network error" & ASCII.LF & 
        "       handling with reconnection logic, Partial failure continuation," & ASCII.LF & 
        "       Comprehensive error logging for post-mortem analysis, Circuit breaker" & ASCII.LF & 
        "       pattern to prevent repeated failures, Multi-platform session management." & ASCII.LF & 
        "" & ASCII.LF & 
        "SECURITY" & ASCII.LF & 
        "       Session data can be encrypted using EdD448 + Kyber-1024 + BLAKE3 + SHAKE-512," & ASCII.LF & 
        "       API credentials are stored securely in configuration files," & ASCII.LF & 
        "       Phone numbers are stored securely, All sensitive data can be optionally" & ASCII.LF & 
        "       encrypted, Session files use restricted permissions." & ASCII.LF & 
        "" & ASCII.LF & 
        "REPORTING BUGS" & ASCII.LF & 
        "       Report bugs at: https://github.com/hyperpolymath/trigger/issues" & ASCII.LF & 
        "" & ASCII.LF & 
        "       Include: Version of Trigger, Version of compilers (GNAT, Zig, Idris2)," & ASCII.LF & 
        "       Operating system, Steps to reproduce, Expected behavior, Actual behavior," & ASCII.LF & 
        "       Relevant log output." & ASCII.LF & 
        "" & ASCII.LF & 
        "COPYRIGHT" & ASCII.LF & 
        "       Code is licensed under Mozilla Public License 2.0 (MPL-2.0)." & ASCII.LF & 
        "       Documentation is licensed under Creative Commons Attribution-ShareAlike" & ASCII.LF & 
        "       4.0 International (CC-BY-SA-4.0)." & ASCII.LF & 
        "       See LICENSE and LICENSES/ for full license texts." & ASCII.LF & 
        "" & ASCII.LF & 
        "SEE ALSO" & ASCII.LF & 
        "       Trigger source: https://github.com/hyperpolymath/trigger" & ASCII.LF & 
        "       Original Ripper concept: https://github.com/2nixx/Ripper" & ASCII.LF & 
        "       Ada/SPARK: https://www.adacore.com" & ASCII.LF & 
        "       Zig: https://ziglang.org" & ASCII.LF & 
        "       Idris2: https://idris-lang.org" & ASCII.LF & 
        "       Telegram API: https://core.telegram.org/api" & ASCII.LF & 
        "       Discord API: https://discord.com/developers/docs/intro" & ASCII.LF & 
        "       Twitter API: https://developer.twitter.com/en/docs/twitter-api";
   end Get_Man_Page_Text;

end Trigger.CLI.Man_Page;
