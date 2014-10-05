;;; evil-org-mode.el --- evil keybindings for org-mode

;; Copyright (C) 2014 by Tad Ashlock
;; Author: Tad Ashlock
;; URL: https://github.com/tadashlock/evil-org-mode.git
;; Git-Repository; git://github.com/tadashlock/evil-org-mode.git
;; Created: 2014-08-23
;; Version: 0.1.0
;; Package-Requires: ((evil "0")) ;TODO
;; Keywords: evil vim-emulation org-mode key-bindings presets

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;; Known Bugs:
;; See, https://github.com/tadashlock/evil-org-mode/issues

;; TODO:
;; * Fix org-mode to not have hard-coded references to key sequences in messages / documentation.
;;   For example, in org-kill-line, it mentions 'C-k' in an error message.
;;
;; * Maybe add to org-mode the function 'org-kill-whole-line' to override Emacs's 'kill-whole-line'.
;;   See 'org-kill-line' for reasons why.
;;
;; * Change org-mode's org-special-ctrl-a/e variable to not be key binding specific.
;;
;; * Change org-support-shift-left to not be key binding specific.
;;
;; * It looks to me like the mapping of evil-digit-argument-or-evil-beginning-of-line to "0"
;;   in evil-integration.el should actually call evil-define-motion evil-beginning-of-line-or-digit-argument.

(require 'evil)
(require 'org)

(define-minor-mode evil-org-mode
  "Buffer-local minor mode for integrating Evil Mode and Org Mode"
  :init-value nil
  :lighter " EvilOrg"
  :keymap (make-sparse-keymap) ; defines evil-org-mode-map
  :group 'evil-org
  (if evil-org-mode
      (evil-org-register)
    (evil-org-unregister)))

(add-hook 'org-mode-hook 'evil-org-mode) ; only load with org-mode


(defun evil-org-register ()
  (add-hook 'evil-move-beginning-of-line--move-beginning-of-line-functions
            'evil-org-beginning-of-line)
  (add-hook 'evil-beginning-of-line--move-beginning-of-line-functions
            'evil-org-beginning-of-line)
  (add-hook 'evil-delete-region--delete-region-functions
            'evil-org-delete-region)
  (add-hook 'evil-delete-backward-char-and-join--delete-backward-char-functions
            'evil-org-delete-backward-char-and-join))

(defun evil-org-unregister ()
  (remove-hook 'evil-move-beginning-of-line--move-beginning-of-line-functions
               'evil-org-move-beginning-of-line)
  (remove-hook 'evil-beginning-of-line--move-beginning-of-line-functions
               'evil-org-beginning-of-line)
  (remove-hook 'evil-delete-region--delete-region-functions
               'evil-org-delete-region)
  (remove-hook 'evil-delete-backward-char-and-join--delete-backward-char-functions
               'evil-org-delete-backward-char-and-join))


;;; Motions

(defun org-forward-paragraph-new (count)
  (interactive)
  (org-forward-paragraph))

(defun org-backward-paragraph-new (count)
  (interactive)
  (org-backward-paragraph))

(evil-define-motion evil-org-forward-paragraph (count)
  "Move to the end of the COUNT-th next paragraph."
  :jump t
  :type exclusive
  (evil-move-end count #'org-forward-paragraph-new #'org-backward-paragraph-new))

(define-key evil-org-mode-map [remap evil-forward-paragraph] #'evil-org-forward-paragraph)



;;;

(defun evil-org-beginning-of-line (arg)
  (org-beginning-of-line arg)
  t)

; This function calls org-delete-char with an argument of 1 rather than N in order
; to get the advanced table handling of Org Mode.
(defun evil-org-delete-region (beg end)
  (let ((N (- end beg)))
    (save-excursion
      (goto-char beg)
      (dotimes (i N) (org-delete-char 1))))
  t)


(evil-define-command evil-org-delete-backward-char-and-join (count)
  "Delete previous character and join lines.
If point is at the beginning of a line then the current line will
be joined with the previous line if and only if
`evil-backspace-join-lines'."
  (interactive "p")
  (org-delete-backward-char count)
  t)



(evil-define-key 'normal evil-org-mode-map
 "[\t" 'org-cycle
 "[C" 'org-ctrl-c-ctrl-c
 "[\r" 'org-ctrl-c-ret)







;TODO! (defun always-insert-item ()
;TODO!   "Force insertion of org item"
;TODO!   (if (not (org-in-item-p))
;TODO!       (insert "\n- ")
;TODO!     (org-insert-item)))
;TODO! 
;TODO! (defun evil-org-eol-call (fun)
;TODO!   "Go to end of line and call provided function"
;TODO!   (end-of-line)
;TODO!   (funcall fun)
;TODO!   (evil-append nil))

;TODO! ;; normal state shortcuts
;TODO! (evil-define-key 'normal evil-org-mode-map
;TODO!  "gh" 'outline-up-heading
;TODO!  "gj" (if (fboundp 'org-forward-same-level) ;to be backward compatible with older org version
;TODO!           'org-forward-same-level
;TODO!         'org-forward-heading-same-level)
;TODO!  "gk" (if (fboundp 'org-backward-same-level)
;TODO!           'org-backward-same-level
;TODO!         'org-backward-heading-same-level)
;TODO!  "gl" 'outline-next-visible-heading
;TODO!  "t" 'org-todo
;TODO!  "T" '(lambda () (interactive) (evil-org-eol-call (lambda() (org-insert-todo-heading nil))))
;TODO!  "H" 'org-beginning-of-line
;TODO!  "L" 'org-end-of-line
;TODO!  ";t" 'org-show-todo-tree
;TODO!  "o" '(lambda () (interactive) (evil-org-eol-call 'always-insert-item))
;TODO!  "O" '(lambda () (interactive) (evil-org-eol-call 'org-insert-heading))
;TODO!  "$" 'org-end-of-line
;TODO!  "^" 'org-beginning-of-line
;TODO!  "<" 'org-metaleft
;TODO!  ">" 'org-metaright
;TODO!  ";a" 'org-agenda
;TODO!  "-" 'org-cycle-list-bullet
;TODO!  (kbd "TAB") 'org-cycle)

;TODO! ;; normal & insert state shortcuts.
;TODO! (mapc (lambda (state)
;TODO!         (evil-define-key state evil-org-mode-map
;TODO!           (kbd "M-l") 'org-metaright
;TODO!           (kbd "M-h") 'org-metaleft
;TODO!           (kbd "M-k") 'org-metaup
;TODO!           (kbd "M-j") 'org-metadown
;TODO!           (kbd "M-L") 'org-shiftmetaright
;TODO!           (kbd "M-H") 'org-shiftmetaleft
;TODO!           (kbd "M-K") 'org-shiftmetaup
;TODO!           (kbd "M-J") 'org-shiftmetadown
;TODO!           (kbd "M-o") '(lambda () (interactive)
;TODO!                          (evil-org-eol-call
;TODO!                           '(lambda()
;TODO!                              (org-insert-heading)
;TODO!                              (org-metaright))))
;TODO!           (kbd "M-t") '(lambda () (interactive)
;TODO!                          (evil-org-eol-call
;TODO!                           '(lambda()
;TODO!                              (org-insert-todo-heading nil)
;TODO!                              (org-metaright))))
;TODO!           ))
;TODO!       '(normal insert))

(provide 'evil-org)
;;; evil-org.el ends here
