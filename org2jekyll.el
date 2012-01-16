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
;; - convert source code block to be highlight by Jekyll/pygments
;; Additionally helper function(s) for
;; - creating template for new posts/pages
;;
;;
;;=================================================================
;;; code starts here
(require 'org)

;;=================================================================
;; user options
;;=================================================================

(defcustom org2jekyll-post-template
  "#+TITLE: %s
#+DATE: %s
#+CATEGORY:
#+KEYWORDS:
#+LAYOUT: post
#+PUBLISHED: true
#+COMMENTS: true
#+DESCRIPTION:

#+OPTIONS: toc:nil num:nil todo:nil pri:nil tags:nil ^:nil TeX:nil
\n"
  "The default template to be inserted in a new post buffer."
  :group 'org2jekyll
  :type 'string)

(defcustom org2jekyll-src-template "```\n %s \n```"
  "In jekyll/octopress few different highlight the source code"
  :group  'org2jekyll
  :type 'string)

(defcustom org2jekyll-basedir nil
  "root directory of the jekyll/octopress site
new post templates will be placed in `org2jekyll-basedir'/org/_posts/"
  :group  'org2jekyll
  :type 'string)

(defvar org2jekyll-buffer-name "%s-%s.org"
  "Name of the post buffer")

;;=================================================================
;; internal variables
;;=================================================================


;;=================================================================
;; Internal functions
;;=================================================================

;;=================================================================
;; user functions
;;=================================================================
;;;###autoloads
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
