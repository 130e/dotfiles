;;; init.el --- My Emacs config  -*- lexical-binding: t; -*-
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

;;; Package management
(use-package package
  :ensure nil
  :config
  (setq use-package-always-ensure nil))

;;; General Emacs options
(use-package emacs
  :demand t
  :bind (("C-z" . undo)
	 ("C-S-z" . undo-redo)
	 ("C-x f" . find-file))
  :hook ((emacs-lisp-mode . outline-minor-mode)
	 (prog-mode       . display-line-numbers-mode)
	 (prog-mode       . my/set-trailing-whitespace)
	 (org-mode        . my/set-trailing-whitespace)
	 (text-mode       . visual-line-mode))
  :init
  (defun my/set-trailing-whitespace ()
    "Show trailing whitespace in the current buffer."
    (setq-local show-trailing-whitespace t))
  :config
  ;; Fonts
  (set-face-attribute 'default        nil :family "Iosevka"        :height 130)
  (set-face-attribute 'variable-pitch nil :family "Iosevka Etoile" :height 1.0)
  (set-face-attribute 'fixed-pitch    nil :family "Iosevka"        :height 1.0)
  ;; UI chrome
  (menu-bar-mode   0)
  (tool-bar-mode   0)
  (scroll-bar-mode 0)
  (set-fringe-mode 10)
  ;; General settings
  (setq custom-safe-themes                    t
        use-short-answers                     t
        read-answer-short                     t
        help-window-select                    t
        help-window-keep-selected             t
        find-library-include-other-files      nil
        window-combination-resize             t
        save-interprogram-paste-before-kill   t
        list-matching-lines-jump-to-current-line nil
        completion-category-defaults          nil
        ring-bell-function                    'ignore
        visible-bell                          nil
        inhibit-startup-message               t
	;; initial-major-mode                    'org-mode
	;; initial-scratch-message               "* Scratch\n"
        backup-directory-alist                `(("." . ,(locate-user-emacs-file "backup-files/")))
	vc-follow-symlinks t)
  ;; Editing behaviour
  ;; (cua-mode              1)
  (show-paren-mode       1)
  (electric-pair-mode    1)
  (delete-selection-mode 1)
  ;; Session persistence
  (setq auto-revert-verbose nil
        history-length      25
	;; update bookmark file whenever changes are made
	bookmark-save-flag 1)
  (auto-revert-mode 1)
  (recentf-mode     1)
  (save-place-mode  1)
  (savehist-mode    1)
  ;; diff
  (setq diff-font-lock-syntax nil))

;;; Dired
(use-package dired
  :ensure nil
  :config
  ;; (setq dired-kill-when-opening-new-dired-buffer t)
  (setq dired-auto-revert-buffer #'dired-directory-changed-p)
  (setq dired-clean-up-buffers-too t)
  (setq dired-clean-confirm-killing-deleted-buffers t)
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq delete-by-moving-to-trash t)
  (setq dired-create-destination-dirs 'ask)
  (setq dired-create-destination-dirs-on-trailing-dirsep t)
  (setq wdired-create-parent-directories t))

;;; Org
(use-package org
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   ("C-c l" . org-store-link))
  :config
  (setq org-catch-invisible-edits 'show-and-error
	org-special-ctrl-a/e t
	org-insert-heading-respect-content t
	org-hide-emphasis-markers t
	org-hide-drawer-startup t
	org-pretty-entities t
	;; org-ellipsis "…"
	org-cycle-separator-lines 1 ;; Fold show empty if at least 1 line
	org-return-follows-link t ;; RET open link
	)
  ;; Agenda and todos
  (setq org-agenda-files '("~/RoamNotes/inbox.org"
			   "~/RoamNotes/life.org"
			   "~/RoamNotes/routine.org"
			   "~/RoamNotes/projects/")
	org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|"
				      "DONE(d!)" "CANCELLED(c@)"))
	;; Default archive to a datetree, filed by their CLOSED date.
	;; Can be overriden per file with "#+ARCHIVE: ::* Archive".
	org-archive-location "~/RoamNotes/archive.org::datetree/"
	org-log-done 'time
	org-log-into-drawer t
	org-log-repeat 'time
	org-agenda-span 'day
	org-agenda-time-grid '((daily today require-timed remove-match)
                               (600 700 900 1200 1400 1800 2100)
                               " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
	org-agenda-current-time-string "⭠ now ─────────"
	org-agenda-sorting-strategy
	'((agenda time-up urgency-down category-keep)
	  (todo urgency-down category-keep)
	  (tags urgency-down category-keep)
	  (search category-keep))
	org-agenda-custom-commands
	'(("d" "Day"
	   ((agenda "")
	    (todo "TODO" ((org-agenda-overriding-header "Unscheduled")
			  (org-agenda-skip-function
			   '(org-agenda-skip-entry-if 'scheduled 'deadline))))))
	  ("r" "Review: what did I actually do (last 7 days)"
	   ((agenda "" ((org-agenda-span 7)
			(org-agenda-start-day "-7d")
			(org-agenda-start-with-log-mode t)
			(org-agenda-log-mode-items '(closed clock state))
			(org-agenda-archives-mode t))))))
	org-capture-templates
	'(("t" "Todo" entry (file "~/RoamNotes/inbox.org")
	   "* TODO %?\n%U" :empty-lines 1)
	  ("s" "Scheduled todo" entry (file "~/RoamNotes/inbox.org")
	   "* TODO %?\nSCHEDULED: %^t\n%U" :empty-lines 1)
	  ("d" "Deadline todo" entry (file "~/RoamNotes/inbox.org")
	   "* TODO %?\nDEADLINE: %^t\n%U" :empty-lines 1)
	  ("l" "Todo from link" entry (file "~/RoamNotes/inbox.org")
	   "* TODO %?\n%U\n%a" :empty-lines 1)
	  )
	;; Refile: complete on outline paths, not timestamped file names
	org-refile-targets '((org-agenda-files :maxlevel . 3))
	org-refile-use-outline-path 'file
	org-outline-path-complete-in-steps nil
	org-refile-allow-creating-parent-nodes 'confirm
	)
  ;; org-timer
  (add-to-list 'org-modules 'org-timer)
  (setq org-timer-default-timer 25)

  (require 'org-habit)
  ;; Babel: evaluate graphviz (and shell/elisp) blocks, show results inline
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((dot        . t)
     (emacs-lisp . t)
     (shell      . t)))
  ;; skip confirm y/n
  (defun my/org-confirm-babel-evaluate (lang _body)
    (not (member lang '("dot" "emacs-lisp"))))
  (setq org-confirm-babel-evaluate #'my/org-confirm-babel-evaluate
        org-startup-with-inline-images t
        org-image-actual-width '(600))
  :hook (('org-capture-mode . delete-other-windows)
	 ('org-babel-after-execute . org-redisplay-inline-images))
  )

;;;; GTD: clocking + capture straight into a project node
(with-eval-after-load 'org
  ;; Clocking is what makes "when/where did I do this" answerable later.
  ;; C-c C-x C-i clock in, C-c C-x C-o out, C-c C-x C-j jump to running clock.
  (setq org-clock-persist 'history
        org-clock-in-resume t
        org-clock-into-drawer t
        org-clock-out-remove-zero-time-clocks t
        org-clock-report-include-clocking-task t)
  (org-clock-persistence-insinuate)

  (defun my/capture-target-project-log ()
    "Put point under the `Log' subtree of an interactively chosen project node.
Projects are the file-level org-roam nodes tagged :project: -- i.e. the
files in ~/RoamNotes/projects/.  Completion is on the node title, not the
file name."
    (let ((node (org-roam-node-read
                 nil
                 (lambda (n) (and (= 0 (org-roam-node-level n))
                                  (member "project" (org-roam-node-tags n))))
                 nil t "Project: ")))
      (set-buffer (org-capture-target-buffer (org-roam-node-file node)))
      (widen)
      (goto-char (point-min))
      (let ((m (org-find-exact-headline-in-buffer "Log")))
        (if m
            (goto-char m)
          (goto-char (point-max))
          (unless (bolp) (insert "\n"))
          (insert "* Log\n")
          (forward-line -1)))))

  (add-to-list 'org-capture-templates
               '("m" "Meeting (into a project)" entry
                 (function my/capture-target-project-log)
                 "* %^{Topic} [%<%Y-%m-%d %a>] :meeting:\n:PROPERTIES:\n:ATTENDEES: %^{With}\n:END:\n%?"
                 :empty-lines 1 :clock-in t :clock-resume t)
               t))

;;;; Org extensions
(use-package org-modern
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-star 'replace))

(use-package org-roam
  ;; :preface
  ;; (defun my/org-roam-dailies-goto-today ()
  ;;   (interactive)
  ;;   (org-roam-dailies-goto-today "n"))
  ;; (defun my/org-roam-dailies-goto-yesterday (n)
  ;;   (interactive "p")
  ;;   (org-roam-dailies-goto-yesterday n "n"))
  ;; (defun my/org-roam-dailies-goto-tomorrow (n)
  ;;   (interactive "p")
  ;;   (org-roam-dailies-goto-tomorrow n "n"))
  ;; (defun my/org-roam-dailies-goto-date ()
  ;;   (interactive)
  ;;   (org-roam-dailies-goto-date nil "n"))
  :custom
  (org-roam-directory (file-truename "~/RoamNotes"))
  ;; (org-roam-dailies-capture-templates
  ;;  '(("n" "note" entry "* %?"
  ;;     :target (file+head "%<%Y-%m-%d>.org"
  ;; 			 "#+title: %<%Y-%m-%d>\n")
  ;;     :empty-lines 1
  ;;     :unnarrowed t)
  ;;    ("m" "meeting" entry "* Meeting: %^{with} :meeting:\n%?"
  ;;     :target (file+head "%<%Y-%m-%d>.org"
  ;; 			 "#+title: %<%Y-%m-%d>\n")
  ;;     :empty-lines 1
  ;;     :unnarrowed t)))
  (org-roam-mode-sections
   '(org-roam-backlinks-section
     org-roam-reflinks-section))
  :bind (("C-c f" . org-roam-node-find)
         ("C-c n c" . org-roam-capture)
	 ("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n g" . org-roam-graph)
	 ("C-c n n" . org-id-get-create)
         ("C-c n i" . org-roam-node-insert)
	 ;; Move a daily subtree/region into an existing node, or out to a new one.
	 ("C-c n r" . org-roam-refile)
	 ("C-c n e" . org-roam-extract-subtree)
         ("C-c j c" . org-roam-dailies-capture-today))
  ;; ("C-c j t" . my/org-roam-dailies-goto-today)
  ;; ("C-c j y" . my/org-roam-dailies-goto-yesterday)
  ;; ("C-c j T" . my/org-roam-dailies-goto-tomorrow)
  ;; ("C-c j d" . my/org-roam-dailies-goto-date)
  ;; ("C-c j D" . org-roam-dailies-find-directory)
  :config
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-side-window)
               (side . right)
               (window-width . 0.33)
               (window-parameters . ((no-delete-other-windows . t)))))

