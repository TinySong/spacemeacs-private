;;; packages.el --- TinySong layer packages file for Spacemacs.
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
;; added to `TinySong-packages'. Then, for each package PACKAGE:
;;

;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `TinySong/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `TinySong/pre-init-PACKAGE' and/or
;;   `TinySong/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst tinysong-packages
  ;; (setq tinysong-packages
  '(
    ;; (hackernews :location build-in)
    js-doc
    smartparens
    erc
    ;; document create
    (doxymacs :location local)
    evil-vimish-fold
    beacon
    ctags-update
    projectile
    hl-anything
    helm-ag
    helm-gtags
    keyfreq
    ;; git-messenger for github
    git-messenger
    ;; visual-regexp-steroids and visual-regexp are reg serarch, steroids is an externsion to visual-regexp
    visual-regexp
    visual-regexp-steroids
    flycheck
    cmake-font-lock
    cmake-mode
    google-c-style
    ;; post extension names go here
    ;; nodejs-repl-eval don't support es6 and js2-mode also don't support it
    ;; so I use js-comit instead.
    nodejs-repl
    wrap-region
    org
    helm-flyspell
    helm
    occur-mode
    helm-ls-git
    youdao-dictionary
    find-file-in-project
    deft
    ;; header2
    ;; (unicad :location local)
    ;; worf
    ))


;;; packages.el ends here

;; TODO: https://www.gnu.org/software/emacs/manual/html_node/elisp/Desktop-Notifications.html

;; package init

(defun tinysong/post-init-js-doc ()
  (setq js-doc-mail-address "TinySong1226@gmail.com"
        js-doc-author (format "RongXiang Song <%s>" js-doc-mail-address)
        js-doc-url "http://www.TinySong.com"
        js-doc-license "MIT"))


