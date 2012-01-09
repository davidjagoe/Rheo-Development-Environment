
;;; General setup

(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)
(show-paren-mode t)
(transient-mark-mode t)
(desktop-save-mode t)
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(setq inhibit-startup-message t)
(setq column-number-mode t)
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;;; Start the emacs server
(server-start)

;;; Printing
(setq ps-lpr-command "lpr")
(global-set-key (kbd "C-x p") 'ps-print-buffer)
(global-set-key (kbd "C-x P") 'ps-print-buffer-with-faces)

;;; Set up load path
(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/rst-mode")
(add-to-list 'load-path "~/.emacs.d/puppet-mode")

;;; Requires
(require 'graphviz-dot-mode)
(require 'ido)
(ido-mode t)
(require 'rst)
(require 'puppet-mode)
(require 'espresso)
;; (require 'jabber-autoloads)

;;; Clojure
(add-hook 'clojure-mode-hook 'paredit-mode)
;; (require 'clojure-refactoring-mode)
;; symbols for some overlong function names
(eval-after-load 'clojure-mode
  '(font-lock-add-keywords
    'clojure-mode
    (mapcar
     (lambda (pair)
       `(,(car pair)
         (0 (progn (compose-region
                    (match-beginning 0) (match-end 0)
                    ,(cadr pair))
                   nil))))
     `(("\\<fn\\>" ,(make-char 'greek-iso8859-7 107))
       ("\\<comp\\>" ?∘)
       ("\\<partial\\>" ?þ)
       ("\\<complement\\>" ?¬)))))

;;; Auto modes
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(add-to-list 'auto-mode-alist '("\\.pyx$" . python-mode))
(add-to-list 'auto-mode-alist '("\\.pp$" . puppet-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . espresso-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . espresso-mode))
(autoload 'artist-mode "artist" "Enter artist-mode" t)
(autoload 'espresso-mode "espresso" nil t)
(setq auto-mode-alist
      (append '(("\\.txt$" . rst-mode)
                ("\\.rst$" . rst-mode)
                ("\\.rest$" . rst-mode)) auto-mode-alist))

;;; Calendar and diary
;; Use ISO dates so that even the Americans will understand me
(setq calendar-date-style 'iso)

(add-hook 'list-diary-entries-hook 'sort-diary-entries t)

;;; Org-mode setup
(define-key global-map "\C-ca" 'org-agenda)
(setq org-todo-keywords '("TODO" "STARTED" "WAITING" "DONE"))
(setq org-clock-modeline-total (quote current))
(setq org-agenda-include-diary t)
(setq org-return-follows-link t)
(setq org-log-done t)
;; Org templates
(setq org-remember-templates
      '(("Bug" ?b "* %?\n  %i\n  %a" "BUGS.org" "Bugs")
	("Todo" ?t "* TODO %?\n  %i\n  %a" "REMEMBER.org" "Tasks")
	("Reading" ?r "* %?\n%u\n%^C" "REMEMBER.org" "Reading")
        ("Idea" ?i "* %^{Title}\n%u\n  %i\n  %a" "REMEMBER.org" "New Ideas")))

;;; Org-diary functions
(defun diary-limited-cyclic (recurrences interval m d y)
  "For use in emacs diary. Cyclic item with limited number of recurrences.
   Occurs every INTERVAL days, starting on YYYY-MM-DD, for a
   total of RECURRENCES occasions.

   E.g.
      ** 19:00-21:00 Spanish lessons
         <%%(diary-limited-cyclic 8 7 8 18 2010)>
  "
 (let ((startdate (calendar-absolute-from-gregorian (list m d y)))
       (today (calendar-absolute-from-gregorian date)))
   (and (not (minusp (- today startdate)))
        (zerop (% (- today startdate) interval))
        (< (floor (- today startdate) interval) recurrences))))

;;; Remember mode setup
(org-remember-insinuate)
(setq org-directory "~/Organizer")
(setq org-default-notes-file (concat org-directory "/notes.org"))
(define-key global-map "\C-cr" 'org-remember)

;;; Browser setup
;; (setq browse-url-browser-function 'browse-url-firefox
;;       browse-url-new-window-flag  t
;;       browse-url-firefox-new-window-is-tab t)

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "chromium-browser")

;;; Custom elisp

(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

;; Word Count
;;; First version; has bugs!
(defun count-words-region (beginning end)
  "Print number of words in the region.
Words are defined as at least one word-constituent
character followed by at least one character that
is not a word-constituent.  The buffer's syntax
table determines which characters these are."
  (interactive "r")
  (message "Counting words in region ... ")

;;; 1. Set up appropriate conditions.
  (save-excursion
    (goto-char beginning)
    (let ((count 0))

;;; 2. Run the while loop.
      (while (< (point) end)
        (re-search-forward "\\w+\\W*")
        (setq count (1+ count)))

;;; 3. Send a message to the user.
      (cond ((zerop count)
             (message
              "The region does NOT have any words."))
            ((= 1 count)
             (message
              "The region has 1 word."))
            (t
             (message
              "The region has %d words." count))))))

;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/package.el"))
  (package-initialize))

(setq package-archives '(("ELPA" . "http://tromey.com/elpa/") 
                         ("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")))

;;; Custom
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(indent-tabs-mode nil)
 '(mouse-wheel-progressive-speed nil)
 '(org-agenda-custom-commands (quote (("d" todo #("DONE" 0 4 (face org-warning)) nil))))
 '(org-agenda-files (quote ("~/Organizer/")))
 '(org-agenda-skip-scheduled-if-done nil)
 '(rst-mode-lazy nil)
 '(show-paren-mode t)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify))
 '(vc-diff-switches "-u"))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 102 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))
