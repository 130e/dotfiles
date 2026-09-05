;; My emacs' config
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

(use-package package
  :ensure nil
  :config
  (setq use-package-always-ensure nil))

;;;; General emacs options
(use-package emacs
  :demand t
  :bind (("C-z" . undo)
	 ("C-S-z" . undo-redo))
  :hook
  ((emacs-lisp-mode . outline-minor-mode)
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
  (set-face-attribute 'default        nil :family "Iosevka"        :height 120)
  (set-face-attribute 'variable-pitch nil :family "Iosevka Aile" :height 1.0)
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
	initial-major-mode                    'org-mode
	initial-scratch-message               "* Scratch\n"
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

;;;; Dired
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

;; org
(use-package org
  :bind
  (("C-c a" . org-agenda)
   ("C-c l" . org-store-link))
  :config
  (setq
   ;; Edit settings
   org-auto-align-tags nil
   org-tags-column 0
   org-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t
   ;; Org styling, hide markup etc.
   org-hide-emphasis-markers nil
   org-hide-drawer-startup t
   org-pretty-entities t
   org-agenda-tags-column 0
   org-ellipsis "…"
   ;; Fold show empty if at least 1 line
   org-cycle-separator-lines 1

   ;; Agenda and todos
   org-agenda-files '("~/RoamNotes/"
		      "~/RoamNotes/daily/")))

;;; Extensions
(use-package org-modern
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-star 'replace))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/RoamNotes"))
  :bind (("C-c f" . org-roam-node-find)
         ("C-c c" . org-roam-capture)
	 ("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n g" . org-roam-graph)
	 ("C-c n n" . org-id-get-create)
         ("C-c n i" . org-roam-node-insert)
         ("C-c j c" . org-roam-dailies-capture-today)
	 ("C-c j d" . org-roam-dailies-find-directory)
	 ("C-c j t" . org-roam-dailies-goto-today)
	 ("C-c j y" . org-roam-dailies-goto-yesterday)
	 ("C-c j T" . org-roam-dailies-goto-tomorrow)
	 ("C-c j D" . org-roam-dailies-goto-date))
  :config
  ;; (setq org-roam-dailies-capture-templates
  ;; 	'(("d" "default" plain "%?"
  ;;          :target (file+head "%<%Y-%m-%d>.org"
  ;;                             "#+title: %<%Y-%m-%d>\n* Reminder [/]\n\n- [ ] ")
  ;;          :unnarrowed t)))
  ;; (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag))
  ;; 	org-roam-dailies-capture-templates
  ;; 	'(("t" "todo" entry "* TODO %?\n%U"
  ;;          :target (file+head+olp "%<%Y-%m-%d>.org"
  ;;                                 "#+title: %<%Y-%m-%d>\n* Journal\n* Tasks\n"
  ;;                                 ("Tasks"))
  ;;          :empty-lines-before 1)
  ;;         ("j" "journal" entry "* %<%H:%M> %?"
  ;;          :target (file+head+olp "%<%Y-%m-%d>.org"
  ;;                                 "#+title: %<%Y-%m-%d>\n* Journal\n"
  ;;                                 ("Journal"))
  ;;          :empty-lines 1)))
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-side-window)
               (side . right)
               (window-width . 0.33)
               (window-parameters . ((no-delete-other-windows . t)))))

(use-package markdown-mode
  :mode ("\\.md\\'" . gfm-mode)
  :init (setq markdown-command "pandoc")
  :custom
  (markdown-hide-markup nil)
  (markdown-fontify-code-blocks-natively t)
  (markdown-header-scaling t))

;; Tex LaTex
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
    "Use LaTeXMk as the default command for `C-c C-a' and `C-c C-c'."
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

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-view-roll-minor-mode)  ; pageless continuous scroll
  :custom
  (pdf-view-continuous t)
  :config (pdf-loader-install))

;; Show the compiled PDF in a dedicated half-width window on the right,
;; instead of taking over the source window.
(add-to-list 'display-buffer-alist
             '((derived-mode . pdf-view-mode)
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . right)
               (window-width . 0.5)
               (dedicated . t)))

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

(use-package doom-themes
  :config
  (load-theme 'doom-one t)
  ;; (load-theme 'doom-feather-light)
  )

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

(defun my/markdown-to-org-region (start end)
  (interactive "r")
  (shell-command-on-region
   start end
   "pandoc -f markdown -t org --wrap=none" t t))

;; IDE
(use-package company
  :init
  (global-company-mode)
  :config
  (setq company-dabbrev-other-buffers t))

;; Tree sitter
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

;; eglot
(add-hook 'python-base-mode-hook #'eglot-ensure)
(add-hook 'c-ts-mode-hook #'eglot-ensure)
(add-hook 'c++-ts-mode-hook #'eglot-ensure)
(add-hook 'go-ts-mode-hook #'eglot-ensure)

;; vcs git diff
(use-package magit
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-diff-refine-hunk 'all))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  (unless (display-graphic-p)
    (diff-hl-margin-mode)))

;; Note: Tramp do not load env from profile
;; Force tramp to check path
(with-eval-after-load 'tramp
  (dolist (d '("/usr/lib/llvm/22/bin"
               "/usr/lib/llvm/21/bin"))
    (add-to-list 'tramp-remote-path d)))
