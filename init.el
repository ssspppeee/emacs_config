;;; init.el --- Emacs Configuration -*- lexical-binding: t; -*-

;; Bootstrap `use-package`
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Load custom file (optional for cleaner `init.el`)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'no-error 'no-message))
;; Set width to 80
(setq-default fill-column 80)

;;; Move backups to their own folder
(setq backup-directory-alist '(("." . "~/.emacs_bak")))

;;; UI Customization
(load-theme 'modus-vivendi-tinted t)
(scroll-bar-mode -1)

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