;;; Markdown
(use-package markdown-mode
  :mode ("\\.md\\'" . gfm-mode)
  :init (setq markdown-command "pandoc")
  :custom
  (markdown-hide-markup t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-header-scaling t))

;;; TeX / LaTeX
;; TODO: review fix
(use-package auctex
  :hook ((LaTeX-mode . turn-on-reftex)
         (LaTeX-mode . TeX-source-correlate-mode)
         (LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . my/LaTeX-prefer-latexmk))
  :init
  ;; `LaTeX-mode' ends its body with (setq TeX-command-default "LaTeX"), and
  ;; that setting is buffer-local, so customizing the global value has no
  ;; effect.  Override it from `LaTeX-mode-hook', which runs afterwards.
  (defun my/LaTeX-prefer-latexmk ()
    (setq TeX-command-default "LaTeXMk"))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-source-correlate-start-server t)
  (reftex-plug-into-AUCTeX t))

;; AUCTeX defers loading, and nothing pulls in the `auctex' feature itself,
;; so hang the extra setup off `tex' -- that is where TeX-command-list and
;; TeX-after-compilation-finished-functions actually live.
(with-eval-after-load 'tex
  ;; Refresh the PDF buffer after every successful compile.
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer)

  ;; ...but that hook is only run by `TeX-LaTeX-sentinel', and the stock
  ;; LaTeXMk entry runs `TeX-run-format', whose sentinel is
  ;; `TeX-TeX-sentinel' -- which does not run it, so the PDF window keeps
  ;; showing the stale file.  `TeX-run-TeX' is `TeX-run-format' plus the
  ;; major mode's own sentinel, i.e. `TeX-LaTeX-sentinel' here.
  (setf (nth 2 (assoc "LaTeXMk" TeX-command-list)) #'TeX-run-TeX)

  ;; Extra latexmk entries, offered in the C-c C-c completion list.
  ;; "LaTeXMk Force" ignores latexmk's .fdb_latexmk cache; use it after
  ;; fixing something outside the source tree (installing a TeX package,
  ;; a path, a .bst) that latexmk cannot notice on its own.
  (add-to-list 'TeX-command-list
               '("LaTeXMk Force" "latexmk -g %(latexmk-out) %(file-line-error) \
%`%(extraopts) %S%(mode)%' %t"
                 TeX-run-TeX nil (LaTeX-mode docTeX-mode)
                 :help "Run LaTeXMk, forcing a full rebuild (-g)"))
  (add-to-list 'TeX-command-list
               '("LaTeXMk Clean" "latexmk -C %t"
                 TeX-run-command nil (LaTeX-mode docTeX-mode)
                 :help "Remove every latexmk-generated file, including the PDF (-C)")))

