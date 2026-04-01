;; --------------------------------------------------
;; My Functions
;; --------------------------------------------------

(setq nico/pomodoro-timer nil)
(setq nico/pomodoro-end-time nil)


(defun nico/pomodoro-done ()
  (with-current-buffer (get-buffer-create "*Pomodoro Log*")
    (insert (format "Session Completed at %s\n" (format-time-string "%Y-%m-%d %H:%M")))
    (display-buffer (current-buffer))))

(defun nico/pomodoro-start ()
  "Start a 25min pomodoro timer"
  (interactive)
  (message "Pomodoro started! Focus for 25min")
  (setq nico/pomodoro-end-time
	(time-add (current-time) (* 25 60)))
  (setq nico/pomodoro-timer
	(run-with-timer 0 60 
			(lambda ()
			  (let* ((remaining (time-subtract nico/pomodoro-end-time (current-time)))
				 (secs (floor (float-time remaining)))
				 (mins (/ secs 60))
				 (secs (% secs 60)))
			    (if (< (float-time remaining) 0)
				(progn
				  (cancel-timer nico/pomodoro-timer)
				  (nico/pomodoro-done))
			      (message "Pomodoro: %02d:%02d remaining" mins secs)))))))


(defun nico/pomodoro-stop () 
  "Cancel the running pomodoro timer"
	 (interactive)
	 (when nico/pomodoro-timer
	   (cancel-timer nico/pomodoro-timer)
	   (setq nico/pomodoro-timer nil)
	   (message "Pomodoro stopped")))
	   
(define-minor-mode nico/pomodoro-mode
  "A simple pomodoro timer mode"
	 :lighter " Pomo"	   ; shows in the modeline when active
	 :global t
	 (if nico/pomodoro-mode
	     (nico/pomodoro-start)
	   (nico/pomodoro-stop)))
