;;; init.el --- Emacs Configuration -*- lexical-binding: t; -*-

;; Bootstrap `use-package`
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("org" . "https://orgmode.org/elpa/")))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Load custom file (optional for cleaner `init.el`)
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)

;; Set PATH (on macOS, Emacs does not inherit the shell path when started from
;; the UI
(defun set-exec-path-from-shell-path ()
  (interactive)
  (let ((shell-path (shell-command-to-string
			  "$SHELL --login -c 'echo -n $PATH'"
                          )))
    (setenv "PATH" shell-path)
    (setq exec-path (split-string shell-path path-separator))))
(set-exec-path-from-shell-path)

;; Set width to 80
(setq-default fill-column 80)

;;; Move backups to their own folder
(setq backup-directory-alist '(("." . "~/.emacs_bak")))

;; recentf-mode
(recentf-mode t)

;;; UI Customization
(load-theme 'modus-operandi-tinted t)
(add-to-list 'default-frame-alist
             '(font . "Inconsolata-16"))
(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)

(defun match-fringe-to-background ()
  "Set the fringe colour to match the background colour."
  (let ((bg-colour (face-background 'default)))
    (set-face-attribute 'fringe nil :background bg-colour)))
(match-fringe-to-background)
(add-hook 'after-load-theme-hook #'match-fringe-to-background)

;; elfeed
(use-package elfeed
  :ensure t)

;; citar
(use-package citar
  :custom
  (citar-bibliography '("~/bib/references.bib"))
  (citar-library-paths '("~/doc/papers"))
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup)
  :ensure t)
(use-package citar-embark
  :after citar embark
  :no-require
  :config (citar-embark-mode)
  :ensure t)
(use-package citar-org-roam
  :after (citar org-roam)
  :config (citar-org-roam-mode)
  :ensure t)

;; SLIME
(use-package slime
  :ensure t
  :config
  (setq inferior-lisp-program "sbcl")
  (setq slime-lisp-implementations
	'((sbcl ("sbcl" "--dynamic-space-size" "4096")))))

;; anki-editor
(use-package anki-editor
  :ensure t)

;; ace-window
(use-package ace-window
  :ensure t
  :bind (("M-o" . ace-window))
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq aw-background nil))

;; avy
(use-package avy
  :ensure t
  :bind (("C-'" . avy-goto-char-timer))
  :config (setq avy-timeout-seconds 0.1))

;; AUCTeX
(use-package auctex
  :ensure t)

;; tooltip-mode does not work well with macOS fullscreen
(defun disable-tooltip-in-doc-view ()
  (tooltip-mode -1))
(add-hook 'doc-view-mode-hook 'disable-tooltip-in-doc-view)

;; gnuplot
(use-package gnuplot
  :ensure t)
(use-package gnuplot-mode
  :ensure t)

;; org
(setq org-agenda-files '("~/org/inbox.org" "~/org/project.org"))
(setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
(global-set-key (kbd "C-c t") 'org-todo-list)

;; org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (C . t)
   (lisp . t)
   (emacs-lisp . t)))

;; org LaTeX/PDF settings
(defun enable-auto-revert-for-pdf ()
  "Enable `auto-revert-mode` for PDF files only."
  (when (string-equal (file-name-extension buffer-file-name) "pdf")
    (auto-revert-mode 1)))
(add-hook 'doc-view-mode-hook #'enable-auto-revert-for-pdf)
(setq org-latex-src-block-backend 'listings)

;; org-capture
(global-set-key (kbd "C-c c") 'org-capture)
(setq org-my-anki-file "~/org/anki.org")
(setq org-my-inbox-file "~/org/inbox.org")
(setq org-capture-templates
      '(("v" "Anki vocabulary"
         entry
         (file org-my-anki-file)
         "* %<%H:%M>\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Vocabulary (two-sided with sentence)\n:ANKI_DECK: Mega\n:END:\n** Front\n%?\n** Back\n** Sentence\n** Language\n")
	("w" "Anki vocabulary (auto)" ;; TODO Doesn't work 
         entry
         (file org-my-anki-file)
         "* %<%H:%M>\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Vocabulary (two-sided with sentence)\n:ANKI_DECK: Mega\n:END:\n** Front\n%^{Word|%(thing-at-point 'word)}\n** Back\n%?\n** Sentence\n%^{Sentence|%(thing-at-point 'sentence)}\n** Language\nGerman\n")
	("b" "Anki basic"
         entry
         (file org-my-anki-file)
         "* %<%H:%M>\n:PROPERTIES:\n:ANKI_NOTE_TYPE: Basic\n:ANKI_DECK: Mega\n:END:\n** Front\n%?\n** Back\n%x\n")
	("q" "Quick note"
	 entry
	 (file org-my-inbox-file)
	 "* TODO %^{Enter note}\n"
	 :immediate-finish t)
	("n" "Note"
	 entry
	 (file org-my-inbox-file)
	 "* TODO %?\n")
	("t" "To do"
	 entry
	 (file org-my-inbox-file)
	 "* TODO %^{Enter note}\n%^T\n"
	 :immediate-finish t)))

;; org-roam
(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/org/roam")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-setup))

;; eat
(use-package eat
  :ensure t)


;;; Python LSP (lsp-pyright)
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . lsp-deferred))

;;; Rust Support
(use-package rust-mode
  :ensure t
  :hook (rust-mode . eglot-ensure))

;;; Language Server Protocol (Eglot)
(add-hook 'prog-mode-hook 'eglot-ensure)

;;; LLM Integration (GPTel)
(setq gptel-model 'test
      gptel-backend (gptel-make-openai "llama-cpp"
                                       :stream t
                                       :protocol "http"
                                       :host "localhost:8080"
                                       :models '(test)))

;;; Completion Framework (Vertico + Corfu)
(use-package vertico
  :ensure t
  :init (vertico-mode))

(use-package savehist
  :ensure t
  :init (savehist-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  :hook ((prog-mode shell-mode eshell-mode) . corfu-mode)
  :init (global-corfu-mode))

;;; Rich Minibuffer Annotations (Marginalia)
(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

;;; Incremental Completion and Navigation (Consult)
(use-package consult
  :ensure t
  :bind (("C-c M-x" . consult-mode-command)          ;; Mode-specific command
         ("C-c h" . consult-history)                ;; Command history
         ("C-c k" . consult-kmacro)                 ;; Keyboard macros
         ("C-c m" . consult-man)                    ;; Man pages
         ("C-c i" . consult-info)                   ;; Info pages
         ([remap Info-search] . consult-info)       ;; Info search

         ("C-x M-:" . consult-complex-command)      ;; Repeat complex commands
         ("C-x b" . consult-buffer)                ;; Buffer switch
         ("C-x 4 b" . consult-buffer-other-window)  ;; Buffer switch in other window
         ("C-x 5 b" . consult-buffer-other-frame)   ;; Buffer switch in other frame
         ("C-x t b" . consult-buffer-other-tab)     ;; Buffer switch in other tab
         ("C-x r b" . consult-bookmark)             ;; Jump to bookmark
         ("C-x p b" . consult-project-buffer)       ;; Buffer switch in project

         ("M-#" . consult-register-load)            ;; Load registers
         ("M-'" . consult-register-store)           ;; Store registers
         ("C-M-#" . consult-register)               ;; Open register UI

         ("M-y" . consult-yank-pop)                 ;; Search kill-ring
         ("M-g e" . consult-compile-error)          ;; Compilation errors
         ("M-g f" . consult-flymake)                ;; Flymake diagnostics
         ("M-g g" . consult-goto-line)              ;; Go to line
         ("M-g o" . consult-outline)                ;; Go to outline
         ("M-g m" . consult-mark)                   ;; Go to mark
         ("M-g k" . consult-global-mark)            ;; Go to global mark
         ("M-g i" . consult-imenu)                  ;; Go to imenu
         ("M-g I" . consult-imenu-multi)            ;; Go to imenu (multi-buffer)

         ("M-s d" . consult-find)                   ;; Find files
         ("M-s c" . consult-locate)                 ;; Locate files
         ("M-s g" . consult-grep)                   ;; Grep
         ("M-s G" . consult-git-grep)               ;; Git grep
         ("M-s r" . consult-ripgrep)                ;; Ripgrep
         ("M-s l" . consult-line)                   ;; Search current buffer
         ("M-s L" . consult-line-multi)             ;; Search across buffers
         ("M-s k" . consult-keep-lines)             ;; Keep matching lines
         ("M-s u" . consult-focus-lines)            ;; Focus matching lines

         ("M-s e" . consult-isearch-history)        ;; Isearch history
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)          ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)

         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; Minibuffer history
         ("M-r" . consult-history))               ;; Reverse minibuffer history
  :hook (completion-list-mode . consult-preview-at-point-mode))

;; consult-dir
(use-package consult-dir
  :ensure t
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;;; Contextual Actions (Embark + Consult Integration)
(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \$begin:math:text$Live\\\\|Completions\\$end:math:text$\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;;; Provide init
(provide 'init)
;;; init.el ends here
