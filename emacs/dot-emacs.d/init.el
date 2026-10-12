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
	 ("C-x f" . find-file)
	 ("C-c 5" . other-frame-prefix))
  :hook ((emacs-lisp-mode . outline-minor-mode)
	 (prog-mode       . display-line-numbers-mode)
	 (prog-mode       . my/set-trailing-whitespace)
	 (org-mode        . my/set-trailing-whitespace)
	 (text-mode       . visual-line-mode)
	 (text-mode       . flyspell-mode)
	 (prog-mode       . flyspell-prog-mode)
	 (prog-mode       . flymake-mode))
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
	initial-buffer-choice                 "~/RoamNotes/inbox.org"
        backup-directory-alist                `(("." . ,(locate-user-emacs-file "backup-files/")))
	vc-follow-symlinks                    t
	indent-tabs-mode nil
	pixel-scroll-mode                     t
	imenu-auto-rescan    t
	view-read-only       t
	repeat-mode        t
	frame-resize-pixelwise t
	window-resize-pixelwise t
	frame-inhibit-implied-resize t
	browse-url-browser-function 'browse-url-firefox
	global-xref-mouse-mode t
	completion-styles '(basic partial-completion emacs22 flex)
	;; mostly benign since vertico is used
	minibuffer-visible-completions t
	completions-detailed t
	completions-group t
	completion-auto-select 'second-tab
	completion-eager-update t
	global-completion-preview-mode t
	shell-command-prompt-show-cwd t
	)
  ;; Editing behaviour
  ;; (cua-mode              1)
  (show-paren-mode       1)
  (electric-pair-mode    1)
  (delete-selection-mode 1)
  ;; Session persistence
  (setq auto-revert-verbose nil
        history-length      25
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
  (setq dired-kill-when-opening-new-dired-buffer t)
  (setq dired-auto-revert-buffer t)
  (setq dired-clean-up-buffers-too t)
  (setq dired-clean-confirm-killing-deleted-buffers t)
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq delete-by-moving-to-trash t)
  (setq dired-create-destination-dirs 'ask)
  (setq dired-create-destination-dirs-on-trailing-dirsep t)
  (setq wdired-create-parent-directories t)
  (setopt dired-mouse-drag-files t))

;;; Project
;; Lowercase runs the project command here, uppercase in a new frame
;; (the one-key equivalent of C-x 5 p <key>).
;; (use-package project
;;   :ensure nil
;;   :bind (("C-c f" . project-find-file)
;; 	 ("C-c F" . my/project-find-file-other-frame)
;; 	 ("C-c b" . project-switch-to-buffer)
;; 	 ("C-c B" . my/project-switch-to-buffer-other-frame)
;; 	 ("C-c d" . project-find-dir)
;; 	 ("C-c D" . my/project-find-dir-other-frame)
;; 	 ("C-c e" . project-eshell)
;; 	 ("C-c E" . my/project-eshell-other-frame)
;; 	 ("C-c p" . project-switch-project)
;; 	 ("C-c P" . my/project-switch-project-other-frame)
;; 	 ("C-c k" . project-kill-buffers))
;;   :init
;;   (defmacro my/define-project-other-frame (command)
;;     "Define `my/COMMAND-other-frame', running COMMAND in a new frame."
;;     `(defun ,(intern (format "my/%s-other-frame" command)) ()
;;        ,(format "Run `%s', displaying its buffer in a new frame." command)
;;        (interactive)
;;        (let ((switch-to-buffer-obey-display-actions t)
;;              (display-buffer-overriding-action
;;               '((display-buffer-pop-up-frame) (inhibit-same-window . t))))
;;          (call-interactively #',command))))
;;   (my/define-project-other-frame project-find-file)
;;   (my/define-project-other-frame project-switch-to-buffer)
;;   (my/define-project-other-frame project-find-dir)
;;   (my/define-project-other-frame project-eshell)
;;   (my/define-project-other-frame project-switch-project))


;;; Org
(use-package org
  ;; Load eagerly for org-protocol
  :demand t
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   ("C-c l" . org-store-link))
  :config
  (require 'org-protocol)
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
	;; org-agenda-span 'day
	org-agenda-start-on-weekday 0
	calendar-week-start-day 0
	org-agenda-show-all-dates nil
	org-agenda-compact-blocks t
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
	  ("w" "Quote selected text and link" entry (file "~/RoamNotes/inbox.org")
	   "* %:description\n%U\n%:link\n\n#+begin_quote\n%i\n#+end_quote\n%?" :empty-lines 1)
	  ;; Meetings land in the inbox too; refile to a project during review.
	  ("m" "Meeting" entry (file "~/RoamNotes/inbox.org")
	   "* Meeting: %^{Topic} [%<%Y-%m-%d %a>] :meeting:\n:PROPERTIES:\n:ATTENDEES: %^{With}\n:END:\n%?"
	   :empty-lines 1 :clock-in t :clock-resume t)
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
  (defun my/org-confirm-babel-evaluate (lang _body)
    (not (member lang '("dot" "emacs-lisp"))))
  (setq org-confirm-babel-evaluate #'my/org-confirm-babel-evaluate
        org-startup-with-inline-images t
        org-image-actual-width '(600))
  :hook (('org-capture-mode . delete-other-windows)
	 ('org-babel-after-execute . org-redisplay-inline-images)
	 ('org-capture-after-finalize . my/del-temp-frame))
  )

;;;; GTD: clocking
(with-eval-after-load 'org
  ;; Clocking is what makes "when/where did I do this" answerable later.
  ;; C-c C-x C-i clock in, C-c C-x C-o out, C-c C-x C-j jump to running clock.
  (setq org-clock-persist 'history
        org-clock-in-resume t
        org-clock-into-drawer t
        org-clock-out-remove-zero-time-clocks t
        org-clock-report-include-clocking-task t)
  (org-clock-persistence-insinuate))

;;;; Org extensions
(use-package org-modern
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-star 'replace))

(use-package calfw)
(use-package calfw-org
  :after calfw
  :bind
  (("C-c m" . calfw-org-open-calendar))
  :config
  (setq calfw-org-overwrite-default-keybinding t))

(use-package org-roam
  :demand t ;; org-roam-protocol
  :custom
  (org-roam-directory (file-truename "~/RoamNotes"))
  (org-roam-mode-sections
   '(org-roam-backlinks-section
     org-roam-reflinks-section))
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n c" . org-roam-capture)
	 ("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n g" . org-roam-graph)
	 ("C-c n n" . org-id-get-create)
         ("C-c n i" . org-roam-node-insert)
	 ("C-c n r" . org-roam-refile)
	 ("C-c n e" . org-roam-extract-subtree)
         ("C-c n j" . org-roam-dailies-capture-today)
	 ("C-c n J" . my/org-roam-dailies-goto-today))
  :config
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol)
  (setq org-roam-capture-ref-templates
      '(("w" "ref" plain "#+begin_quote\n${body}\n#+end_quote\n%?"
         :target (file+head "${slug}.org" "#+title: ${title}")
         :unnarrowed t))))

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
(use-package auctex
  :hook ((LaTeX-mode . turn-on-reftex)
         (LaTeX-mode . TeX-source-correlate-mode)
         (LaTeX-mode . LaTeX-math-mode))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-source-correlate-start-server t)
  (reftex-plug-into-AUCTeX t))

;; AUCTeX defers loading, and nothing pulls in the `auctex' feature itself,
;; so hang the extra setup off `tex' -- that is where
;; TeX-after-compilation-finished-functions actually lives.
(with-eval-after-load 'tex
  ;; Refresh the PDF buffer after every successful compile.
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer))

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
;; (let ((desktop-theme-dir (expand-file-name "~/.emacs.d/themes/")))
;;   (add-to-list 'custom-theme-load-path desktop-theme-dir)
;;   (load-theme 'noctalia t))
(use-package kaolin-themes
  :config
  (load-theme 'kaolin-temple t))

;;; Better prose reading experiences inspired by Nano-emacs
;; Thin type; "bold" becomes only one step heavier
(set-face-attribute 'default nil :weight 'light)
(set-face-attribute 'bold nil :weight 'regular)

(defun my/apply-chrome (&rest _)
  (let ((bg     (face-background 'default))
        (subtle (face-background 'mode-line-inactive nil t))
        (rule   (face-foreground 'shadow nil t)))
    (dolist (f '(internal-border window-divider fringe
                 window-divider-first-pixel window-divider-last-pixel))
      (set-face-attribute f nil :background bg :foreground bg))
    ;; Mode line collapsed to a thin rule
    (dolist (f '(mode-line mode-line-inactive))
      (set-face-attribute f nil :height 0.1 :box nil :overline nil
                          :foreground bg :background bg :underline rule))
    ;; Status bar lives in the header line instead
    (set-face-attribute 'header-line nil :background subtle :box nil
                        :underline nil :inherit nil)
    ))

(my/apply-chrome)
(add-hook 'enable-theme-functions #'my/apply-chrome)

(setq x-underline-at-descent-line t)
(setq-default mode-line-format ""
              header-line-format
              '(" " (:propertize "%b" face bold) "  (" mode-name ")"
                (:eval (propertize " " 'display '(space :align-to (- right 8))))
                "%l:%c"))

(defface my-strong '((t :weight medium)) "Structural text: default colour, one step heavier.")

(with-eval-after-load 'outline
  (dolist (n (number-sequence 1 8))
    (set-face-attribute (intern (format "outline-%d" n)) nil
                        :inherit 'my-strong :foreground 'unspecified)))

(with-eval-after-load 'markdown-mode
  (set-face-attribute 'markdown-header-face nil
                      :inherit 'my-strong :foreground 'unspecified :weight 'unspecified))

(with-eval-after-load 'org
  (cl-loop for (face . height) in '((org-level-1 . 1.4) (org-level-2 . 1.25)
                                    (org-level-3 . 1.15) (org-level-4 . 1.1))
           do (set-face-attribute face nil :height height)))

;;; Minibuffer completion and key hints
(use-package vertico
  :custom
  (vertico-resize t)
  (vertico-cycle  t)
  :init
  (vertico-mode))

(use-package marginalia
  :config (marginalia-mode 1))

(use-package which-key
  :config
  (which-key-mode 1))

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

(defun my/set-trailing-whitespace ()
  "Show trailing whitespace in the current buffer."
  (setq-local show-trailing-whitespace t))

(defun my/del-temp-frame ()
  "Delete frame if its frame title matches."
  (when (equal (frame-parameter nil 'name) "emacs-temp-frame")
    (delete-frame)))

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
	 (LaTeX-mode . diff-hl-mode)
         ;; (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode))

;;; TRAMP
;; Note: Tramp do not load env from profile
;; Force tramp to check path
(with-eval-after-load 'tramp
  (dolist (d '("/usr/lib/llvm/22/bin"
               "/usr/lib/llvm/21/bin"))
    (add-to-list 'tramp-remote-path d)))