(global-set-key (kbd "C-c p") 'nico/pomodoro-mode)

(defun my-scratchpad ()
  "toggle a persistent scratchpad buffer"
  (interactive)
  (let ((buf (get-buffer-create "*scratchpad*")))
    (if (eq (current-buffer) buf)
	(bury-buffer)
      (switch-to-buffer buf))
    (if (= (buffer-size) 0)
	(insert (format "Scratchpad %s\n=============\n\n" (format-time-string "%Y-%m-%d"))))))

;; Function Init.el evaluation
(defcustom nico/save-delay 0.5
  "seconds to wait before saving"
  :type 'number
  :group 'nico)

(defun nico/config-save ()
  "Eval-buffer init.el when saved"
  (when (string-equal (buffer-name) "init.el")
    (run-with-timer
     (if (boundp 'nico/save-delay) nico/save-delay 0.5)
     nil
     (lambda ()
       (eval-buffer)
       (message "init.el reloaded!")))))

(add-hook 'after-save-hook 'nico/config-save)

;; --------------------------------------------------
;; My Bindings
;; --------------------------------------------------

;;Scratchpad (my function)
(global-set-key (kbd "C-c s") 'my-scratchpad)

;;Increase/Decrease Font
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;;Change the emacs selection
(setq org-support-shift-select t)

;;Have emacs use the system clipboard
(setq select-enable-clipboard t)
(setq select-enable-primary t)
(setq xclip-program "xclip") ;; for terminal mode
(setq xclip-select-enable-clipboard t)

;; --------------------------------------------------
;; Package system
;; --------------------------------------------------

(require 'package)

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; --------------------------------------------------
;; Clipboard
;; --------------------------------------------------

(use-package xclip
  :config
  (xclip-mode 1))

;; --------------------------------------------------
;; Basic UI cleanup
;; --------------------------------------------------

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-screen t)

;; Line numbers in code, not in org
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Highlight current line — helps when scanning tables
(global-hl-line-mode 1)

;; Smoother scrolling (less jarring jumps)
(setq scroll-conservatively 101
      scroll-margin 3)

;;Show matching parens instantly
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Remember where you were in each file
(save-place-mode 1)

;; Remember recent files (M-x recentf-open-files)
(recentf-mode 1)
(setq recentf-max-saved-items 50)

;; Shorter yes/no prompts
(fset 'yes-or-no-p 'y-or-n-p)

;; Auto-revert files changed on disk (useful after git operations)
(global-auto-revert-mode 1)

;; --------------------------------------------------
;; Font
;; --------------------------------------------------

(set-face-attribute 'default nil
                    :font "JetBrainsMono"
                    :height 140)

;; Variable-pitch font for org prose (optional — toggle with M-x variable-pitch-mode)
;; Uncomment if you have a good serif/sans font available:
;; (set-face-attribute 'variable-pitch nil
;;                     :font "Calibri"
;;                     :height 150)

;; --------------------------------------------------
;; Theme
;; --------------------------------------------------

(use-package doom-themes
  :config
  (load-theme 'doom-one t)
  ;; Better org fontification with doom themes
  (doom-themes-org-config))

;; --------------------------------------------------
;; Better modeline
;; --------------------------------------------------

(use-package doom-modeline
  :ensure t
  :config
  (doom-modeline-mode 1)
  (setq doom-modeline-height 30
        doom-modeline-bar-width 4
        doom-modeline-buffer-file-name-style 'truncate-with-project))

;; --------------------------------------------------
;; Icons
;; --------------------------------------------------

(use-package all-the-icons)

;; Run once manually:
;; M-x all-the-icons-install-fonts

;; --------------------------------------------------
;; Which-key (shows shortcuts)
;; --------------------------------------------------

(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5))

;; --------------------------------------------------
;; Modern completion UI
;; --------------------------------------------------

(use-package vertico
  :init
  (vertico-mode)
  :config
  (setq vertico-count 12
        vertico-cycle t))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil))

(use-package marginalia
  :init
  (marginalia-mode))

;; Rich previews when selecting files/buffers
(use-package consult
  :bind (("C-x b" . consult-buffer)       ;; better buffer switching
         ("C-s" . consult-line)            ;; search within file
         ("M-g g" . consult-goto-line)
         ("M-s r" . consult-ripgrep)))     ;; search across files (needs ripgrep)

;; --------------------------------------------------
;; File tree sidebar (toggle with C-c t)
;; --------------------------------------------------

(use-package treemacs
  :bind ("C-c t" . treemacs)
  :config
  (setq treemacs-width 30
        treemacs-is-never-other-window t))

;; --------------------------------------------------
;; Git (Magit)
;; --------------------------------------------------

(use-package magit
  :bind ("C-x g" . magit-status))

;; Show git changes in the gutter (left margin)
(use-package diff-hl
  :config
  (global-diff-hl-mode)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

;; --------------------------------------------------
;; Org Mode
;; --------------------------------------------------

(use-package org
  :config
  (setq org-directory "~/org"
        org-hide-emphasis-markers t
        org-startup-folded 'content
        org-startup-align-all-tables t
        org-confirm-babel-evaluate nil
        org-src-fontify-natively t          ;; syntax highlight code blocks
        org-src-tab-acts-natively t         ;; tab works normally in code blocks
        org-edit-src-content-indentation 0  ;; no extra indent in code blocks
        org-return-follows-link t           ;; Enter opens links
        org-image-actual-width '(500))      ;; cap inline image width

  ;; Enable Python and Shell in org-babel
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t)))

  (setq org-babel-python-command "python3")

  ;; Better TODO keywords for model workflow
  (setq org-todo-keywords
        '((sequence "TODO" "IN-PROGRESS" "REVIEW" "|" "DONE" "ARCHIVED"))))

;; --------------------------------------------------
;; Org visual improvements
;; --------------------------------------------------

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-table t
        org-modern-block-fringe t))

;; --------------------------------------------------
;; Centered writing layout
;; --------------------------------------------------

(use-package visual-fill-column
  :hook (org-mode . visual-fill-column-mode)
  :init
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t))

(add-hook 'org-mode-hook 'visual-line-mode)

;; --------------------------------------------------
;; Org-roam
;; --------------------------------------------------

(use-package org-roam
  :init
  (setq org-roam-directory (file-truename "~/org-roam")
        org-roam-dailies-directory "daily/"
        org-roam-completion-everywhere t

        org-roam-capture-templates
        '(("d" "default" plain "%?"
           :if-new
           (file+head "${slug}.org"
                      "#+title: ${title}\n")
           :unnarrowed t))

        org-roam-dailies-capture-templates
        '(("d" "default" entry
           "* %?"
           :target
           (file+head "%<%Y-%m-%d>.org"
                      "#+title: %<%Y-%m-%d>\n\n"))))

  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n b" . org-roam-buffer-toggle)
         ("C-c n d" . org-roam-dailies-capture-today))

  :config
  (org-roam-db-autosync-mode))

