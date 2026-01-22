;;; private/mu4e-config.el -*- lexical-binding: t; -*-
;; Multi-account email configuration
;; This file is encrypted with git-crypt

(after! mu4e
  ;; Basic mu4e configuration
  (setq mu4e-maildir "~/Mail"
        mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300
        mu4e-compose-signature-auto-include nil
        mu4e-view-show-images t
        mu4e-view-show-addresses t
        mu4e-compose-format-flowed t
        mu4e-change-filenames-when-moving t)

  ;; Multiple accounts configuration
  (setq mu4e-contexts
        (list
         ;; Account 1: Gmail Personal
         (make-mu4e-context
          :name "Gmail-Personal"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/gmail-personal" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "jokinenmarko1@gmail.com")
                  (user-full-name . "Marko Jokinen")
                  (mu4e-sent-folder . "/gmail-personal/[Gmail]/Sent Mail")
                  (mu4e-drafts-folder . "/gmail-personal/[Gmail]/Drafts")
                  (mu4e-trash-folder . "/gmail-personal/[Gmail]/Trash")
                  (mu4e-refile-folder . "/gmail-personal/[Gmail]/All Mail")
                  (smtpmail-smtp-server . "smtp.gmail.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type . starttls)))

         ;; Account 2: Proton Personal
         (make-mu4e-context
          :name "Proton-Personal"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/proton-personal" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "jokinen.marko@proton.me")
                  (user-full-name . "Marko Jokinen")
                  (mu4e-sent-folder . "/proton-personal/Sent")
                  (mu4e-drafts-folder . "/proton-personal/Drafts")
                  (mu4e-trash-folder . "/proton-personal/Trash")
                  (mu4e-refile-folder . "/proton-personal/Archive")
                  (smtpmail-smtp-server . "127.0.0.1")
                  (smtpmail-smtp-service . 1025)
                  (smtpmail-stream-type . starttls)))

         ;; Account 3: Proton PM Alias
         (make-mu4e-context
          :name "Proton-PM"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/proton-pm" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "jokinen.marko@pm.me")
                  (user-full-name . "Marko Jokinen")
                  (mu4e-sent-folder . "/proton-pm/Sent")
                  (mu4e-drafts-folder . "/proton-pm/Drafts")
                  (mu4e-trash-folder . "/proton-pm/Trash")
                  (mu4e-refile-folder . "/proton-pm/Archive")
                  (smtpmail-smtp-server . "127.0.0.1")
                  (smtpmail-smtp-service . 1025)
                  (smtpmail-stream-type . starttls)))

         ;; Account 4: Proton Developer
         (make-mu4e-context
          :name "Developer"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/developer" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "thephatle@proton.me")
                  (user-full-name . "Phat Le")
                  (mu4e-sent-folder . "/developer/Sent")
                  (mu4e-drafts-folder . "/developer/Drafts")
                  (mu4e-trash-folder . "/developer/Trash")
                  (mu4e-refile-folder . "/developer/Archive")
                  (smtpmail-smtp-server . "127.0.0.1")
                  (smtpmail-smtp-service . 1025)
                  (smtpmail-stream-type . starttls)))

         ;; Account 5: Company (via Proton Bridge!)
         (make-mu4e-context
          :name "Company"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/company" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "info@thephatle.dev")
                  (user-full-name . "The Phat Le")
                  (mu4e-sent-folder . "/company/Sent")
                  (mu4e-drafts-folder . "/company/Drafts")
                  (mu4e-trash-folder . "/company/Trash")
                  (mu4e-refile-folder . "/company/Archive")
                  (smtpmail-smtp-server . "127.0.0.1")  ;; Proton Bridge!
                  (smtpmail-smtp-service . 1025)         ;; Not regular SMTP
                  (smtpmail-stream-type . starttls)))

         ;; Account 6: Work NW Group
         (make-mu4e-context
          :name "Work"
          :match-func
            (lambda (msg)
              (when msg
                (string-prefix-p "/work" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "cto@nwgroup.asia")
                  (user-full-name . "Marko Jokinen")
                  (mu4e-sent-folder . "/work/Sent")
                  (mu4e-drafts-folder . "/work/Drafts")
                  (mu4e-trash-folder . "/work/Trash")
                  (mu4e-refile-folder . "/work/Archive")
                  ;; Uses work-nwgroup/smtp-server from pass
                  (smtpmail-smtp-server . "smtp.nwgroup.asia")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type . starttls)))))

  ;; Default context
  (setq mu4e-context-policy 'pick-first
        mu4e-compose-context-policy 'ask)

  ;; SMTP (uses auth-source / .authinfo.gpg)
  (setq message-send-mail-function 'smtpmail-send-it
        smtpmail-debug-info t))

(provide 'mu4e-config)
