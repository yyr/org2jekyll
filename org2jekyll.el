;;; org2jekyll.el
;;
;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: org2jekyll.el
;; Created: Tuesday, January 17 2012
;; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

;;; Description:
;; Pieces of this file directly are taken from the org2blog
;; https://github.com/punchagan/org2blog
;;
;; Post processing of the org exported html for Jekyll.
;; - write yaml front matter
;;   + set `org2jekyll-post-headers' for your headers, the default is
;;     '(title date category keywords layout published comments excerpt)
;;   + set `org2jekyll-write-yaml' to nil to switch off this processing
;; - convert source code block to be highlight by Jekyll/pygments
;;   + set `org2jekyll-process-src' to nil to switch off this processing
;; Additionally helper function(s) for
;; - creating template for new posts/pages
;;
;;=================================================================
;;; code starts here
(require 'org)
(defgroup org2jekyll nil
  "Post to weblogs from Emacs"
  :group 'org2jekyll)

;;=================================================================
;; user options
;;=================================================================
(defcustom org2jekyll-post-headers
  '(title
    date
    category
    keywords
    layout
    published
    comments
    excerpt)
  "list of required fields/properties in the org files. This list will be
used in `org2jekyll-post-template' and each field will be added in the
yaml front matter if their value is non-nil"
  :group 'org2jekyll
  :type 'list)

(defcustom org2jekyll-src-style "``` %s  \n %s```"
  "In jekyll/octopress there are few different ways highlight the
source code. default is pygments style"
  :group  'org2jekyll
  :type 'string)

(defcustom org2jekyll-process-src t
  "Clean org exported source code and place preferred jekyll format"
  :group 'org2jekyll
  :type 'boolean)

(defcustom org2jekyll-write-yaml t
  "Clean org exported source code and place preferred jekyll format"
  :group 'org2jekyll
  :type 'boolean)

(defcustom org2jekyll-basedir nil
  "root directory of the jekyll/octopress site
new post templates will be placed in `org2jekyll-basedir'/org/_posts/"
  :group  'org2jekyll
  :type 'string)

;;=================================================================
;; internal variables
;;=================================================================
(defvar org2jekyll-buffer-name "%s-%s.org"
  "Name of the post buffer")

;;=================================================================
;; Internal functions
;;=================================================================

;;; let org know our default headers
(add-hook 'org-export-first-hook
          (lambda ()
            (setq org-export-inbuffer-options-extra
                  (mapcar (lambda (x)
                            (let ((prop (format  "%s" x)))
                              (list (format "%s" (upcase prop))
                                    (intern (concat ":" prop)))))
                          org2jekyll-post-headers))))

(defun org2jekyll-write-yaml ()
  "inserts jekyll headers at the beginning of the buffer
---
title: XXX
other: '_'
---"
  (goto-char (point-min))
  (insert "---\n")
  (let ((al org2jekyll-post-headers))
    (mapc (lambda (x)
            (let* ((prop (format  "%s" x))
                   (val (plist-get
                         org-export-opt-plist
                         (intern (concat ":" prop)))))

              (if val
                  (insert (downcase prop) ": "
                          val "\n"))))
          al))
  (insert "---\n"))

(defun org2jekyll-process-src ()
  "Replace pre blocks with sourcecode shortcode blocks."
  (let (pos code lang)
    (save-excursion
      (goto-char (point-min))
      (save-match-data
        (while (re-search-forward
                "<pre\\(.*?\\)>\\(\\(.\\|[[:space:]]\\|\\\n\\)*?\\)</pre.*?>"
                nil t 1)
          (setq code (match-string-no-properties 2))
          (setq lang (match-string-no-properties 1))
          ;; When the codeblock is a src_block
          (if (save-match-data (string-match "src"
                                             lang))
              ;; Stripping out all the code highlighting done by htmlize
              (progn
                (setq code (replace-regexp-in-string "<.*?>" "" code))
                (setq lang (replace-regexp-in-string
                            "^.*src-\\(.*?\\)\"$" "\\1" lang))
                (replace-match
                 (format org2jekyll-src-style lang code) nil t))
            ;; swear put it back if its not a code block
            (insert code)))))))

(defun org2jekyll-process ()
  "Process org exported html.
Process code blocks with `org2jekyll-process-src'
Write yaml headers with `org2jekyll-write-yaml'
"
  (save-excursion
    ;; FIXME can we reduce no of lines with any special form (cond).?
    (if org2jekyll-write-yaml
        (funcall 'org2jekyll-write-yaml))
    (if org2jekyll-process-src
        (funcall 'org2jekyll-process-src))))

(add-hook 'org-export-html-final-hook 'org2jekyll-process)

;;=================================================================
;; user functions
;;=================================================================
;;;###autoload
(defun org2jekyll-new-post ()
  "Creates a new post/page entry."
  (interactive)
  (let* ((title
          ;; collect the title in the mini buffer
          (read-string "Title of the new post: " nil nil "no-title"))
         (date (format-time-string "%Y-%m-%d" (current-time)))
         (date (read-string (format "Date for the new post %s:" date)
                            nil nil date))
         (org2jekyll-new-post-buffer
          (generate-new-buffer
           (format org2jekyll-buffer-name
                   date
                   title))))
    (switch-to-buffer org2jekyll-new-post-buffer)
    (org-mode)
    (insert
     (format org2jekyll-post-template
             title
             date))))

(provide 'org2jekyll)
;;; org2jekyll.el ends here
