#!/usr/bin/env guile
!#
;; This file is part of Cunning Bot, an IRC bot written in Guile Scheme.
;; Copyright (C) 2011,2013 Aidan Gauland
;; Copyright (C) 2013 Ian Price

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(use-modules (cunning-bot bot)
             (system repl server)
             (cunning-bot plugins)
             (cunning-bot plugins help)
             (cunning-bot plugins admin)
             ((cunning-bot plugins seen)
              #:renamer (symbol-prefix-proc 'seen:))
             (cunning-bot commands))

(define socket-file-name "cbot-repl-socket")
(define bot (make-bot "cadrobot" "irc.freenode.net" 6667))

(use-plugin! bot 'help)
(use-plugin! bot 'admin)

(for-each (lambda (command)
            (let ((name (car command))
                  (proc (cdr command)))
             (register-command! bot name proc)))
          `((flay . ,flay)
            (help      . ,help)
            (say-hello . ,say-hello)
            (seen      . ,seen:seen)))

(let ((log-dir (format #f "~a/.local/share/cadrobot/logs" (getenv "HOME"))))
  (set-log-dir! bot log-dir)
  (seen:set-log-dir! log-dir)
  (format #t "IRC logs directory: ~a~%" log-dir))

(spawn-server (make-unix-domain-server-socket #:path socket-file-name))

;; Does not work because of bug#13018.  Fixed in trunk.  See
;; https://lists.gnu.org/archive/html/bug-guile/2013-08/msg00003.html
;;
;; (sigaction SIGINT
;;   (lambda ()
;;     (quit-irc bot))

(add-quit-hook! bot (lambda (bot) (delete-file socket-file-name)))
(start-bot bot '("##cadr"))
