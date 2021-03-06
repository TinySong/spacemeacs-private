;;; packages.el --- ts-org layer packages file for Spacemacs. ;; -*- lexical-binding: t -*-
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;

;; Author: song <song@GE60-SHADOW-Walker.lan>
;; URL: https://github.com/TinySong/spacemacs-private
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:


;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `ts-org-packages'. Then, for each package PACKAGE:
;;

;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `ts-org/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `ts-org/pre-init-PACKAGE' and/or
;;   `ts-org/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:
(defconst ts-org-packages
  '(
    org
    org-tree-slide
    cnfonts
    ))

(defun ts-org/post-init-org ()
  (with-eval-after-load 'org
    (progn
      ;; https://github.com/syl20bnr/spacemacs/issues/2994#issuecomment-139737911
      (spacemacs|disable-company org-mode)
      ;; set org-priority major-mode leader key
      (spacemacs/set-leader-keys-for-major-mode 'org-mode
        "," 'org-priority)
      ;; (require 'org-compat)
      ;; http://orgmode.org/manual/Tracking-your-habits.html
      (require 'org-habit)
      (add-to-list 'org-modules 'org-habit)
      (add-hook 'org-mode-hook 'toc-org-enable)
      (setq org-outline-path-complete-in-steps nil)
      ;; config stuck project
      (setq org-stuck-projects
            '("TODO={.+}/-DONE" nil nil "SCHEDULED:\\|DEADLINE:"))

      (define-key global-map (kbd "<f12>") 'org-agenda)



      (setq org-agenda-inhibit-startup t)       ;; ~50x speedup
      (setq org-agenda-use-tag-inheritance nil) ;; 3-4x speedup
      (setq org-agenda-include-diary t)
      (setq org-agenda-window-setup 'current-window)
      (setq org-log-done t)

      ;; ;FIX: ~t~ keybindings evil-find-char-to
      ;; https://www.mail-archive.com/emacs-orgmode@gnu.org/msg112173.html
      (evil-define-key 'normal evil-org-mode-map
        (kbd "t") 'org-todo)

      ;; 加密文章
      ;; "http://coldnew.github.io/blog/2013/07/13_5b094.html"
      ;; https://www.emacswiki.org/emacs/EasyPG#toc5
      ;; org-mode 設定
      (require 'org-crypt)
      ;; (require 'epa-file)

      ;; (epa-file-enable)
      ;; ; Encrypt all entries before saving
      (org-crypt-use-before-save-magic)

      ;; 設定要加密的 tag 標籤為 secret
      (setq org-crypt-tag-matcher "secret")
      (spacemacs/set-leader-keys "oc" 'org-decrypt-entries)

      ;; 避免 secret 這個 tag 被子項目繼承 造成重複加密
      ;; (但是子項目還是會被加密喔)
      (setq org-tags-exclude-from-inheritance (quote ("secret")))

      ;; 用於加密的 GPG 金鑰
      ;; 可以設定任何 ID 或是設成 nil 來使用對稱式加密 (symmetric encryption)
      (setq org-crypt-key nil)

      (add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|text\\)\\’" . org-mode))



      ;; TODO each keywords means
      (setq org-todo-keywords
            (quote ((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d!/!)" "|" "NEXT(n)")
                    (sequence "HOLD(h)" "WAITING(w@/!)" "SOMEDAY(S)"  "|" "CANCELLED(c@/!)" "MEETING(m)" "PHONE(p)")
                    )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; Org clock
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ;; Change task state to STARTED when clocking in
      (setq org-clock-in-switch-to-state "STARTED")
      (setq org-clock-into-drawer t)
      ;; Removes clocked tasks with 0:00 duration
      ;; (setq org-clock-out-remove-zero-time-clocks t)
      ;; Show the clocked-in task - if any - in the header line
      (setq org-clock-persist 'history)
      (org-clock-persistence-insinuate)
      ;; TODO
      (setq org-tags-match-list-sublevels nil)

      ;; http://wenshanren.org/?p=327
      ;; change it to helm
      (defun ts-org/org-insert-src-block (src-code-type)
        "Insert a `SRC-CODE-TYPE' type source code block in org-mode."
        (interactive
         (let ((src-code-types
                '("emacs-lisp" "python" "C" "sh" "java" "js" "clojure" "C++" "css"
                  "calc" "asymptote" "dot" "gnuplot" "ledger" "lilypond" "mscgen"
                  "octave" "oz" "plantuml" "R" "sass" "screen" "sql" "awk" "ditaa"
                  "haskell" "latex" "lisp" "matlab" "ocaml" "org" "perl" "ruby"
                  "scheme" "sqlite" "yaml" "go")))
           (list (ido-completing-read "Source code type: " src-code-types))))
        (progn
          (newline-and-indent)
          (insert (format "#+BEGIN_SRC %s\n" src-code-type))
          (newline-and-indent)
          (insert "#+END_SRC\n")
          (previous-line 2)
          (org-edit-src-code)))

      (add-hook 'org-mode-hook '(lambda ()
                                  ;; keybinding for editing source code blocks
                                  ;; keybinding for inserting code blocks
                                  (local-set-key (kbd "C-c i s")
                                                 'ts-org/org-insert-src-block)
                                  ))
      (spacemacs/set-leader-keys-for-major-mode 'org-mode
        "iS" 'ts-org/org-insert-src-block)
      (spacemacs/set-leader-keys-for-major-mode 'org-mode
        "ie" 'org-edit-src-code)
      ;; http://orgmode.org/worg/org-tutorials/org-publish-html-tutorial.html
      (require 'ox-publish)
      (add-to-list 'org-latex-classes '("ctexart" "\\documentclass[11pt]{ctexart}
                                        [NO-DEFAULT-PACKAGES]
                                        \\usepackage[utf8]{inputenc}
                                        \\usepackage[T1]{fontenc}
                                        \\usepackage{fixltx2e}
                                        \\usepackage{graphicx}
                                        \\usepackage{longtable}
                                        \\usepackage{float}
                                        \\usepackage{wrapfig}
                                        \\usepackage{rotating}
                                        \\usepackage[normalem]{ulem}
                                        \\usepackage{amsmath}
                                        \\usepackage{textcomp}
                                        \\usepackage{marvosym}
                                        \\usepackage{wasysym}
                                        \\usepackage{amssymb}
                                        \\usepackage{booktabs}
                                        \\usepackage[colorlinks,linkcolor=black,anchorcolor=black,citecolor=black]{hyperref}
                                        \\tolerance=1000
                                        \\usepackage{listings}
                                        \\usepackage{xcolor}
                                        \\lstset{
                                        %行号
                                        numbers=left,
                                        %背景框
                                        framexleftmargin=10mm,
                                        frame=none,
                                        %背景色
                                        %backgroundcolor=\\color[rgb]{1,1,0.76},
                                        backgroundcolor=\\color[RGB]{245,245,244},
                                        %样式
                                        keywordstyle=\\bf\\color{blue},
                                        identifierstyle=\\bf,
                                        numberstyle=\\color[RGB]{0,192,192},
                                        commentstyle=\\it\\color[RGB]{0,96,96},
                                        stringstyle=\\rmfamily\\slshape\\color[RGB]{128,0,0},
                                        %显示空格
                                        showstringspaces=false
                                        }
                                        "
                                        ("\\section{%s}" . "\\section*{%s}")
                                        ("\\subsection{%s}" . "\\subsection*{%s}")
                                        ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                                        ("\\paragraph{%s}" . "\\paragraph*{%s}")
                                        ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

      ;; {{ export org-mode in Chinese into PDF
      ;; @see http://freizl.github.io/posts/tech/2012-04-06-export-orgmode-file-in-Chinese.html
      ;; and you need install texlive-xetex on different platforms
      ;; To install texlive-xetex:
      ;;    `sudo USE="cjk" emerge texlive-xetex` on Gentoo Linux
      ;; }}
      (setq org-latex-default-class "ctexart")
      (setq org-latex-pdf-process
            '(
              "xelatex -interaction nonstopmode -output-directory %o %f"
              "xelatex -interaction nonstopmode -output-directory %o %f"
              "xelatex -interaction nonstopmode -output-directory %o %f"
              "rm -fr %b.out %b.log %b.tex auto"))

      (setq org-latex-listings t)

      ;; =================== start ========================================================
      ;;reset all subtask when finish the repeat task
      (setq org-default-properties (cons "RESET_SUBTASKS" org-default-properties))

      (defun org-reset-subtask-state-subtree ()
        "Reset all subtasks in an entry subtree."
        (interactive "*")
        (if (org-before-first-heading-p)
            (error "Not inside a tree")
          (save-excursion
            (save-restriction
              (org-narrow-to-subtree)
              (org-show-subtree)
              (goto-char (point-min))
              (beginning-of-line 2)
              (narrow-to-region (point) (point-max))
              (org-map-entries
               '(when (member (org-get-todo-state) org-done-keywords)
                  (org-todo (car org-todo-keywords))))
              ))))

      (defun org-reset-subtask-state-maybe ()
        "Reset all subtasks in an entry if the `RESET_SUBTASKS' property is set"
        (interactive "*")
        (if (org-entry-get (point) "RESET_SUBTASKS")
            (org-reset-subtask-state-subtree)))

      (defun org-subtask-reset ()
        (when (member org-state org-done-keywords) ;; org-state dynamically bound in org.el/org-todo
          (org-reset-subtask-state-maybe)
          (org-update-statistics-cookies t)))

      (add-hook 'org-after-todo-state-change-hook 'org-subtask-reset)
      ;; =================== end ========================================================

      (org-babel-do-load-languages
       'org-babel-load-languages
       '((perl . t)
         (ruby . t)
         (shell . t)
         (js . t)
         (python . t)
         (emacs-lisp . t)
         (plantuml . t)
         (C . t)
         (ditaa . t)))

      (setq org-agenda-refile (expand-file-name "refile.org" org-note-dir))
      (setq org-agenda-files (quote ("~/org-notes/personal" "~/org-notes/project" "~/org-notes/business" "~/org-notes/schedule.org" "~/org-notes/refile.org")))


      (with-eval-after-load 'org-agenda
        (when (configuration-layer/package-usedp 'org-pomodoro)
          ;; (define-key org-agenda-mode-map (kbd "P") 'org-pomodoro)
          )

        (spacemacs/set-leader-keys-for-major-mode 'org-agenda-mode
          "." 'spacemacs/org-agenda-transient-state/body)
        )
      ;; the %i would copy the selected text into the template
      ;;http://www.howardism.org/Technical/Emacs/journaling-org.html
      ;;add multi-file journal
      (setq org-capture-templates
            '(
              ("t"  "Quick Task" entry (file+headline "~/org-notes/refile.org" "QuickTask")
               "* TODO %?  %i \n%U"
               )

              ("T"  "Task" entry (file+headline "~/org-notes/refile.org" "Task")
               "* TODO %?  %i \n%U"
               )
              ;; soloved client something
              ("w" "work" entry (file+olp+datetree "~/org-notes/refile.org" "Work")
               "* TODO [#A] %? :Work: \n SCHEDULED: %t\n%U\n"
               )

              ("i" "iterative summary" entry (file+olp+datetree "~/org-notes/refile.org" "Iterative summary")
               "* TODO [#A] %? :Work: \n SCHEDULED: %t\n%U\n"
               )

              ("W" "week summary" entry (file+olp+datetree "~/org-notes/refile.org" "Week Summary")
               "* %? :Idea: %i \n%U"
               )

              ("s" "stand meeting" entry (file+olp+datetree "~/org-notes/refile.org" "Stand Meeting")
               "* %? :MEETING: %i \n%U"
               )

              ("p" "Project" entry (file+headline "~/org-notes/refile.org" "Project")
               "* TODO [#B] %? :Project: %i\n%U"
               )

              ("m" "Meeting" entry (file+headline "~/org-notes/refile.org" "Meeting")
               "* MEETING with %? :MEETING:\n%U" :clock-in t
               )

              ("n" "notes" entry (file+headline "~/org-notes/refile.org" "Notes")
               "* %? :NOTE:\n%U\n%a\n"
               )
              )
            )

      ;;An entry without a cookie is treated just like priority ' B '.
      ;;So when create new task, they are default 重要且紧急
      (setq org-agenda-custom-commands
            '(
              ("w" . "任务安排")
              ("wa" "重要且紧急的任务" tags-todo "+PRIORITY=\"A\"")
              ("wb" "重要且不紧急的任务" tags-todo "-Weekly-Monthly-Daily+PRIORITY=\"B\"")
              ("wc" "不重要且紧急的任务" tags-todo "+PRIORITY=\"C\"")
              ("b" "Blog" tags-todo "BLOG")
              ("p" . "项目安排")
              ;; ("pw" tags-todo "PROJECT+WORK+CATEGORY=\"cocos2d-x\"")
              ("pl" tags-todo "PROJECT+DREAM+CATEGORY=\"project\"")
              ("W" "Weekly Review"
               ((stuck "") ;; review stuck projects as designated by org-stuck-projects
                (tags-todo "PROJECT") ;; review all projects (assuming you use todo keywords to designate projects)
                ))))


      (defun org-summary-todo (n-done n-not-done)
        "Switch entry to DONE when all subentries are done, to TODO otherwise."
        (let (org-log-done org-log-states) ; turn off logging
          (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

      (add-hook 'org-after-todo-statistics-hook 'org-summary-todo)
      ;; used by org-clock-sum-today-by-tags
      (defun filter-by-tags ()
        (let ((head-tags (org-get-tags-at)))
          (member current-tag head-tags)))

      (defun org-clock-sum-today-by-tags (timerange &optional tstart tend noinsert)
        (interactive "P")
        (let* ((timerange-numeric-value (prefix-numeric-value timerange))
               (files (org-add-archive-files (org-agenda-files)))
               (include-tags '("WORK" "EMACS" "DREAM" "WRITING" "MEETING"
                               "LIFE" "PROJECT" "OTHER"))
               (tags-time-alist (mapcar (lambda (tag) `(,tag . 0)) include-tags))
               (output-string "")
               (tstart (or tstart
                           (and timerange (equal timerange-numeric-value 4) (- (org-time-today) 86400))
                           (and timerange (equal timerange-numeric-value 16) (org-read-date nil nil nil "Start Date/Time:"))
                           (org-time-today)))
               (tend (or tend
                         (and timerange (equal timerange-numeric-value 16) (org-read-date nil nil nil "End Date/Time:"))
                         (+ tstart 86400)))
               h m file item prompt donesomething)
          (while (setq file (pop files))
            (setq org-agenda-buffer (if (file-exists-p file)
                                        (org-get-agenda-file-buffer file)
                                      (error "No such file %s" file)))
            (with-current-buffer org-agenda-buffer
              (dolist (current-tag include-tags)
                (org-clock-sum tstart tend 'filter-by-tags)
                (setcdr (assoc current-tag tags-time-alist)
                        (+ org-clock-file-total-minutes (cdr (assoc current-tag tags-time-alist)))))))
          (while (setq item (pop tags-time-alist))
            (unless (equal (cdr item) 0)
              (setq donesomething t)
              (setq h (/ (cdr item) 60)
                    m (- (cdr item) (* 60 h)))
              (setq output-string (concat output-string (format "[-%s-] %.2d:%.2d\n" (car item) h m)))))
          (unless donesomething
            (setq output-string (concat output-string "[-Nothing-] Done nothing!!!\n")))
          (unless noinsert
            (insert output-string))
          output-string))
      (global-set-key (kbd "C-c a") 'org-agenda)
      (define-key org-mode-map (kbd "s-p") 'org-priority)
      (define-key global-map (kbd "<f9>") 'org-capture)
      (global-set-key (kbd "C-c b") 'org-iswitchb)

      ;; org refile
      (setq org-reverse-note-order t)
      (setq org-refile-allow-creating-parent-nodes 'confirm)
      ;; Use full outline paths for refile targets - we file directly with IDO
      (setq org-refile-use-outline-path 'file)
      (setq org-refile-targets
            '((nil :maxlevel . 4)
              (org-agenda-files :maxlevel . 4)))
      (define-key evil-normal-state-map (kbd "C-c C-w") 'org-refile)

      ;; org mobile
      (setq org-mobile-directory "~/org-notes/mobile")
      )))


(defun ts-org/init-org-tree-slide ()
  (use-package org-tree-slide
    :init
    :defer t
    :config))


(defun ts-org/init-cnfonts ()
  (use-package cnfonts
    :init
    (cnfonts-enable)
    :config
    (cnfonts-set-spacemacs-fallback-fonts))

  )