;;;; PDF viewing
(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-view-roll-minor-mode)  ; pageless continuous scroll
  :custom
  (pdf-view-continuous t)
  ;; SyncTeX backward search (click in the PDF -> jump to the source).
  ;; `pdf-sync-backward-search' hands this to `pop-to-buffer' as its ACTION,
  ;; and unset it just splits the PDF's own frame.  reuse-window with
  ;; `reusable-frames' hands the jump to whatever frame already shows that
  ;; source buffer; pop-up-frame only kicks in when no frame does.
  (pdf-sync-backward-display-action
   '((display-buffer-reuse-window display-buffer-pop-up-frame)
     (reusable-frames . visible)
     (inhibit-same-window . t)))
  :config (pdf-loader-install))

;; Show the compiled PDF in a separate frame, instead of taking over the
;; source window.  reuse-window with `reusable-frames' picks up the frame
;; from the previous compile, so re-running C-c C-c does not pile up frames.
(add-to-list 'display-buffer-alist
             '((derived-mode . pdf-view-mode)
               (display-buffer-reuse-window display-buffer-pop-up-frame)
               (reusable-frames . visible)
               (inhibit-same-window . t)
	       (inhibit-switch-frame . t)
	       (dedicated . t)))

;;;; Org LaTeX preview
(setq org-preview-latex-default-process 'dvisvgm)
;; (plist-put org-format-latex-options :scale 1.3)
(setq org-startup-with-latex-preview t)           ; or #+STARTUP: latexpreview per file
;; (setq org-highlight-latex-and-related '(native latex script entities))

;; Fix for TRAMP. Force latex preview to render locally
(defun my/org-preview-latex-locally (orig &rest args)
  (if (file-remote-p default-directory)
      (let ((default-directory temporary-file-directory))
        (apply orig args))
    (apply orig args)))
(advice-add 'org-create-formula-image :around #'my/org-preview-latex-locally)

;;; Themes
;; (use-package doom-themes
;;   :config
;;   (load-theme 'doom-one t)
;;   ;; Emacs 31's defface makes `gnus-group-news-low' inherit
;;   ;; `gnus-group-news-low-empty', and doom-themes makes the latter inherit the
;;   ;; former.  doom's spec for news-low only matches via `min-colors', so a new
;;   ;; frame falls back to the defface spec and `make-frame' (hence
;;   ;; `emacsclient -c') fails with an inheritance cycle once gnus is loaded.
;;   (custom-theme-set-faces
;;    'user
;;    `(gnus-group-news-low
;;      ((t (:inherit gnus-group-mail-1 :foreground ,(doom-color 'base5)))))))
(let ((desktop-theme-dir (expand-file-name "~/.emacs.d/themes/")))
  (add-to-list 'custom-theme-load-path desktop-theme-dir)
  (load-theme 'noctalia t))

;;; Minibuffer completion and key hints
(use-package vertico
  :custom
  (vertico-resize t)
  (vertico-cycle  t)
  :init
  (vertico-mode))

(use-package marginalia
  :config (marginalia-mode 1))

(use-package orderless
  :config (setq completion-styles '(orderless basic)))

(use-package which-key
  :config
  (which-key-mode +1))

;;; Helper commands
(defun my/markdown-to-org-region (start end)
  (interactive "r")
  (shell-command-on-region
   start end
   "pandoc -f markdown -t org --wrap=none" t t))

(defun my/org-unroll-region (start end)
  (interactive "r")
  (shell-command-on-region
   start end
   "pandoc -f org -t org --wrap=none" t t))

;;; IDE
(use-package company
  :init
  (global-company-mode)
  :config
  (setq company-dabbrev-other-buffers t))

;;;; Tree-sitter
;; Remap built-in modes
(dolist (entry '((python-mode  python-ts-mode  python)
                 (c-mode       c-ts-mode       c)
                 (c++-mode     c++-ts-mode     cpp)
                 (sh-mode      bash-ts-mode    bash)
                 (js-mode      js-ts-mode      javascript)
                 (js-json-mode json-ts-mode    json)
                 (css-mode     css-ts-mode     css)
                 (yaml-mode    yaml-ts-mode    yaml)))
  (when (treesit-language-available-p (nth 2 entry))
    (add-to-list 'major-mode-remap-alist (cons (nth 0 entry) (nth 1 entry)))))
;; Add (because no base-mode available)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
(add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-mod-ts-mode))

;;;; Eglot
(add-hook 'python-base-mode-hook #'eglot-ensure)
(add-hook 'c-ts-mode-hook #'eglot-ensure)
(add-hook 'c++-ts-mode-hook #'eglot-ensure)
(add-hook 'go-ts-mode-hook #'eglot-ensure)

;;; Version control
(use-package magit
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-diff-refine-hunk 'all))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         ;; (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  ;; (global-diff-hl-mode)
  (diff-hl-flydiff-mode))

;;; TRAMP
;; Note: Tramp do not load env from profile
;; Force tramp to check path
(with-eval-after-load 'tramp
  (dolist (d '("/usr/lib/llvm/22/bin"
               "/usr/lib/llvm/21/bin"))
    (add-to-list 'tramp-remote-path d)))
