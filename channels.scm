;;
;; Guix channels configuration for Trigger
;;
;; This file specifies the Guix channels used for building the Trigger application.
;; It enables access to packages not in the default Guix repository.
;;
;; Author: hyperpolymath
;;

(cons*
  ;; Official Guix channel
  (channel
    (name 'guix)
    (url "https://git.savannah.gnu.org/git/guix.git")
    (branch "master")
    (commit "a0943964320853c95325754320836064c5133507"))  ; Update to latest stable commit
  
  ;; nonguix channel - provides additional packages including:
  ;; - zig (Zig compiler)
  ;; - idris2 (Idris2 compiler)
  ;; - Various development tools
  (channel
    (name 'nonguix)
    (url "https://gitlab.com/nonguix/nonguix")
    (branch "master")
    (commit "587613d113c427375171f6e46f3e7b3d4d17245a"))
  
  ;; Additional channel for Ada/SPARK tools if needed
  ;; (channel
  ;;   (name 'ada-guix)
  ;;   (url "https://gitlab.com/ada-guix/ada-guix")
  ;;   (branch "master"))
  
  ;; Local channel for custom packages (optional)
  ;; (channel
  ;;   (name 'trigger-custom)
  ;;   (path "/path/to/local/channel")
  ;;   (branch "main"))
)