;; https://ebzzry.github.io/emacs-pairs.html
(defun tinysong/post-init-smartparens ()
  (progn
    (defun wrap-sexp-with-new-round-parens ()
      (interactive)
      (insert "()")
      (backward-char)
      (sp-forward-slurp-sexp))

    (global-set-key (kbd "C-(") 'wrap-sexp-with-new-round-parens)
    (with-eval-after-load 'smartparens
      (evil-define-key 'normal sp-keymap
        (kbd ")>") 'sp-forward-slurp-sexp
        (kbd ")<") 'sp-forward-barf-sexp
        (kbd "(>") 'sp-backward-barf-sexp
        (kbd "(<") 'sp-backward-slurp-sexp))

    ))

(setq-default tab-width 4)


;; https://www.emacswiki.org/emacs/ERC
;; TODO: erc linux notation

;; (defun do-notify (nickname message)
;;   (let* ((channel (buffer-name))
;;          ;; using https://github.com/leathekd/erc-hl-nicks
;;          (nick (erc-hl-nicks-trim-irc-nick nickname))
;;          (title (if (string-match-p (concat "^" nickname) channel)
;;                     nick
;;                   (concat nick " (" channel ")")))
;;          ;; Using https://github.com/magnars/s.el
;;          (msg (s-trim (s-collapse-whitespace message))))
;;     ;; call the system notifier here
;;     ))

(defun tinysong/post-init-erc ()
  (progn
    (defun my-erc-hook (match-type nick message)
      "Shows a growl notification, when user's nick was mentioned. If the buffer is currently not visible, makes it sticky."
      (unless (posix-string-match "^\\** *Users on #" message)
        (tinysong/growl-notification
         (concat "ERC: : " (buffer-name (current-buffer)))
         message
         t
         )))
    (message "notation")
    (add-hook 'erc-text-matched-hook 'my-erc-hook)
    ;; (spaceline-toggle-erc-track-off)
    ))


;; https://www.ibm.com/developerworks/cn/aix/library/au-learningdoxygen/
;; http://emacser.com/doxymacs.htm
(defun tinysong/init-doxymacs ()
  "Initialize doxymacs, create document from souce-code"
  (use-package doxymacs
    :init
    (add-hook 'c-mode-common-hook 'doxymacs-mode)
    :config
    (progn
      (defun my-doxymacs-font-lock-hook ()
        (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))
            (doxymacs-font-lock)))
      (add-hook 'font-lock-mode-hook 'my-doxymacs-font-lock-hook)
      (spacemacs|hide-lighter doxymacs-mode))))


;; fold functions
(defun tinysong/init-evil-vimish-fold ()
  (use-package evil-vimish-fold
    :init
    (vimish-fold-global-mode 1)))

;; http://endlessparentheses.com/beacon-never-lose-your-cursor-again.html
(defun tinysong/init-beacon ()
  (use-package beacon
    :init
    (progn
      (spacemacs|add-toggle beacon
        :status beacon-mode
        :on (beacon-mode)
        :off (beacon-mode -1)
        :documentation "Enable point highlighting after scrolling"
        :evil-leader "otb")
      ;; (setq beacon-push-mark 60)
      ;; (setq beacon-color "#666600")
      ;; (setq beacon-color "#990099")
      (setq beacon-color "#FF9900")
      (spacemacs/toggle-beacon-on))
    :config (spacemacs|hide-lighter beacon-mode)))

;; http://blog.binchen.org/posts/how-to-use-ctags-in-emacs-effectively-3.html
(defun tinysong/init-ctags-update ()
  (use-package ctags-update
    :init
    (progn
      (add-hook 'c++-mode-hook 'turn-on-ctags-auto-update-mode)
      (add-hook 'c-mode-hook 'turn-on-ctags-auto-update-mode)
      (define-key evil-normal-state-map (kbd "gf")
        (lambda () (interactive) (find-tag (find-tag-default-as-regexp))))

      (define-key evil-normal-state-map (kbd "gb") 'pop-tag-mark)

      (define-key evil-normal-state-map (kbd "gn")
        (lambda () (interactive) (find-tag last-tag t)))
      )
    :defer t
    :config
    (spacemacs|hide-lighter ctags-auto-update-mode)))


;; https://github.com/bbatsov/projectile
(defun tinysong/post-init-projectile ()
  (with-eval-after-load 'projectile
    (progn
      (setq projectile-completion-system 'ivy)
      (projectile-global-mode)
      (setq projectile-indexing-method 'native)
      ;; to disable remote file exists cache that use this snippet of code
      (setq projectile-file-exists-remote-cache-expire nil)
      ;; to change the remote file exists ache expire to 30 second use the snippet of code
      (setq projectile-file-exists-remote-cache-expire (* 1 20))
      (add-to-list 'projectile-other-file-alist '("html" "js")) ;; switch from html -> js
      (add-to-list 'projectile-other-file-alist '("js" "html")) ;; switch from js -> html
      (spacemacs/set-leader-keys "pf" 'tinysong/open-file-with-projectile-or-lsgit) ;;
      )))


(defun tinysong/post-init-hl-anything ()
  (progn
    (hl-highlight-mode -1)
    (spacemacs|add-toggle toggle-hl-anything
      :status hl-highlight-mode
      :on (hl-highlight-mode)
      :off (hl-highlight-mode -1)
      :documentation "Toggle highlight anything mode."
      :evil-leader "ths")))

;; https://github.com/syohex/emacs-helm-ag
(defun tinysong/post-init-helm-ag ()
  (progn
    (setq helm-ag-use-agignore t)
    ;; This settings use .agignore file to ignore items, and it don't respect to .hgignore, .gitignore
    ;; when there are some git repositories are in .gitignore file, this options is very useful.
    ;;And the .agignore file while be searched at PROJECT_ROOT/.agignore and ~/.agignore
    ;; Thanks to 'man ag' and 'customize-group<RET> helm-ag' for finding the solution... Always RTFM.
    (setq helm-ag-command-option " -U" ))
  )

;; http://top.jobbole.com/11941/
(defun tinysong/post-init-helm-gtags ()
  (with-eval-after-load 'helm-gtags
    (progn
      (evil-make-overriding-map helm-gtags-mode-map 'normal)
      (add-hook 'helm-gtags-mode-hook #'evil-normalize-keymaps))))


;; https://github.com/benma/visual-regexp.el
(defun tinysong/init-visual-regexp ()
  (use-package visual-regexp
    :init))

(defun tinysong/init-visual-regexp-steroids ()
  (use-package visual-regexp-steroids
    :init))

;;In order to export pdf to support Chinese, I should install Latex at here: https://www.tug.org/mactex/
;; http://freizl.github.io/posts/2012-04-06-export-orgmode-file-in-Chinese.html
;;http://stackoverflow.com/questions/21005885/export-org-mode-code-block-and-result-with-different-styles
(defun tinysong/post-init-org ()
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

      (setq org-refile-use-outline-path 'file)
      (setq org-outline-path-complete-in-steps nil)
      (setq org-refile-targets
            '((nil :maxlevel . 4)
              (org-agenda-files :maxlevel . 4)))
      ;; config stuck project
      ;; http://orgmode.org/manual/Stuck-projects.html#Stuck-projects
      (setq org-stuck-projects
            '("TODO={.+}/-DONE" nil nil "SCHEDULED:\\|DEADLINE:"))

      (setq org-agenda-inhibit-startup t)       ;; ~50x speedup
      (setq org-agenda-use-tag-inheritance nil) ;; 3-4x speedup
      (setq org-agenda-window-setup 'current-window)
      (setq org-log-done t)

      ;; 加密文章
      ;; "http://coldnew.github.io/blog/2013/07/13_5b094.html"
      ;; https://www.emacswiki.org/emacs/EasyPG#toc5
      ;; org-mode 設定
      (require 'org-crypt)

      ;; 當被加密的部份要存入硬碟時，自動加密回去
      (org-crypt-use-before-save-magic)

      ;; 設定要加密的 tag 標籤為 secret
      (setq org-crypt-tag-matcher "secret")

      ;; 避免 secret 這個 tag 被子項目繼承 造成重複加密
      ;; (但是子項目還是會被加密喔)
      (setq org-tags-exclude-from-inheritance (quote ("secret")))

      ;; 用於加密的 GPG 金鑰
      ;; 可以設定任何 ID 或是設成 nil 來使用對稱式加密 (symmetric encryption)
      (setq org-crypt-key nil)

      (add-to-list 'auto-mode-alist '("\\.org\\’" . org-mode))



      (setq org-todo-keywords
            (quote ((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d!/!)")
                    (sequence "WAITING(w@/!)" "SOMEDAY(S)"  "|" "CANCELLED(c@/!)" "MEETING(m)" "PHONE(p)"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; Org clock
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ;; Change task state to STARTED when clocking in
      (setq org-clock-in-switch-to-state "STARTED")
      (setq org-clock-into-drawer t)
      ;; Removes clocked tasks with 0:00 duration
      (setq org-clock-out-remove-zero-time-clocks t) ;; Show the clocked-in task - if any - in the header line

      (setq org-tags-match-list-sublevels nil)

      ;; http://wenshanren.org/?p=327
      ;; change it to helm
      (defun tinysong/org-insert-src-block (src-code-type)
        "Insert a `SRC-CODE-TYPE' type source code block in org-mode."
        (interactive
         (let ((src-code-types
                '("emacs-lisp" "python" "C" "sh" "java" "js" "clojure" "C++" "css"
                  "calc" "asymptote" "dot" "gnuplot" "ledger" "lilypond" "mscgen"
                  "octave" "oz" "plantuml" "R" "sass" "screen" "sql" "awk" "ditaa"
                  "haskell" "latex" "lisp" "matlab" "ocaml" "org" "perl" "ruby"
                  "scheme" "sqlite")))
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
                                                 'tinysong/org-insert-src-block)
                                  ))

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

      ;;reset subtask
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

      ;; (setq org-plantuml-jar-path
      ;;       (expand-file-name "~/.spacemacs.d/plantuml.jar"))
      ;; (setq org-ditaa-jar-path "~/.spacemacs.d/ditaa.jar")


      (org-babel-do-load-languages
       'org-babel-load-languages
       '((perl . t)
         (ruby . t)
         (sh . t)
         (js . t)
         (python . t)
         (emacs-lisp . t)
         (plantuml . t)
         (C . t)
         (ditaa . t)))
      (setq org-agenda-files (quote ("~/org-notes" )))
      (setq org-default-notes-file "~/org-notes/gtd.org")

      (with-eval-after-load 'org-agenda
        (define-key org-agenda-mode-map (kbd "P") 'org-pomodoro)
        (spacemacs/set-leader-keys-for-major-mode 'org-agenda-mode
          "." 'spacemacs/org-agenda-transient-state/body)
        )
      ;; the %i would copy the selected text into the template
      ;;http://www.howardism.org/Technical/Emacs/journaling-org.html
      ;;add multi-file journal
      (setq org-capture-templates
            '(("t" "Todo" entry (file+headline "~/org-notes/gtd.org" "Workspace")
               "* TODO [#B] %?\n  %i\n"
               :empty-lines 1)
              ("n" "notes" entry (file+headline "~/org-notes/notes.org" "Quick notes")
               "* TODO [#C] %?\n  %i\n %U"
               :empty-lines 1)
              ("b" "Blog Ideas" entry (file+headline "~/org-notes/notes.org" "Blog Ideas")
               "* TODO [#B] %?\n  %i\n %U"
               :empty-lines 1)
              ("d" "Dev Driver" entry (file+headline "~/org-notes/net_driver.org" "Net Driver")
               "* TODO [#B] %?\n  %i\n %U"
               :empty-lines 1)
              ("k" "Kernel" entry (file+headline "~/org-notes/kernel.org" "Kernel Quick Note")
               ;; "* TODO [#B] %?\n  %i\n %U"
               ;; :empty-lines 1
               )
              ("w" "work" entry (file+headline "~/org-notes/gtd.org" "ISMS_Kernel")
               "* TODO [#A] %?\n  %i\n %U"
               :empty-lines 1)
              ("c" "Chrome" entry (file+headline "~/org-notes/notes.org" "Quick notes")
               "* TODO [#C] %?\n %(tinysong/retrieve-chrome-current-tab-url)\n %i\n %U"
               :empty-lines 1)
              ("l" "links" entry (file+headline "~/org-notes/notes.org" "Quick notes")
               "* TODO [#C] %?\n  %i\n %a \n %U"
               :empty-lines 1)
              ("j" "Journal Entry"
               entry (file+datetree "~/org-notes/journal.org")
               "* %?"
               :empty-lines 1)))

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
              ("pl" tags-todo "PROJECT+DREAM+CATEGORY=\"tinysong\"")
              ("W" "Weekly Review"
               ((stuck "")            ;; review stuck projects as designated by org-stuck-projects
                (tags-todo "PROJECT") ;; review all projects (assuming you use todo keywords to designate projects)
                ))))

      (defvar tinysong-website-html-preamble
        "<div class='nav'>
<ul>
<li><a href='http://tinysong.com'>博客</a></li>
<li><a href='/index.html'>Wiki目录</a></li>
</ul>
</div>")
      (defvar tinysong-website-html-blog-head
        " <link rel='stylesheet' href='css/site.css' type='text/css'/> \n
    <link rel=\"stylesheet\" type=\"text/css\" href=\"/css/worg.css\"/>")
      (setq org-publish-project-alist
            `(
              ("blog-notes"
               :base-directory "~/org-notes"
               :base-extension "org"
               :publishing-directory "~/org-notes/public_html/"

               :recursive t
               :html-head , tinysong-website-html-blog-head
               :publishing-function org-html-publish-to-html
               :headline-levels 4           ; Just the default for this project.
               :auto-preamble t
               :exclude "gtd.org"
               :exclude-tags ("ol" "noexport")
               :section-numbers nil
               :html-preamble ,tinysong-website-html-preamble
               :author "tinysong"
               :email "tinysong1226@gmail.com"
               :auto-sitemap t               ; Generate sitemap.org automagically...
               :sitemap-filename "index.org" ; ... call it sitemap.org (it's the default)...
               :sitemap-title "我的wiki"     ; ... with title 'Sitemap'.
               :sitemap-sort-files anti-chronologically
               :sitemap-file-entry-format "%t" ; %d to output date, we don't need date here
               )
              ("blog-static"
               :base-directory "~/org-notes"
               :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
               :publishing-directory "~/org-notes/public_html/"
               :recursive t
               :publishing-function org-publish-attachment
               )
              ("blog" :components ("blog-notes" "blog-static"))))

      (defun org-summary-todo (n-done n-not-done)
        "Switch entry to DONE when all subentries are done, to TODO otherwise."
        (let (org-log-done org-log-states)  ; turn off logging
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
      (define-key evil-normal-state-map (kbd "C-c C-w") 'org-refile)
      (spacemacs/set-leader-keys-for-major-mode 'org-mode
        "owh" 'plain-org-wiki-helm
        "owf" 'plain-org-wiki)
      (setq org-mobile-directory "~/org-notes/org")
      )))


(defun tinysong/post-init-helm-flyspell ()
  (progn
    ;; "http://emacs.stackexchange.com/questions/14909/how-to-use-flyspell-to-efficiently-correct-previous-word/14912#14912"
    (defun tinysong/flyspell-goto-previous-error (arg)
      "Go to arg previous spelling error."
      (interactive "p")
      (while (not (= 0 arg))
        (let ((pos (point))
              (min (point-min)))
          (if (and (eq (current-buffer) flyspell-old-buffer-error)
                   (eq pos flyspell-old-pos-error))
              (progn
                (if (= flyspell-old-pos-error min)
                    ;; goto beginning of buffer
                    (progn
                      (message "Restarting from end of buffer")
                      (goto-char (point-max)))
                  (backward-word 1))
                (setq pos (point))))
          ;; seek the next error
          (while (and (> pos min)
                      (let ((ovs (overlays-at pos))
                            (r '()))
                        (while (and (not r) (consp ovs))
                          (if (flyspell-overlay-p (car ovs))
                              (setq r t)
                            (setq ovs (cdr ovs))))
                        (not r)))
            (backward-word 1)
            (setq pos (point)))
          ;; save the current location for next invocation
          (setq arg (1- arg))
          (setq flyspell-old-pos-error pos)
          (setq flyspell-old-buffer-error (current-buffer))
          (goto-char pos)
          (call-interactively 'helm-flyspell-correct)
          (if (= pos min)
              (progn
                (message "No more miss-spelled word!")
                (setq arg 0))))))

    ;; http://endlessparentheses.com/ispell-and-abbrev-the-perfect-auto-correct.html#comment-2440958792
    (define-key ctl-x-map "\C-i"
      #'endless/ispell-word-then-abbrev)

    (defun endless/ispell-word-then-abbrev (p)
      "Call `ispell-word', then create an abbrev for it.
With prefix P, create local abbrev. Otherwise it will
be global."
      (interactive "P")
      (let (bef aft)
        (save-excursion
          (while (progn
                   (backward-word)
                   (and (setq bef (thing-at-point 'word))
                        (not (ispell-word nil 'quiet)))))
          (setq aft (thing-at-point 'word)))
        (when (and aft bef (not (equal aft bef)))
          (setq aft (downcase aft))
          (setq bef (downcase bef))
          (define-abbrev
            (if p local-abbrev-table global-abbrev-table)
            bef aft)
          (message "\"%s\" now expands to \"%s\" %sally"
                   bef aft (if p "loc" "glob")))))

    (setq save-abbrevs 'silently)
    (setq-default abbrev-mode t)

    (bind-key* "C-;" 'tinysong/flyspell-goto-previous-error)
    (global-set-key (kbd "C-c s") 'helm-flyspell-correct)))

(defun tinysong/post-init-helm ()
  (progn
    (global-set-key (kbd "C-s-y") 'helm-show-kill-ring)
    ;; See https://github.com/bbatsov/prelude/pull/670 for a detailed
    ;; discussion of these options.
    (setq helm-split-window-in-side-p t
          helm-move-to-line-cycle-in-source t
          helm-ff-search-library-in-sexp t
          helm-ff-file-name-history-use-recentf t
          helm-buffer-max-length 45)

    (setq helm-completing-read-handlers-alist
          '((describe-function . ido)
            (describe-variable . ido)
            (debug-on-entry . helm-completing-read-symbols)
            (find-function . helm-completing-read-symbols)
            (find-tag . helm-completing-read-with-cands-in-buffer)
            (ffap-alternate-file . nil)
            (tmm-menubar . nil)
            (dired-do-copy . nil)
            (dired-do-rename . nil)
            (dired-create-directory . nil)
            (find-file . ido)
            (copy-file-and-rename-buffer . nil)
            (rename-file-and-buffer . nil)
            (w3m-goto-url . nil)
            (ido-find-file . nil)
            (ido-edit-input . nil)
            (mml-attach-file . ido)
            (read-file-name . nil)
            (yas/compile-directory . ido)
            (execute-extended-command . ido)
            (minibuffer-completion-help . nil)
            (minibuffer-complete . nil)
            (c-set-offset . nil)
            (wg-load . ido)
            (rgrep . nil)
            (read-directory-name . ido)))))


(defun tinysong/init-helm-ls-git ()
  (use-package helm-ls-git
    :init
    (progn
      ;;beautify-helm buffer when long file name is present
      (setq helm-ls-git-show-abs-or-relative 'relative))))


(defun tinysong/init-keyfreq ()
  (use-package keyfreq
    :init
    (progn
      (keyfreq-mode t)
      (keyfreq-autosave-mode 1))))

;; https://github.com/syohex/emacs-git-messenger
(defun tinysong/post-init-git-messenger ()
  (use-package git-messenger
    :defer t
    :config
    (progn
      (defun song/github-browse-commit ()
        "Show the GitHub page for the current commit."
        (interactive)
        (use-package github-browse-file
          :commands (github-browse-file--relative-url))

        (let* ((commit git-messenger:last-commit-id)
               (url (concat "https://github.com/"
                            (github-browse-file--relative-url)
                            "/commit/"
                            commit)))
          (github-browse--save-and-view url)
          (git-messenger:popup-close)))
      (define-key git-messenger-map (kbd "f") '/github-browse-commit))))


(defun tinysong/post-init-flycheck ()
  (with-eval-after-load 'flycheck
    (progn
      ;; (setq flycheck-display-errors-function 'flycheck-display-error-messages)
      (setq flycheck-display-errors-delay 0.1)
      ;; (remove-hook 'c-mode-hook 'flycheck-mode)
      ;; (remove-hook 'c++-mode-hook 'flycheck-mode)
      ;; (evilify flycheck-error-list-mode flycheck-error-list-mode-map)
      )))

;; cmake https://www.ibm.com/developerworks/cn/linux/l-cn-cmake/
(defun tinysong/post-init-cmake-mode ()
  (progn
    (spacemacs/declare-prefix-for-mode 'cmake-mode
                                       "mh" "docs")
    (spacemacs/set-leader-keys-for-major-mode 'cmake-mode
      "hd" 'cmake-help)
    (defun cmake-rename-buffer ()
      "Renames a CMakeLists.txt buffer to cmake-<directory name>."
      (interactive)
      (when (and (buffer-file-name)
                 (string-match "CMakeLists.txt" (buffer-name)))
        (setq parent-dir (file-name-nondirectory
                          (directory-file-name
                           (file-name-directory (buffer-file-name)))))
        (setq new-buffer-name (concat "cmake-" parent-dir))
        (rename-buffer new-buffer-name t)))

    (add-hook 'cmake-mode-hook (function cmake-rename-buffer))))

(defun tinysong/init-cmake-font-lock ()
  (use-package cmake-font-lock
    :defer t))

;; http://blog.csdn.net/csfreebird/article/details/9250989
(defun tinysong/init-google-c-style ()
  (use-package google-c-style
    :init (add-hook 'c-mode-common-hook 'google-set-c-style)))


(defun tinysong/init-nodejs-repl ()
  (use-package nodejs-repl
    :init
    :defer t))


;; ;; https://github.com/capitaomorte/yasnippet
;; (defun tinysong/post-init-yasnippet ()
;;   (progn
;;     (setq-default yas-prompt-functions '(yas-ido-prompt yas-dropdown-prompt))
;;     (mapc #'(lambda (hook) (remove-hook hook 'spacemacs/load-yasnippet)) '(prog-mode-hook
;;                                                                        org-mode-hook
;;                                                                        markdown-mode-hook))

;;     (defun tinysong/load-yasnippet ()
;;       (unless yas-global-mode
;;         (progn
;;           ;; (yas-global-mode 1)
;;           (setq my-snippet-dir (expand-file-name "~/.spacemacs.d/snippets"))
;;           (setq yas-snippet-dirs  my-snippet-dir)
;;           (yas-load-directory my-snippet-dir)
;;           (setq yas-wrap-around-region t)))
;;       (yas-minor-mode 1))

;;     (spacemacs/add-to-hooks 'tinysong/load-yasnippet '(prog-mode-hook
;;                                                        markdown-mode-hook
;;                                                        org-mode-hook))
;;     ))

(defun tinysong/init-worf ()
  (use-package worf
    :defer t
    :init
    (add-hook 'org-mode-hook 'worf-mode)))

;; TODO : SPC o
(defun tinysong/init-occur-mode ()
  (defun occur-dwim ()
    "Call `occur' with a sane default."
    (interactive)
    (push (if (region-active-p)
              (buffer-substring-no-properties
               (region-beginning)
               (region-end))
            (let ((sym (thing-at-point 'symbol)))
              (when (stringp sym)
                (regexp-quote sym))))
          regexp-history)
    (call-interactively 'occur))
  (bind-key* "M-s o" 'occur-dwim)
  (evilified-state-evilify occur-mode occur-mode-map
    "RET" 'occur-mode-goto-occurrence))

(defun tinysong/init-wrap-region ()
  (use-package wrap-region
    :init
    (progn
      (wrap-region-global-mode t)
      (wrap-region-add-wrappers
       '(("$" "$")
         ("{-" "-}" "#")
         ("/" "/" nil ruby-mode)
         ("/* " " */" "#" (java-mode javascript-mode css-mode js2-mode))
         ("`" "`" nil (markdown-mode ruby-mode))))
      (add-to-list 'wrap-region-except-modes 'dired-mode)
      (add-to-list 'wrap-region-except-modes 'web-mode)
      )
    :defer t
    :config
    (spacemacs|hide-lighter wrap-region-mode)))

(defun tinysong/post-init-youdao-dictionary ()
  ;; ((interactive "P"))
  (spacemacs/set-leader-keys "oy" 'youdao-dictionary-search-at-point+))

(defun tinysong/post-init-persp-mode ()
  (when (fboundp 'spacemacs|define-custom-layout)
    (spacemacs|define-custom-layout "@Kernel"
      :binding "k"
      :body
      (find-file "~/kernel-2.6.11.12/Makefile")
      ;; (split-window-right)
      ;; (find-file "~/cocos2d-x/cocos/cocos2d.cpp")
      )))
(defun tinysong/init-unicad ()
  (use-package unicad
    :init))

;; (defun tinysong/init-header2
;;     (interactive "p")
;;   (use-package header2
;;     :init
;;     (autoload 'auto-make-header "header2")
;;     (add-hook 'write-file-hooks 'auto-update-file-header)
;;     (add-hook 'emacs-lisp-mode-hook 'auto-make-header)
;;     (add-hook 'c-mode-common-hook 'auto-make-header)
;;     (add-hook 'tex-mode-hook 'auto-make-header)
;;     ))

(defun tinysong/post-init-find-file-in-project ()
  (progn
    ;; If you use other VCS (subversion, for example), enable the following option
    ;;(setq ffip-project-file ".svn")
    ;; in MacOS X, the search file command is CMD+p
    (bind-key* "s-p" 'find-file-in-project)
    (setq-local ffip-find-options "-not -size +64k -not -iwholename '*/bin/*'")
    ;; for this project, I'm only interested certain types of files
    ;; (setq-default ffip-patterns '("*.html" "*.js" "*.css" "*.java" "*.xml" "*.js"))
    ;; if the full path of current file is under SUBPROJECT1 or SUBPROJECT2
    ;; OR if I'm reading my personal issue track document,
    ))

(defun tinysong/post-init-deft ()
  (progn
    (setq deft-use-filter-string-for-filename t)
    (spacemacs/set-leader-keys-for-major-mode 'deft-mode "q" 'quit-window)
    (setq deft-extension "org")
    (setq deft-directory "~/org-notes")))
