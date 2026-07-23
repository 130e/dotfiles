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
  (set-face-attribute 'default        nil :family "Iosevka"        :height 130)
  (set-face-attribute 'variable-pitch nil :family "Iosevka Aile" :height 130)
  (set-face-attribute 'fixed-pitch    nil :family "Iosevka"        :height 130)
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
        backup-directory-alist                `(("." . ,(locate-user-emacs-file "backup-files/")))
	vc-follow-symlinks t)
  ;; Editing behaviour
  (cua-mode              1)
  (show-paren-mode       1)
  (electric-pair-mode    1)
  (delete-selection-mode 1)
  ;; Session persistence
  (setq auto-revert-verbose nil
        history-length      25)
  (auto-revert-mode 1)
  (recentf-mode     1)
  (save-place-mode  1)
  (savehist-mode    1))

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
   org-hide-emphasis-markers t
   org-hide-drawer-startup t
   org-pretty-entities t
   org-agenda-tags-column 0
   org-ellipsis "…"

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
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c c" . org-roam-capture)
         ("C-c j" . org-roam-dailies-capture-today)
	 ("C-c n d" . org-roam-dailies-find-directory))
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag))
	org-roam-dailies-capture-templates
	'(("t" "todo" entry "* TODO %?\n%U"
           :target (file+head+olp "%<%Y-%m-%d>.org"
                                  "#+title: %<%Y-%m-%d>\n* Journal\n* Tasks\n"
                                  ("Tasks"))
           :empty-lines-before 1)
          ("j" "journal" entry "* %<%H:%M> %?"
           :target (file+head+olp "%<%Y-%m-%d>.org"
                                  "#+title: %<%Y-%m-%d>\n* Journal\n"
                                  ("Journal"))
           :empty-lines 1)))
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol))

(use-package markdown-mode
  :mode ("\\.md\\'" . gfm-mode)
  :init (setq markdown-command "pandoc")
  :custom
  ;; (markdown-hide-markup t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-header-scaling t))

(use-package doom-themes
  :config
  (load-theme 'doom-one t))

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

(use-package treemacsl
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

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