;; --------------------------------------------------
;; Better Org-roam search
;; --------------------------------------------------

(use-package consult-org-roam
  :after org-roam
  :config
  (consult-org-roam-mode 1))

;; --------------------------------------------------
;; Quick link creation
;; --------------------------------------------------

(defun my/org-roam-link-at-point ()
  (interactive)
  (org-roam-node-insert))

(global-set-key (kbd "C-c l") #'my/org-roam-link-at-point)

;; --------------------------------------------------
;; Claude Emacs
;; --------------------------------------------------

(use-package inheritenv
  :vc (:url "https://github.com/purcell/inheritenv" :rev :newest))

(use-package claude-code
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :config
  (setq claude-code-terminal-backend 'vterm)
  (claude-code-mode)
  :bind-keymap ("C-c c" . claude-code-command-map))


;; --------------------------------------------------
;; Python
;; --------------------------------------------------
;; Autocomplete
(use-package anaconda-mode
  :hook (python-mode . anaconda-mode))

(use-package company
  :config
  (global-company-mode 1))

(use-package company-anaconda
  :after (company anaconda-mode)
  :config
  (add-to-list 'company-backends 'company-anaconda))


;; --------------------------------------------------
;; Terminal
;; --------------------------------------------------
(use-package vterm)
;; --------------------------------------------------
;; Quick reference card (C-c ? to view)
;; --------------------------------------------------

(defun my-keybindings ()
  "Show my custom keybindings."
  (interactive)
  (with-output-to-temp-buffer "*My Keybindings*"
    (princ "MY KEYBINDINGS
==============

Navigation
  C-x b       Switch buffer (consult)
  C-s         Search in file (consult)
  M-s r       Search across files (ripgrep)
  C-c t       File tree (treemacs)

Org-roam
  C-c n f     Find node
  C-c n i     Insert link to node
  C-c n b     Toggle backlinks buffer
  C-c n d     Daily capture
  C-c l       Insert link (at point)

Org-babel
  C-c C-c     Execute code block at point
  C-c C-v b   Execute all blocks in buffer
  C-c C-e l p Export to PDF (LaTeX)
  C-c '       Edit code block in dedicated buffer

Git
  C-x g       Magit status
              s = stage, u = unstage
              c c = commit, P p = push

Other
  C-c s       Scratchpad
  C-= / C--   Increase/decrease font
  C-c ?       This help
")))

(global-set-key (kbd "C-c ?") 'my-keybindings)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons anaconda-mode claude-code company company-anaconda
		   consult-org-roam diff-hl doom-modeline doom-themes
		   inheritenv magit marginalia orderless org-modern
		   transient treemacs vertico visual-fill-column vterm
		   with-editor xclip))
 '(package-vc-selected-packages
   '((claude-code :url "https://github.com/stevemolitor/claude-code.el"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
