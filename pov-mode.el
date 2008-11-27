;;; pov-mode.el --- major mode for Povray scene files
;;
;; Author: Peter Boettcher <pwb@andrew.cmu.edu>
;; Maintainer: Peter Toneby <woormie@acc.umu.se>
;; Created: 04 March 1994
;; Modified: 08 Sep 2003
;; Version: 2.10
;; Keywords: pov, povray
;;
;; LCD Archive Entry:
;; povray|Peter Toneby|woormie@acc.umu.se|
;; Major mode for Povray scene files|
;; 08-Sep-2003|2.10|~/lib/emacs/pov-mode.el|
;;
;; Copyright (C) 1997 Peter W. Boettcher
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;
;;; Commentary:
;;
;; This major mode for GNU Emacs provides support for editing Povray
;; scene files, rendering and viewing them.  It automatically indents
;; blocks, both {} and #if #end.  It also provides context-sensitive
;; keyword completion and font-lock highlighting, as well as the
;; ability to look up those keywords in the povray docu.
;;
;; It should work for either Xemacs or FSF Emacs, versions >= 20;
;; however, only Xemacs can display pictures.
;;
;; To automatically load pov-mode every time Emacs starts up, put the
;; following line into your .emacs file:
;;
;;      (require 'pov-mode)
;;
;; Of course pov-mode has to be somewhere in your load-path for emacs
;; to find it (Use C-h v load-path to see which directories are in the
;; load-path).
;;
;; NOTE: To achieve any sort of reasonable performance, YOU MUST
;;   byte-compile this package.  In emacs, type M-x byte-compile
;;   and then enter the name of this file.
;;
;; You can customize the behaviour of pov-mode and via the
;; customization menu or by simply entering M-x customize-group pov.
;; In many or even most cases, however, it should be completely
;; sufficient to to rely on the default settings.
;;
;; To learn about the basics, just load a pov-file and press C-h m.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modified by: Peter Boettcher <pwb@andrew.cmu.edu>
;;  5/8/97:
;;    Added font-lock support for Emacs/XEmacs 19
;;    Indent under `#declare Object=' lines
;;    Corrected comment syntax
;;    Got rid of more remnants from postscript mode
;;    General cleanup
;;    Arbitrarily chose version 1.2
;; 5/8/97:  Version 1.21
;;    fontify-insanely was ignored.  fixed.
;;
;; 9/24/97: Version 1.3
;;    Added indentation for Pov 3 syntax (#if #else, etc)
;;    Preliminary context-sensitive keyword completion
;;
;; 1/13/98 by Peter Boettcher <pwb@andrew.cmu.edu>
;;    Explicitly placed package under GPL
;;    Reorganized comment sections and change log to follow GNU standards
;;    Added simple code for jumping to pov documentation (Thanks to
;;         Benjamin Strautin <bis@acpub.duke.edu> for this code)
;;
;; Modified by: Peter Toneby <woormie@acc.umu.se>
;;  22/3/99: Version 1.99beata1
;;    Added support for Pov3.1s new keywords. (not all, I think...)
;;    Removed atmosphere (and atmosphere_*) (stupid me...)
;;
;; Modified by: Peter Toneby <woormie@acc.umu.se>
;;  23/4/99: Version 1.99beata2
;;    Added support for all new keyword, BUT
;;    Added atmosphere (and atmosphere_*) again
;;    Got Pete Boettchers blessing to continue (but with a note
;;      that said that I should have talked to him first, I'm sorry
;;      for not doing that). Pete also said he was willing to let
;;      me continue the maintainance of this file.
;;    I can't get the pov-keyword-help to work, anyone with knowledge
;;      about elisp can send me a fix for it.
;;    The keyword expansion doesn't work for all keywords,
;;      I need to add lots of stuff and read through the docs
;;      to get everything correct.
;;
;; Modified by: Alexander Schmolck <aschmolck@gmx.de>
;; 2000-01-31: Version 2beataXXX
;;    Added working keyword lookup in povuser.txt
;;    Added rendering and viewing from within Emacs and with an external viewer
;;    Added customization and made installation simpler
;;    Added a few other minor details
;;
;; Modified by: Peter Toneby <woormie@acc.umu.se>
;; 2000-05-24: Version 2
;;    Changed the keyword lookup a little, povuser.txt didn't open as
;;       expected when having set the pov-home-dir and pov-help-file
;;       manually.
;;
;; Modified by: Peter Toneby <woormie@acc.umu.se>
;; 2000-08-10: Version 2.5b1
;;    Added povray-font-lock-faces.
;;    Made sure font-lock works properly on:
;;        XEmacs 19.15p7
;;        XEmacs 20.0
;;        XEmacs 21.1p10
;;        Emacs 19.29.1
;;        Emacs 20.7.2
;;    Added all 3.1 keywords except track, since I don't know what it
;;        is, I have also dropped the 3.0 specific keywords that
;;        shouldn't be used anymore.
;;    Fixed some completion stuff, I think I have added all keywords to
;;        the completions.
;;    Added configureation for all faces. To bad I can't get the defaults
;;        to work properly on dark backgrounds, I don't know why that is.
;;    Added a toolbar, it replaces to standard XEmacs toolbar, I think
;;        that is the best thing to do, but I retain the standard useful
;;        functionality.
;;    Fixed an error in the external viewer, it used variables that were
;;        not available in the same scope as the sentinel.
;;    Added basic imenu support, currently only #local and #declare,
;;        but I will try to add objects, cameras and lightsources later.
;; 2000-09-12 Version 2.5.b2
;;    Added basic support for megapov
;;    Bob Pepin fixed a bug in test to select external/internal viewer.
;;    fortsätt på kapitel 5.6
;; 2001-04-05 Version 2.6
;;    Added the capability to open standard include files by pressing
;;        C-c i. It opens the file entered ro.
;;    Fixed leeking color in emacs (Robert Kleemann)
;;    Changed the rendertoolbarbutton to show a popup dialog with buttons
;;        for the different qualities.
;; 2001-12-07 Version 2.7
;;    Fixed font-locks for Emacs 21
;; 2002-06-19 Version 2.8
;;    Fixed loading for Emacs 21-2, missed a test for customizations
;;    Added most parts of a patch from  Christoph Hormann that cleaned
;;        up the Regexp mess, and added all (or at least most) of the
;;        keywords for 3.5 Parts of that patch are still missing, I'll
;;        get around to those sometime...
;; 2002-08-07 Version 2.9
;;    Added Insert menu, it uses the directory structure of the winpov
;;        insert menu.
;;    Moved the toolbar icons out to separate xpm-files.
;;    Added some missing keyword expansions
;;    Fixed so that box, cylinder... has their own face, object-face,
;;        removed unused faces
;;    Cleaned up the code, removed unused stuff.
;;    It works in versions 21, can't test in 20, font-lock is borked for me.
;; 2002-08-10 Version 2.9.1
;;    Fixed so that tollbar icons are searched for, not hard coded.
;; 2003-08-29 Version 2.10
;;    Fixed references to povray.el.
;;    Fixed cut-n-pasted comment for font-pov-operator-face.
;;    Fixed the insert menus, they missed the last items, thanks to Hartwig
;;        Bosse for the heads up, and a fix.
;; 2003-08-29 Version 2.11 (This is a future version)
;;    Fix a bug with rendering so that the active buffer is changed to the
;;        correct buffer, found by Hartwig Bosse.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Original Author:     Kevin O. Grover <grover@isri.unlv.edu>
;;        Cre Date:     04 March 1994
;; This file derived from postscript mode by Chris Maio
;;
;;  Please send bug reports/comments/suggestions to Peter Toneby
;;        woormie@acc.umu.se
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; TODO list:
;; * Vector operations (add <0, .5, 1> to every vector in region)
;; * Clean up completion code
;; * TAGS, to jump to #declared objects elsewhere in the code
;; * c-mode like electric parens (?)
;; * clean up viewing and rendering code
;; * should render or view be decided on filedates? If so, what
;;     image file-name extensions should be checked?
;;     I think PNG is default for UNIX, not sure.
;;     I could make this a customizeation option.
;; * imenu support
;;     started, but needs to be fixed so it handles nested menus.
;; * Make sure the scopes are correct
;; * Make hooks for menus, so they are userselectable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Better safe than sorry, lets fail if you are using a (very?) old
;; version of (X)Emacs.
(if (if (save-match-data (string-match "Lucid\\|XEmacs" (emacs-version)))
	(and (= emacs-major-version 19) (< emacs-minor-version 14))
      (and (= emacs-major-version 19) (< emacs-minor-version 29)))
    (error "`font-pov' was written for Emacs 19.29/XEmacs 19.14 or later"))

(defvar font-pov-is-XEmacs19
  (and (not (null (save-match-data
                    (string-match "XEmacs\\|Lucid" emacs-version))))
       (= 19 emacs-major-version)))
(defvar font-pov-is-XEmacs20
  (and (not (null (save-match-data
                    (string-match "XEmacs\\|Lucid" emacs-version))))
       (<= 20 emacs-major-version)))
(defvar font-pov-is-XEmacs21
  (and (not (null (save-match-data
                    (string-match "XEmacs\\|Lucid" emacs-version))))
       (<= 21 emacs-major-version)))

(defvar font-pov-is-XEmacs20-2
  (or (and font-pov-is-XEmacs20 (<= 2 emacs-minor-version))
      font-pov-is-XEmacs21))

(defvar font-pov-is-Emacs19
  (and (not font-pov-is-XEmacs19)
       (not font-pov-is-XEmacs20)
       (= 19 emacs-major-version)))
(defvar font-pov-is-Emacs20
  (and (not font-pov-is-XEmacs19)
       (not font-pov-is-XEmacs20)
       (= 20 emacs-major-version)))
(defvar font-pov-is-Emacs21
  (and (not font-pov-is-XEmacs19)
       (not font-pov-is-XEmacs20)
       (not font-pov-is-XEmacs21)
       (= 21 emacs-major-version)))

(defvar font-pov-is-Emacs
  (or font-pov-is-Emacs19 font-pov-is-Emacs20 font-pov-is-Emacs21))

(require 'cl)
(require 'font-lock) ;;[TODO] Not nice to reqire it, the user should
                     ;;       have a choise...

(defconst pov-mode-version '2.10
  "The povray mode version.")

(defvar pov-tab-width 8)
(defvar pov-autoindent-endblocks t)

;;Create fontfaces
(defvar font-pov-number-face 'font-pov-number-face
  "Face to use for PoV numbers.")

(defvar font-pov-variable-face 'font-pov-variable-face
  "Face to use for PoV variables.")

(defvar font-pov-directive-face 'font-pov-directive-face
  "Face to use for PoV directives.")

(defvar font-pov-object-face 'font-pov-object-face
  "Face to use for PoV objects.")

;(defvar font-pov-object-modifier-face 'font-pov-object-modifier-face
;  "Face to use for PoV objects.")

;(defvar font-pov-texture-face 'font-pov-texture-face
;  "Face to use for PoV objects.")

(defvar font-pov-operator-face 'font-pov-operator-face
  "Face to use for PoV operators.")

(defvar font-pov-csg-face 'font-pov-csg-face
  "Face to use for PoV csg keywords.")

;(defvar font-pov-string-face nil
;  "Face to use for strings.  This is set by font-PoV.")

(defvar font-pov-macro-name-face nil
  "Face to use for strings.  This is set by font-PoV.")

(defvar font-pov-keyword-face nil
  "Face to use for misc keywords.  This is set by font-PoV.")

(defvar pov-insertmenu-location nil
  "Location of the InsertMenu directory structure.")

(defvar pov-icons-location nil
  "Location of the menubaricons.")

; Seems like Emacs lacks these functions (locate-data-[directory|file])...
(unless (fboundp 'locate-data-directory)
  (defun locate-data-directory (name &optional dirs)
    (if dirs
        (if (file-directory-p (expand-file-name name (car dirs)))
            (expand-file-name name (car dirs))
          (locate-data-directory name (cdr dirs)))
      (expand-file-name name data-directory))))

(unless (fboundp 'locate-data-file)
  (defun locate-data-file (name &optional dirs)
    (print dirs)
    (if dirs
        (if (file-regular-p (expand-file-name name (car dirs)))
            (expand-file-name name (car dirs))
          (locate-data-file name (cdr dirs)))
      (expand-file-name name data-directory))))

;; This is because FSFEmacs has a ridiculusly low max-lisp-eval-depth
(when (> 1000 max-lisp-eval-depth)
  (customize-set-value 'max-lisp-eval-depth 1000))

;; Yup XEmacs didn't get cutomizations until 20.2.
(cond ((or font-pov-is-XEmacs20-2 (or font-pov-is-Emacs20 font-pov-is-Emacs21))
      (defgroup  pov nil
	"*Major mode for editing povray 3.X scence files <http://www.povray.org>."
	:group 'languages)

      (defcustom povray-command "povray"
	"*Command used to invoke the povray."
	:type 'string
	:group 'pov)

      (defcustom pov-external-viewer-command "xv"
	"*The external viewer to call."
	:type 'string
	:group 'pov)

      (defcustom pov-external-view-options "%s"
	"*The options for the viewer; %s is replaced with the name of the rendered image."
	:type 'string
	:group 'pov)

      ;;allow user to customize external or internal viewer as defaults if she
      ;;is using Xemacs; for FSF Emacs assume external, since it can't
      ;;handle pictures anyway
      ;(if  (and (boundp 'running-xemacs) running-xemacs)
      (defcustom pov-default-view-internal t
	"*Should the pictures be displayed internally by default?"
	:type 'boolean
	:group 'pov)
      ;(defvar pov-default-view-internal nil))

      (defcustom pov-run-default "+i%s"
	"*The default options for the Render command (%s is replaced by the filename)."
	:type 'string
	:group 'pov
	)
      (defcustom pov-run-test "res120 -Q3 +i%s"
	"*The default options for the Test Render command (%s is replaced by the filename)."
	:type 'string
	:group 'pov
	)
      (defcustom pov-run-low "res320 +i%s"
	"*The default options for the Test Render command (%s is replaced by the filename)."
	:type 'string
	:group 'pov
	)
      (defcustom pov-run-mid "res640 +i%s"
	"*The default options for the Medium Res Render command (%s is replaced by the filename)."
	:type 'string
	:group 'pov
	)
      (defcustom pov-run-high "res800 +i%s"
	"*The default options for the High Res Render command (%s is replaced by the filename)."
	:type 'string
	:group 'pov
	)
      (defcustom pov-run-highest "res1k +i%s"
	"*The default options for the Higest Res Render command (%s is replaced by the filename)."
	:type 'string
	:group 'pov
	)
      (defvar pov-external-view
	"External view")
      (defvar pov-internal-view
	"Internal view")
      (defvar pov-command-alist (list (list "Render"
					    povray-command pov-run-default
					    '()) ;history for the command
				      (list "Test quality render"
					    povray-command pov-run-test
					    '())
				      (list "Low quality render"
					    povray-command pov-run-low
					    '())
				      (list "Medium quality render"
					    povray-command pov-run-highest
					    '())
				      (list "High quality render"
					    povray-command pov-run-high
					    '())
				      (list pov-external-view
					    pov-external-viewer-command
					    pov-external-view-options
					    '())
				      (list pov-internal-view
					    (list pov-internal-view)
					    '()))
	"the commands to run")

      (defcustom pov-home-dir "/usr/local/lib/povray31/"
	"*The directory in which the povray files reside."
	:type 'directory
	:group 'pov)

      (defcustom pov-include-dir "/usr/local/lib/povray31/include/"
	"*The directory in which the povray includefiles reside."
	:type 'directory
	:group 'pov)

      (defcustom pov-help-file "povuser.txt"
	"*The name of the helpfile."
	:type  'file
	:group 'pov)

      (defcustom pov-associate-pov-and-inc-with-pov-mode-flag t
	"*If t then files ending with .pov and .inc will automatically start
pov-mode when loaded, unless those file-endings are already in use."
	:type 'boolean
	:group 'pov)

      (defcustom pov-fontify-insanely t
	"*Non-nil means colorize every povray keyword.  This may take a while on lare files.  Maybe disable this on slow systems."
	:type 'boolean
	:group 'pov)

      (defcustom pov-imenu-in-menu t
	"*Non-nil means have #locals and #declares in a menu called PoV in the menubar. This may take a while on lare files.  Maybe disable this on slow systems."
	:type 'boolean
	:group 'pov)
;; CH
      (defcustom pov-imenu-only-macros t
        "*Non-nil means to restrict imenu to macro declarations."
        :type 'boolean
        :group 'pov)
;; /end CH
      (defcustom pov-indent-level 2
	"*Indentation to be used inside of PoVray blocks or arrays."
	:type 'integer
	:group 'pov)

      (defcustom pov-autoindent-endblocks t
	"*When non-nil, automatically reindents when you type break, end, or else."
	:type 'boolean
	:group 'pov
	)

      (defcustom pov-indent-under-declare 2
	"*Indentation under a `#declare Object=' line."
	:type 'integer
	:group 'pov)

      (defcustom pov-tab-width 8
	"*Tab stop width for PoV mode."
	:type 'integer
	:group 'pov)

      (defcustom pov-turn-on-font-lock t
	"*Turn on syntax highlighting automatically"
	:type 'boolean
	:group 'pov)

      (defcustom font-pov-csg-face t
	"*What color does CSG-object have"
	:type 'face
	:group 'pov)

      (defcustom font-pov-object-face t
	"*What color does objects have"
	:type 'face
	:group 'pov)

      (defcustom font-pov-variable-face t
	"*What color does variables (in declarations) have"
	:type 'face
	:group 'pov)

;      (defcustom font-pov-string-face t
;	"*What color does strings have"
;	:type 'face
;	:group 'pov)

;      (defcustom font-pov-texture-face t
;	"*What color does textures have"
;	:type 'face
;	:group 'pov)

;      (defcustom font-pov-object-modifier-face t
;	"*What color does object modifiers have"
;	:type 'face
;	:group 'pov)

      (defcustom font-pov-directive-face t
	"*What color does (#)-directives have"
	:type 'face
	:group 'pov)

      (defcustom font-pov-number-face t
	"*What color does numbers have"
	:type 'face
	:group 'pov)

      (defcustom font-pov-keyword-face t
	"*What color does keywords have"
	:type 'face
	:group 'pov)
      )
)

; Find where the menubar icons are placed, should be where pov-mode is...
(setq pov-icons-location 
      (file-name-directory (locate-data-file "povrender.xpm" 
					     (cons (file-name-directory (locate-library "pov-mode")) 
						   (if font-pov-is-Emacs data-directory data-directory-list)))))

;; Lets play with the Toolbar, we want to add buttons for 
;; rendering and showing images, lets place them on the rightmost
;; position of the toolbar.
(cond ((or font-pov-is-XEmacs20 font-pov-is-XEmacs21)
       (defvar toolbar-render-icon
	 (if (featurep 'xpm)
	     (let ((rendericon (concat pov-icons-location "povrender.xpm")))
	       (toolbar-make-button-list (make-image-instance (vector 'xpm :file rendericon))))
	 ))
       (defvar toolbar-look-icon
	 (if (featurep 'xpm)
	     (let ((viewicon (concat pov-icons-location "povview.xpm")))
	       (toolbar-make-button-list (make-image-instance (vector 'xpm :file viewicon))))
	   ))
       (defvar pov-toolbar 
	 '(
	   [toolbar-file-icon    toolbar-open    t "Open a file"] 
	   [toolbar-folder-icon  toolbar-dired   t "Edit a directory"]
	   [toolbar-disk-icon    toolbar-save    t "Save buffer"]
	   [toolbar-printer-icon toolbar-print   t "Print buffer"]
	   [toolbar-cut-icon     toolbar-cut     t "Kill region"]
	   [toolbar-copy-icon    toolbar-copy    t "Copy region"]
	   [toolbar-paste-icon   toolbar-paste   t "Paste from clipboard"]
	   [toolbar-undo-icon    toolbar-undo    t "Undo edit"]
	   [toolbar-spell-icon   toolbar-ispell  t "Check spelling"]
	   [toolbar-replace-icon toolbar-replace t "Search & Replace"]
	   nil
	   [toolbar-render-icon  (pov-render-dialog) t "Configured Render the file"]
;	   [toolbar-render-icon 
;	    (pov-render-file "Render" (buffer-file-name) nil) 
;	    t "Quick Render the file"]
	   [toolbar-look-icon
	    (if pov-default-view-internal
		(pov-display-image-xemacs pov-image-file)
	      (pov-display-image-externally pov-image-file nil))
	    t "Show the rendered file"]
	   ))
       (defvar pov-render-dialog-desc
	 '("Render Image"
	   ["Test render"   (pov-render-file "Test quality render"   (buffer-file-name) nil) t]
	   ["Low render"    (pov-render-file "Low quality render"    (buffer-file-name) nil) t]
	   ["Medium render" (pov-render-file "Medium quality render" (buffer-file-name) nil) t]
	   ["High render"   (pov-render-file "High quality render"   (buffer-file-name) nil) t]
	   ["Render"        (pov-render-file "Render"                (buffer-file-name) nil) t]
	   ["Cancel"        (pov-render-file "Render"                (buffer-file-name) nil) t]
	   ))
       ))

(defun pov-toolbar ()
  (interactive)
  (set-specifier default-toolbar (cons (current-buffer) pov-toolbar)))

;; Menubar stuff, buttonmenu will be nice to have too.


;; Abbrev support
(defvar pov-mode-abbrev-table nil
  "Abbrev table in use in pov-mode buffers.")
(define-abbrev-table 'pov-mode-abbrev-table ())

(cond ((or font-pov-is-XEmacs20-2 font-pov-is-Emacs20)
       (when pov-turn-on-font-lock
	 (turn-on-font-lock))
       ;; associate *.pov and *.inc with pov if flag is set and no other
       ;; modes already have
       (cond (pov-associate-pov-and-inc-with-pov-mode-flag 
	      (when (not (assoc "\\.pov\\'" auto-mode-alist))
		(setq auto-mode-alist
		      (append '(("\\.pov\\'" . pov-mode)) auto-mode-alist)))
	      (when (not (assoc "\\.inc\\'" auto-mode-alist))
		(setq auto-mode-alist
		      (append '(("\\.inc\\'" . pov-mode)) auto-mode-alist)))))
       ))

;;END AS

(defvar font-pov-do-multi-line t
  "*Set this to nil to disable the multi-line fontification prone to infinite loop bugs.")

(defun font-pov-setup ()
  "Setup this buffer for PoV font-lock."
  (cond
   ((or font-pov-is-Emacs20 font-pov-is-Emacs21)
    ;; Tell Font Lock about the support.
    (make-local-variable 'font-lock-defaults))
   ((or font-pov-is-XEmacs19 font-pov-is-XEmacs20)
    ;; Cool patch from Christoph Wedler...
    (let (instance)
      (mapcar (function
	       (lambda (property)
		 (setq instance
		       (face-property-instance 'font-pov-number-face property nil 0 t))
		 (if (numberp instance)
		     (setq instance
			   (face-property-instance 'default property nil 0)))
		 ;(or (numberp instance)
		 ;    (set-face-property 'font-lock-string-face property
		;			instance (current-buffer)))))
		 ))
	      (built-in-face-specifiers))))
   (font-pov-is-Emacs19
    (make-local-variable 'font-lock-defaults))))

(cond
 ((or font-pov-is-Emacs20 font-pov-is-XEmacs20-2 font-pov-is-Emacs21)
  (defface font-pov-object-face
    '((((class grayscale) (background light)) (:foreground "DimGray" :bold t))
      (((class grayscale) (background dark))  (:foreground "LightGray" :bold t))
      (((class color) (background light))    (:foreground "DarkOliveGreen" :bold t))
      (((class color) (background dark))     (:foreground "White" :bold t ))
      (t (:bold t)))
    "Font Lock mode face used for objects."
    :group 'font-pov-faces)
  
  (defface font-pov-directive-face
    '((((class grayscale) (background light)) (:foreground "DimGray"))
      (((class grayscale) (background dark))  (:foreground "LightGray"))
      (((class color) (background light))     (:foreground "DarkRed"))
      (((class color) (background dark))      (:foreground "lightgreen"))
      (t (:italic t)))
    "Font Lock mode face used to highlight PoV directives."
    :group 'font-pov-faces)
  
  (defface font-pov-number-face
    '((((class grayscale) (background light))(:foreground "DimGray" :underline t))
      (((class grayscale) (background dark)) (:foreground "LightGray" :underline t))
      (((class color) (background light))    (:foreground "SaddleBrown"))
      (((class color) (background dark))     (:foreground "wheat"))
      (t (:underline t)))
    "Font Lock mode face used to highlight numbers in PoV."
    :group 'font-pov-faces)
  
  (defface font-pov-variable-face
    '((((class grayscale) (background light)) (:foreground "DimGray"))
      (((class grayscale) (background dark))  (:foreground "LightGray"))
      (((class color) (background light))     (:foreground "ForestGreen"))
      (((class color) (background dark))      (:foreground "gray80"))
      )
    "Font Lock mode face used to highlight variabledeclarations in PoV."
    :group 'font-pov-faces)
  
  (defface font-pov-csg-face
    '((((class grayscale) (background light)) (:foreground "DimGray"))
      (((class grayscale) (background dark))  (:foreground "LightGray"))
      (((class color) (background light))     (:foreground "Blue"))
      (((class color) (background dark))      (:foreground "red"))
      )
    "Font Lock mode face used to highlight CSGs in PoV."
    :group 'font-pov-faces)
  
;; -- C.H. --

  (defface font-pov-macro-name-face
    '((((class grayscale) (background light)) (:foreground "DimGray" :bold t))
      (((class grayscale) (background dark))  (:foreground "LightGray" :bold t))
      (((class color) (background light))     (:foreground "Blue2" :bold t))
      (((class color) (background dark))      (:foreground "gray80" :bold t))
      )
    "Font Lock mode face used to highlight macro declarations in PoV."
    :group 'font-pov-faces)

  (defface font-pov-keyword-face
    '((((class grayscale) (background light)) (:foreground "DimGray"))
      (((class grayscale) (background dark))  (:foreground "LightGray"))
      (((class color) (background light))     (:foreground "Blue4"))
      (((class color) (background dark))      (:foreground "Blue"))
      )
    "Font Lock mode face used to highlight general keywords in PoV."
    :group 'font-pov-faces)

;; -- end C.H. --


  (defface font-pov-operator-face
    '((((class grayscale)(background light)) (:foreground "DimGray" :bold t))
      (((class grayscale)(background dark))  (:foreground "LightGray" :bold t))
      (((class color)(background light))     (:foreground "Limegreen" :bold t ))
      (((class color)(background dark))      (:foreground "Limegreen" :bold t ))
      (t (:bold t)))
    "Font Lock mode face used to highlight operators in PoV."
    :group 'font-pov-faces))
 
 (font-pov-is-Emacs19
  (unless (assq 'font-pov-variable-face font-lock-face-attributes)
    (cond 
     ;; FIXME: Add better conditions for grayscale.
     ((memq font-lock-display-type '(mono monochrome grayscale greyscale
					  grayshade greyshade))
      (setq font-lock-face-attributes
	    (append
	     font-lock-face-attributes
	     (list '(font-pov-variable-face nil nil t nil nil)
		   '(font-pov-macro-name-face nil nil t nil nil)  ;; C.H.
		   '(font-pov-keyword-face nil nil nil t nil)     ;; C.H.
		   '(font-pov-object-face nil nil nil t nil)
		   '(font-pov-number-face nil nil nil nil t)
		   (list
		    'font-pov-operator-face
		    (cdr (assq 'background-color (frame-parameters)))
		    (cdr (assq 'foreground-color (frame-parameters)))
		    nil nil nil)))))
     ((eq font-lock-background-mode 'light) ; light color background
      (setq font-lock-face-attributes
	    (append 
	     font-lock-face-attributes
	     ;;;FIXME: These won't follow font-lock-type-face's changes.
	     ;;;       Should I change to a (copy-face) scheme?
	     '((font-pov-variable-face "DarkOliveGreen" nil t nil nil)
	       (font-pov-macro-name-face "DarkOliveGreen" nil t nil nil)  ;; C.H.
	       (font-pov-keyword-face "grey50")                           ;; C.H.
	       (font-pov-number-face "DarkOliveGreen" nil nil t nil)
	       (font-pov-object-face "grey50")
	       (font-pov-directive-face "red" nil t nil nil)))))
     (t			; dark color background
      (setq font-lock-face-attributes
	    (append 
	     font-lock-face-attributes
	     '((font-pov-varible-face "OliveDrab" nil t nil nil)
	       (font-pov-macro-name-face "OliveDrab" nil t nil nil)   ;; C.H.
	       (font-pov-keyword-face "grey60")                       ;; C.H.
	       (font-pov-number-face "OliveDrab" nil nil t nil)
	       ;; good are > LightSeaGreen, LightCoral, coral, orchid, orange
	       (font-pov-object-face "grey60")
	       (font-pov-directive-face "red" nil t nil nil))))))))
 (t
  ;;; XEmacs < version 20.2
  (make-face 'font-pov-variable-face "Face to use for PoV variables.")
  (make-face 'font-pov-macro-name-face "Face to use for PoV macros.")      ;; C.H.
  (make-face 'font-pov-keyword-face "Face to use for PoV keywords.")       ;; C.H.
  (make-face 'font-pov-directive-face "Face to use for PoV directives.")
  (make-face 'font-pov-number-face "Face to use for PoV numbers.")
  (make-face 'font-pov-operator-face "Face to use for PoV operators.")
  (make-face 'font-pov-csg-face "Face to use for PoV csg.")
  (make-face 'font-pov-object-face "Face to use for PoV objects.")

  (make-face-bold 'font-pov-object-face)
  
  ;; XEmacs uses a tag-list thingy to determine if we are using color
  ;;  or mono (and I assume a dark background).
  (set-face-foreground 'font-pov-object-face "green4" 'global nil 'append)
  (set-face-foreground 'font-pov-number-face "green" 'global nil 'append)
  (set-face-foreground 'font-pov-variable-face "red" 'global nil 'append)
  (set-face-foreground 'font-pov-macro-name-face "blue2" 'global nil 'append)   ;; C.H.
  (set-face-foreground 'font-pov-keyword-face "blue4" 'global nil 'append)      ;; C.H.
  ))


(font-pov-setup) ;; Setup and register the fonts...

(defun pov-make-tabs (stop)
  (and (< stop 132) (cons stop (pov-make-tabs (+ stop pov-tab-width)))))

(defconst pov-tab-stop-list (pov-make-tabs pov-tab-width)
  "Tab stop list for PoV mode")

(defvar pov-mode-map nil
  "Keymap used in PoV mode buffers")

(defvar pov-mode-syntax-table nil
  "PoV mode syntax table")

(defconst pov-comment-start-regexp "//\\|/\\*"
  "Dual comment value for `comment-start-regexp'.")

(defvar pov-comment-syntax-string ". 124b"
  "PoV hack to handle Emacs/XEmacs foo")

(defvar pov-begin-re "\\<#\\(if\\(n?def\\)?\\|case\\|range\\|switch\\|while\\)\\>")
(defvar pov-end-re  "\\<#break\\|#end\\>")

(defvar pov-else-re "\\<#else\\>")

(defvar pov-begin-end-re (concat
			  pov-begin-re
			  "\\|"
			  pov-end-re
			  "\\|"
			  pov-else-re))

(defun pov-setup-syntax-table nil
  (if (or (string-match "Lucid" emacs-version)
	  (string-match "XEmacs" emacs-version))
      (setq pov-comment-syntax-string ". 1456"))
  (if pov-mode-syntax-table
      ()
    (setq pov-mode-syntax-table (make-syntax-table))
    (modify-syntax-entry ?_ "w" pov-mode-syntax-table)
    (modify-syntax-entry ?# "w" pov-mode-syntax-table)
    (modify-syntax-entry ?/ pov-comment-syntax-string pov-mode-syntax-table)
    (modify-syntax-entry ?* ". 23" pov-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" pov-mode-syntax-table)
    (set-syntax-table pov-mode-syntax-table)))

;; -- C.H. --

(defvar pov-all-keyword-matcher
  (eval-when-compile
    (concat "\\<\\("
	    (regexp-opt '("aa_level" "aa_threshold" "abs" "absorption" "accuracy" "acos" "acosh" "adaptive"
			  "adc_bailout" "agate" "agate_turb" "all" "all_intersections" "alpha" "altitude"
			  "always_sample" "ambient" "ambient_light" "angle" "aperture" "append" "arc_angle"
			  "area_light" "array" "asc" "ascii" "asin" "asinh" "assumed_gamma" "atan" "atan2"
			  "atanh" "autostop" "average"
			  "b_spline" "background" "bezier_spline" "bicubic_patch" "black_hole" "blob" "blue"
			  "blur_samples" "bounded_by" "box" "boxed" "bozo" "break" "brick" "brick_size"
			  "brightness" "brilliance" "bump_map" "bump_size" "bumps"
			  "camera" "case" "caustics" "ceil" "cells" "charset" "checker" "chr" "circular"
			  "clipped_by" "clock" "clock_delta" "clock_on" "collect" "color" "color_map"
			  "colour" "colour_map" "component" "composite" "concat" "cone" "confidence"
			  "conic_sweep" "conserve_energy" "contained_by" "control0" "control1" "coords"
			  "cos" "cosh" "count" "crackle" "crand" "cube" "cubic" "cubic_spline" "cubic_wave"
			  "cutaway_textures" "cylinder" "cylindrical" "debug" "declare" "default" "defined"
			  "degrees" "density" "density_file" "density_map" "dents" "df3" "difference"
			  "diffuse" "dimension_size" "dimensions" "direction" "disc" "dispersion"
			  "dispersion_samples" "dist_exp" "distance" "div" "double_illuminate" "eccentricity"
			  "else" "emission" "end" "error" "error_bound" "evaluate" "exp" "expand_thresholds"
			  "exponent" "exterior" "extinction"
			  "face_indices" "facets" "fade_color" "fade_colour" "fade_distance" "fade_power"
			  "falloff" "falloff_angle" "false" "fclose" "file_exists" "filter" "final_clock"
			  "final_frame" "finish" "fisheye" "flatness" "flip" "floor" "focal_point" "fog"
			  "fog_alt" "fog_offset" "fog_type" "fopen" "form" "frame_number" "frequency" 
			  "fresnel" "function" "gather" "gif" "global_lights" "global_settings" "gradient" 
			  "granite" "gray" "gray_threshold" "green"
			  "height_field" "hexagon" "hf_gray_16" "hierarchy" "hypercomplex" "hollow"
			  "if" "ifdef" "iff" "ifndef" "image_height" "image_map" "image_pattern" "image_width"
			  "include" "initial_clock" "initial_frame" "inside" "int" "interior" "interior_texture" 
			  "internal" "interpolate" "intersection" "intervals" "inverse" "ior" "irid" 
			  "irid_wavelength" "isosurface"
			  "jitter" "jpeg" "julia" "julia_fractal"
			  "lambda" "lathe" "leopard" "light_group" "light_source" "linear_spline" "linear_sweep"
			  "ln" "load_file" "local" "location" "log" "look_at" "looks_like" "low_error_factor"
			  "macro" "magnet" "major_radius" "mandel" "map_type" "marble" "material" "material_map"
			  "matrix" "max" "max_extent" "max_gradient" "max_intersections" "max_iteration"
			  "max_sample" "max_trace" "max_trace_level" "media" "media_attenuation"
			  "media_interaction" "merge" "mesh" "mesh2" "metallic" "method" "metric" "min" 
			  "min_extent" "minimum_reuse" "mod" "mortar"
			  "natural_spline" "nearest_count" "no" "no_bump_scale" "no_image" "no_reflection"
			  "no_shadow" "noise_generator" "normal" "normal_indices" "normal_map" "normal_vectors"
			  "number_of_waves"
			  "object" "octaves" "off" "offset" "omega" "omnimax" "on" "once" "onion" "open"
			  "orient" "orientation" "orthographic"
			  "panoramic" "parallel" "parametric" "pass_through" "pattern" "perspective" "pgm"
			  "phase" "phong" "phong_size" "photons" "pi" "pigment" "pigment_map" "pigment_pattern"
			  "planar" "plane" "png" "point_at" "poly" "poly_wave" "polygon" "pot" "pow" "ppm"
			  "precision" "precompute" "pretrace_end" "pretrace_start" "prism" "projected_through"
			  "pwr"
			  "quadratic_spline" "quadric" "quartic" "quaternion" "quick_color" "quick_colour"
			  "quilted"
			  "radial" "radians" "radiosity" "radius" "rainbow" "ramp_wave" "rand" "range"
			  "range_divider" "ratio" "read" "reciprocal" "recursion_limit" "red" "reflection"
			  "reflection_exponent" "refraction" "render" "repeat" "rgb" "rgbf" "rgbft" "rgbt"
			  "right" "ripples" "rotate" "roughness"
			  "samples" "save_file" "scale" "scallop_wave" "scattering" "seed" "select" "shadowless"
			  "sin" "sine_wave" "sinh" "size" "sky" "sky_sphere" "slice" "slope" "slope_map"
			  "smooth" "smooth_triangle" "solid" "sor" "spacing" "specular" "sphere" "sphere_sweep"
			  "spherical" "spiral1" "spiral2" "spline" "split_union" "spotlight" "spotted" "sqr"
			  "sqrt" "statistics" "str" "strcmp" "strength" "strlen" "strlwr" "strupr" "sturm"
			  "substr" "superellipsoid" "switch" "sys"
			  "t" "tan" "tanh" "target" "text" "texture" "texture_list" "texture_map" "tga"
			  "thickness" "threshold" "tiff" "tightness" "tile2" "tiles" "tolerance" "toroidal"
			  "torus" "trace" "transform" "translate" "transmit" "triangle" "triangle_wave" "true"
			  "ttf" "turb_depth" "turbulence" "type"
			  "u" "u_steps" "ultra_wide_angle" "undef" "union" "up" "use_alpha" "use_color"
			  "use_colour" "use_index" "utf8" "uv_indices" "uv_mapping" "uv_vectors"
			  "v" "v_steps" "val" "variance" "vaxis_rotate" "vcross" "vdot" "version"
			  "vertex_vectors" "vlength" "vnormalize" "vrotate" "vstr" "vturbulence" "warning"
			  "warp" "water_level" "waves" "while" "width" "wood" "wrinkles" "write"
			  "x"
			  "y" "yes"
			  "z") t)
	    "\\)\\>")))

(defvar pov-all-directives-matcher
  (eval-when-compile
    (concat "\\<\\("
	    (regexp-opt '("#break" "#case" "#debug" "#declare" "#default" "#else" "#end" "#error" "#fclose"
			  "#fopen" "#if" "#ifdef" "#ifndef" "#include" "#local" "#macro" "#range" "#read"
			  "#render" "#statistics" "#switch" "#undef" "#version" "#warning" "#while" "#write") t)
	    "\\)\\>")))

(defvar pov-all-objects-matcher
  (eval-when-compile
    (concat "\\<\\("
	    (regexp-opt '("background" "bicubic_patch" "blob" "box" "camera" "cone" "cubic" "cylinder" "disc"
			  "fog" "height_field" "isosurface" "julia_fractal" "lathe" "light_group" "light_source"
			  "mesh" "mesh2" "object" "parametric" "plane" "poly" "polygon" "prism" "rainbow"
			  "sky_sphere" "smooth_triangle" "sor" "sphere" "sphere_sweep" "superellipsoid" "text" "torus"
			  "triangle" "quadric" "quartic") t)
	    "\\)\\>")))

(defvar pov-font-lock-keywords
  (list
   ;; highlight variable names after '#declare/#local'
   (list "\\<\\(#declare\\|#local\\)\\>[ \t\n]*\\(\\sw+\\)" '(2 font-pov-variable-face nil t))
   ;; highlight csg-keywords
   (list "\\<\\(difference\\|intersection\\|merge\\|union\\)\\>" '(1 font-pov-csg-face))
   ;; highlight variable names after '#macro'
   (list "\\<\\(#macro\\)\\>[ \t\n]*\\(\\sw+\\)" '(2 font-pov-macro-name-face nil t))
   ;; highlight numbers with type-face
   (list "\\(\\<\\([0-9]*\\.[0-9]+\\|[0-9]+\\)\\|\\.[0-9]+\\)\\([eE][+\\-]?[0-9]+\\)?\\>"
	 '(1 font-pov-number-face))
   ;; highlight operators keywords
   (list "\\([\\-\\+\\|\\^=&!?:/\\>\\<\\*]+\\)" '(1 font-pov-operator-face))
   ;; highlight directives
   (list pov-all-directives-matcher '(1 font-pov-directive-face))
   ;; highlight objects
   (list pov-all-objects-matcher '(1 font-pov-object-face))
   ;; highlight general keywords
   (list pov-all-keyword-matcher '(1 font-pov-keyword-face))
   )
  "Expressions to highlight in PoV mode."
)
;; -- end C.H --

(defun pov-mode nil
  "Major mode for editing PoV files. (Version 2.11)

   In this mode, TAB and \\[indent-region] attempt to indent code
based on the position of {} pairs and #-type directives.  The variable
pov-indent-level controls the amount of indentation used inside
arrays and begin/end pairs.  The variable pov-indent-under-declare
determines indent level when you have something like this:
#declare foo =
   some_object {

This mode also provides PoVray keyword fontification using font-lock.
Set pov-fontify-insanely to nil to disable (recommended for large
files!).

\\[pov-complete-word] runs pov-complete-word, which attempts to complete the
current word based on point location.
\\[pov-keyword-help] looks up a povray keyword in the povray documentation.
\\[pov-command-query] will render or display the current file.

\\{pov-mode-map}

\\[pov-mode] calls the value of the variable pov-mode-hook  with no args, if that value is non-nil.
"
  (interactive)
  (kill-all-local-variables)
  (use-local-map pov-mode-map)
  (pov-setup-syntax-table)
  (make-local-variable 'font-lock-keywords)
  (make-local-variable 'comment-start)
  (make-local-variable 'comment-start-skip)
  (make-local-variable 'comment-end)
  (make-local-variable 'comment-multi-line)
  (make-local-variable 'comment-column)
  (make-local-variable 'indent-line-function)
  (make-local-variable 'tab-stop-list)
  (make-local-variable 'font-lock-defaults)

  (setq font-lock-keywords pov-font-lock-keywords)
  (setq font-lock-defaults '(pov-font-lock-keywords))
  (if (and (boundp 'running-xemacs) running-xemacs)
      (pov-toolbar))
  (if pov-imenu-in-menu
      (pov-helper-imenu-setup))

  ;; Create and show the insert menu
  (pov-im-make-menu)
  (easy-menu-add pov-im-menu)

  (set-syntax-table pov-mode-syntax-table)
  (setq comment-start "// "
	comment-start-skip "/\\*+ *\\|// *"
	comment-end ""
	comment-multi-line nil
	comment-column 60
	indent-line-function 'pov-indent-line
	tab-stop-list pov-tab-stop-list)
  (setq mode-name "PoV")
  (setq major-mode 'pov-mode)
  (run-hooks 'pov-mode-hook)
)

(defun pov-tab ()
  "Command assigned to the TAB key in PoV mode."
  (interactive)
  (if (save-excursion (skip-chars-backward " \t") (bolp))
      (pov-indent-line)
    (save-excursion
      (pov-indent-line))))

(defun pov-indent-line nil
  "Indents a line of PoV code."
  (interactive)
  (beginning-of-line)
  (delete-horizontal-space)
  (if (pov-top-level-p)
      (pov-indent-top-level)
    (if (not (pov-top-level-p))
	(if (pov-in-star-comment-p)
	    (indent-to '2)
	  (if (and (< (point) (point-max))
		   (or
		    (eq ?\) (char-syntax (char-after (point))))
		    (or
		     (looking-at "\\<#\\(end\\|break\\)\\>")
		     (and (looking-at "\\<#else\\>")
			  (not (pov-in-switch-p 0))))))
	      (pov-indent-close)                ; indent close-delimiter
	    (pov-indent-in-block))))))  ; indent line after open delimiter

(defun pov-newline nil
  "Terminate line and indent next line."
  (interactive)
  (newline)
  (pov-indent-line))

(defun pov-in-star-comment-p nil
  "Return true if in a star comment"
  (let ((state
	 (save-excursion
	   (parse-partial-sexp (point-min) (point)))))
    (nth 4 state)))

(defun pov-open nil
  (interactive)
  (insert last-command-char))

(defun pov-close nil
  "Inserts and indents a close delimiter."
  (interactive)
  (insert last-command-char)
  (backward-char 1)
  (pov-indent-close)
  (forward-char 1)
  (blink-matching-open))

(defun pov-indent-close nil
  "Internal function to indent a line containing a close delimiter."
  (if (save-excursion (skip-chars-backward " \t") (bolp))
      (let (x (oldpoint (point)))
	(if (looking-at "#end\\|#else\\|#break")
	    (progn
	      (goto-char (pov-find-begin 0))
	      (if (and (looking-at "#else")
		       (pov-in-switch-p 0))
		  (goto-char (pov-find-begin 0))))
	  (forward-char) (backward-sexp))       ;XXX
	(if (and (eq 1 (count-lines (point) oldpoint))
		 (> 1 (- oldpoint (point))))
	    (goto-char oldpoint)
	  (beginning-of-line)
	  (skip-chars-forward " \t")
	  (setq x (current-column))
	  (goto-char oldpoint)
	  (delete-horizontal-space)
	  (indent-to x)))))

(defun pov-indent-in-block nil
  "Indent a line which does not open or close a block."
  (let ((goal (pov-block-start)))
    (setq goal (save-excursion
		 (goto-char goal)
		 (back-to-indentation)
		 (if (bolp)
		     pov-indent-level
		   (back-to-indentation)
		   (+ (current-column) pov-indent-level))))
    (indent-to goal)))

(defun pov-indent-top-level nil
  (if (save-excursion 
	(forward-line -1)
	(looking-at "\\<#declare[ \t]+[0-9a-zA-Z_]+[ \t]*=[ \t]*$"))
      (indent-to pov-indent-under-declare)))

;;; returns nil if at top-level, or char pos of beginning of current block

(defun pov-block-start nil
  "Returns the character position of the character following the nearest
enclosing `{' or `begin' keyword."
  (save-excursion
    (let (open (skip 0))
      (setq open (condition-case nil
		     (save-excursion
		       (backward-up-list 1)
		       (1+ (point)))
		   (error nil)))
      (pov-find-begin open))))

(defun pov-find-begin (start)
  "Search backwards from point to START for enclosing `begin' and returns the
character number of the character following `begin' or START if not found."
  (save-excursion
    (let ((depth 1) match)
      (while (and (> depth 0)
		  (pov-re-search-backward pov-begin-end-re start t))
	(setq depth (if (looking-at pov-end-re)
			(if (and (looking-at "#end")
				 (pov-in-switch-p start))
			    (progn
			      (pov-re-search-backward "\\<#switch\\>" start t)
			      depth)
			  (+ 1 depth))
		      (if (looking-at "\\<#else\\>")
			  (if (pov-in-switch-p start)
			      (1- depth)
			    depth)
			(1- depth)))))
      (if (not (eq 0 depth))
	  start
	(point)))))

(defun pov-in-switch-p (start)
  "Return t if one level under a switch."
  (save-excursion
    (if (looking-at "\\<#end\\>")
	(pov-re-search-backward pov-begin-end-re start t))
    (beginning-of-line)
    (pov-re-search-backward pov-begin-end-re start t)
    (if (looking-at "\\<#else\\>>") (forward-word -1))
    (while (looking-at "\\<#break\\>")
      (progn
	(pov-re-search-backward "\\<#case\\|#range\\>" start t)
	(pov-re-search-backward pov-begin-end-re start t)))
    (pov-re-search-backward pov-begin-end-re start t)
    (looking-at "\\<#switch\\>")))

(defun pov-top-level-p nil
  "Awful test to see whether we are inside some sort of PoVray block."
  (and (condition-case nil
	   (not (scan-lists (point) -1 1))
	 (error t))
       (not (pov-find-begin nil))))

(defsubst pov-re-search-backward (REGEXP BOUND NOERROR)
  "Like re-search-backward, but skips over matches in comments or strings"
  (set-match-data '(nil nil))
  (while (and
	  (re-search-backward REGEXP BOUND NOERROR)
	  (pov-skip-backward-comment-or-string)
	  (not (set-match-data '(nil nil))))
    ())
  (match-end 0))

(defun pov-autoindent-endblock nil
  "Hack to automatically reindent end, break, and else."
  (interactive)
  (self-insert-command 1)
  (save-excursion
    (forward-word -1)
    (if (looking-at "\\<#else\\|#end\\|#break\\>")
	(pov-indent-line))))

; Taken from verilog-mode.el
(defun pov-skip-backward-comment-or-string ()
  "Return true if in a string or comment"
  (let ((state
	 (save-excursion
	   (parse-partial-sexp (point-min) (point)))))
    (cond
     ((nth 3 state)                      ;Inside string
      (search-backward "\"")
      t)
     ((nth 7 state)                      ;Inside // comment
      (search-backward "//")
      t)
     ((nth 4 state)                      ;Inside /* */ comment
      (search-backward "/*")
      t)
     (t
      nil))))

; *******************
; *** Completions ***
; *******************
;; -------------------------------------------------------------------
;; C.H.: adapted completion to POV-Ray 3.5 syntax to some extent
;; -------------------------------------------------------------------
(defvar pov-completion-str nil)
(defvar pov-completion-all nil)
(defvar pov-completion-pred nil)
;(defvar pov-completion-buffer-to-use nil)
(defvar pov-completion-flag nil)

(defvar pov-global-keywords
  '("#break" "#case" "#debug" "#declare" "#default" "#else" "#end" "#fclose" "#fopen" "#include" "#local" 
    "#macro" "#read" "#render" "#statistics" "#switch" "#undef" "#version" "#warning" "#write"))

(defvar pov-top-level-keywords
  '("global_settings" "camera" "light_source" "light_group" "media" "background" "sky_sphere" "photons" "rainbow"))

(defvar pov-csg-scope-re 
  "\\<inverse\\|union\\|intersection\\|difference\\|merge\\>")

(defvar pov-solid-primitive-keywords
  '("blob" "box" "cone" "cylinder" "height_field" "julia_fractal" "lathe" "object" "prism" "sphere" 
    "sphere_sweep" "superellipsoid" "sor" "text" "torus" "isosurface" "parametric"))

(defvar pov-blob-keywords
  '("threshold" "cylinder" "sphere" "component" "hierarchy" "sturm"))

(defvar pov-heightfield-keywords
  '("hierarchy" "smooth" "water_level"))

(defvar pob-isosurface-keywords
  '("accuracy" "all_intersections" "contained_by" "evaluate" "function" "max_gradient" "max_trace" "method" 
    "open" "threshold"))

(defvar pov-juliafractal-keywords
  '("max_iteration" "precision" "slice" "quaternion" "hypercomplex" "slice"))

(defvar pov-prism-keywords
  '("linear_sweep" "conic_sweep" "linear_spline" "quadratic_spline" "cubic_spline" "bezier_spline" "sturm"))

(defvar pov-patch-primitive-keywords
  '("bicubic_patch" "disc" "smooth_triangle" "triangle" "polygon" "mesh" "mesh2"))

(defvar pov-bicubic-keywords
  '("type" "flatness" "u_steps" "v_steps"))

;defvar pov-bezier-keywords
; '("accuracy" "rational" "trimmed_by"))

(defvar pov-infinite-solid-keywords
  '("plane" "cubic" "poly" "quadric" "quartic"))

(defvar pov-csg-keywords
  '("inverse" "union" "intersection" "difference" "merge" "split_union"))

(defvar pov-light-source-keywords
  '("color" "spotlight" "point_at" "radius" "falloff" "tightness" "area_light" "adaptive" "jitter" "looks_like"
    "shadowless" "cylinder" "fade_distance" "fade_power" "media_attenuation" "media_interaction" "rgb" 
    "circular" "orient" "groups" "parallel"))

(defvar pov-object-modifier-keywords
  '("clipped_by" "bounded_by" "hollow" "no_shadow" "no_reflection" "no_image" "interior_texture"))

(defvar pov-transformation-keywords
  '("rotate" "scale" "translate" "matrix" "transform"))

(defvar pov-camera-keywords
  '("perspective" "orthographic" "fisheye" "ultra_wide_angle" "omnimax" "panoramic" "cylinder" "spherical" 
    "location" "look_at" "right" "up" "direction" "sky" "sphere" "spherical_camera" "h_angle" "v_angle" "angle" 
    "blur_samples" "aperture" "focal_point" "normal" "rotate" "translate"))

(defvar pov-texture-keywords
  '("pigment" "normal" "finish" "halo" "texture_map" "material_map" "boxed" "planar" "cylindrical" "spherical"))

;(defvar pov-pigment-keywords
;  '("colour" "boxed" "brick" "checker" "cylindrical" "hexagon" "color_map" "gradient" "pigment_map" "pigment" "planar" "spherical" "image_map" "quick_color" "rgb"))
(defvar pov-pigment-keywords
  '("color" "colour" "colour_map" "color_map" "pigment_map" "pigment" "image_map" "quick_color"))

(defvar pov-normal-keywords
  '("slope_map" "normal_map" "bump_map" "bump_size" "boxed" "cylindrical" "planar" "spherical"))

(defvar pov-finish-keywords
  '("ambient" "diffuse" "brilliance" "phong" "phong_size" "specular" "roughness" "metallic" "reflection" "irid" 
    "crand"))
;; "refraction" "ior" "caustics" "fade_distance" "fade_power" ;;povray3.0

(defvar pov-reflection-keywords
  '("fresnel" "falloff" "exponent" "metallic" ))

(defvar pov-irid-keywords
  '("thickness" "turbulence"))

;(defvar pov-pattern-keywords
;  '("agate" "average" "boxed" "bozo" "brick" "bumps" "checker" "color" "crackle" "cylindrical" "density_file" "dents" "gradient" "granite" "hexagon" "leopard" "mandel" "marble" "onion" "planar" "pattern1" "pattern2" "pattern3" "quilted" "radial" "ripples" "spherical" "spiral1" "spiral2" "spotted" "waves" "wood" "wrinkles" "image_map" "bump_map" ))
(defvar pov-pattern-keywords
  '("agate" "average" "boxed" "bozo" "brick" "bumps" "cells" "checker" "crackle" "cylindrical" "density_file" 
    "dents" "julia" "mandel" "magnet" "function" "gradient" "granite" "hexagon" "image_pattern" "leopard" 
    "marble" "object" "onion" "pigment_pattern" "planar" "quilted" "radial" "ripples" "slope" "spherical" 
    "spiral1" "spiral2" "spotted" "wood" "waves" "wrinkles" "frequency" "phase" "ramp_wave" "triangle_wave" 
    "sine_wave" "scallop_wave" "cubic_wave" "poly_wave" "noise_generator" "turbulence" "octaves" "omega" 
    "lambda" "warp"))

(defvar pov-media-keywords
  '("intervals" "samples" "confidence" "variance" "ratio" "absorption" "emission" "scattering" "density" 
    "color_map" "density_map" "light_group" "sample_method" "aa_level" "aa_threshold" "jitter" "method"))

(defvar pov-interior-keywords
  '("ior" "caustics" "fade_distance" "fade_power" "media" "dispersion" "dispersion_samples"  "fade_color"))

(defvar pov-texture-keywords
  '("pigment" "normal" "finish" "texture_map" "material_map"))

(defvar pov-material-keywords
  '("texture" "interior"))

(defvar pov-warp-keywords
  '("repeat" "black_hole" "turbulence" "cylindrical" "spherical" "toroidal" "planar" "orientation" "dist_exp" 
    "major_radius" "offset" "flip" "strength" "falloff" "inverse"))

(defvar pov-density-keyword
  '("colour" "colour_map" "boxed" "planar" "cylindrical" "spherical"))

(defvar pov-fog-keywords
 '("fog_type" "distance" "color" "turbulence" "turb_depth" "omega" "lambda" "octaves" "fog_offset" "fog_alt" 
   "up"))

(defvar pov-rainbow-keywords
 '("direction" "angle" "width" "distance" "jitter" "up" "arc_angle" "falloff_angle"))

(defvar pov-global-settings-keywords
  '("adc_bailout" "ambient_light" "assumed_gamma" "charset" "hf_gray_16" "irid_wavelength" "max_intersections" 
    "max_trace_level" "number_of_waves" "radiosity" "reflection_samples" "photons" "noise_generator"))

(defvar pov-radiosity-keywords
  '("adc_bailout" "always_sample" "brightness" "count" "distance_maximum" "error_bound" "gray_threshold" 
    "low_error_factor" "minimum_reuse" "nearest_count" "recursion_limit" "max_sample" "media" "normal" 
    "pretrace_end" "pretrace_start" "recursion_limit" "save_file"))

(defvar pov-object-keywords
 '("texture" "pigment" "finish" "interior" "normal" "no_shadow"))

;; Povray3.0
;;(defvar pov-atmosphere-keywords
;;  '("type" "distance" "scattering" "eccentricity" "samples" "jitter" "aa_threshold" "aa_level" "colour" "color"))

;AS: halo is no longer existent in pov 3.1 so we won't need that
;(defvar pov-halo-keywords
;  '("attenuating" "emitting" "glowing" "dust" "constant" "linear" "cubic" "poly" "planar_mapping" "spherical_mapping" "cylindrical_mapping" "box_mapping" "dust_type" "eccentricity" "max_value" "exponent" "samples" "aa_level" "aa_threshold" "jitter" "turbulence" "octaves" "omega" "lambda" "colour_map" "frequency" "phase" "scale" "rotate" "translate"))


;;AS
(defvar pov-keyword-completion-alist
  (mapcar (function
	   (lambda (item) (list item item)))
	   (append 
	    pov-global-keywords
	    pov-top-level-keywords
	    pov-solid-primitive-keywords
	    pov-blob-keywords
	    pov-heightfield-keywords
	    pov-juliafractal-keywords
	    pov-prism-keywords
	    pov-patch-primitive-keywords
	    pov-bicubic-keywords
	    pov-infinite-solid-keywords
	    pov-csg-keywords
	    pov-light-source-keywords
	    pov-object-modifier-keywords
	    pov-transformation-keywords
	    pov-camera-keywords
	    pov-texture-keywords
	    pov-pigment-keywords
	    pov-normal-keywords
	    pov-finish-keywords
	    pov-reflection-keywords
	    pov-irid-keywords
	    pov-pattern-keywords
	    pov-pattern-keywords
	    pov-media-keywords
	    pov-interior-keywords
	    pov-texture-keywords
	    pov-material-keywords
	    pov-warp-keywords
	    pov-fog-keywords
	    pov-rainbow-keywords
	    pov-global-settings-keywords
	    pov-radiosity-keywords
	    pov-object-keywords
	    )))

;pov-media-keywords
;	   pov-bicubic-keywords
;		   pov-normal-keywords
;		   pov-blob-keywords
;		   pov-object-keywords
;		   pov-camera-keywords
;		   pov-pattern-keywords
;		   pov-csg-keywords
;		   pov-pigment-keywords
;		   pov-density-keyword
;		   pov-prism-keywords
;		   pov-finish-keywords
;		   pov-radiosity-keywords
;		   pov-fog-keywords
;		   pov-texture-keywords
;		   pov-heightfield-keywords
;		   pov-global-keywords)))
;	 pov-atmosphere-keywords
;pov-halo-keywords

(defun pov-string-diff (str1 str2)
  "Return index of first letter where STR1 and STR2 differs."
  (catch 'done
    (let ((diff 0))
      (while t
	(if (or (> (1+ diff) (length str1))
		(> (1+ diff) (length str2)))
	    (throw 'done diff))
	(or (equal (aref str1 diff) (aref str2 diff))
	    (throw 'done diff))
	(setq diff (1+ diff))))))

(defun pov-get-scope nil
  "Return the scope of the POV source at point"
  (interactive)
  (save-excursion
    (if (not (pov-top-level-p))
	(progn
	  (backward-up-list 1)
	  (forward-word -1)
	  (cond
	   ((looking-at "camera")
	    (setq pov-completion-list pov-camera-keywords))
	   ((looking-at "texture")
	    (setq pov-completion-list (append pov-texture-keywords pov-pattern-keywords)))
	   ((looking-at "material")
	    (setq pov-completion-list (append pov-material-keywords pov-pattern-keywords)))
	   ((looking-at "pigment")
	    (setq pov-completion-list (append pov-pigment-keywords pov-pattern-keywords)))
	   ((looking-at "normal")
	    (setq pov-completion-list (append pov-normal-keywords pov-pattern-keywords)))
	   ((looking-at "density")
	    (setq pov-completion-list (append pov-density-keywords pov-pattern-keywords)))
	   ((looking-at "finish")
	    (setq pov-completion-list pov-finish-keywords))
	   ((looking-at "warp")
	    (setq pov-completion-list pov-warp-keywords))
	   ((looking-at "finish")
	    (setq pov-completion-list pov-finish-keywords))
	   ((looking-at "reflection")
	    (setq pov-completion-list pov-reflection-keywords))
	   ((looking-at "irid")
	    (setq pov-completion-list pov-irid-keywords))
	   ((looking-at "blob")
	    (setq pov-completion-list pov-blob-keywords))
	   ((looking-at "isosurface")
	    (setq pov-completion-list pov-isosurface-keywords))
	   ((looking-at "heightfield")
	    (setq pov-completion-list pov-heightfield-keywords))
	   ((looking-at "prism")
	    (setq pov-completion-list pov-prism-keywords))
	   ((looking-at "julia_fractal")
	    (setq pov-completion-list pov-juliafractal-keywords))
	   ((looking-at "bicubic")
	    (setq pov-completion-list pov-bicubic-keywords))
	   ((looking-at "bezier")
	    (setq pov-completion-list pov-bezier-keywords))
	   ((looking-at "trimmed_by")
	    (setq pov-completion-list pov-bezier-keywords))
	   ((looking-at "light_source")
	    (setq pov-completion-list pov-light-source-keywords))
	   ((looking-at "interior")
	    (setq pov-completion-list pov-interior-keywords))
	   ((looking-at "media")
	    (setq pov-completion-list pov-media-keywords))
	   ((looking-at "fog")
	    (setq pov-completion-list pov-fog-keywords))
	   ((looking-at "global_settings")
	    (setq pov-completion-list pov-global-settings-keywords ))
	   ((looking-at "radiosity")
	    (setq pov-completion-list pov-radiosity-keywords))
	   ((looking-at "photons")
	    (setq pov-completion-list pov-photons-keywords))
	   ((looking-at pov-csg-scope-re)
	    (setq pov-completion-list (append pov-solid-primitive-keywords pov-infinite-solid-keywords pov-object-modifier-keywords pov-csg-keywords)))
	   (t
	    (setq pov-completion-list (append pov-object-modifier-keywords pov-object-keywords))))
	  (setq pov-completion-list (append pov-completion-list pov-transformation-keywords)))
      (setq pov-completion-list (append pov-top-level-keywords pov-solid-primitive-keywords pov-infinite-solid-keywords pov-patch-primitive-keywords pov-csg-keywords)))
    ;Append the language directives so that they are available at all places.
    (setq pov-completion-list (append pov-completion-list pov-global-keywords))))

(defun pov-completion (pov-completion-str pov-completion-pred pov-completion-flag)
  (save-excursion
    (let ((pov-completion-all nil))
      (pov-get-scope)
      (mapcar '(lambda (s)
		 (if (string-match (concat "\\<" pov-completion-str) s)
		     (setq pov-completion-all (cons s pov-completion-all))))
	      pov-completion-list)
      ;; Now we have built a list of all matches. Give response to caller
      (pov-completion-response))))

(defun pov-completion-response ()
  (cond ((or (equal pov-completion-flag 'lambda) (null pov-completion-flag))
	 ;; This was not called by all-completions
	 (if (null pov-completion-all)
	     ;; Return nil if there was no matching label
	     nil
	   ;; Get longest string common in the labels
	   (let* ((elm (cdr pov-completion-all))
		  (match (car pov-completion-all))
		  (min (length match))
		  tmp)
	     (if (string= match pov-completion-str)
		 ;; Return t if first match was an exact match
		 (setq match t)
	       (while (not (null elm))
		 ;; Find longest common string
		 (if (< (setq tmp (pov-string-diff match (car elm))) min)
		     (progn
		       (setq min tmp)
		       (setq match (substring match 0 min))))
		 ;; Terminate with match=t if this is an exact match
		 (if (string= (car elm) pov-completion-str)
		     (progn
		       (setq match t)
		       (setq elm nil))
		   (setq elm (cdr elm)))))
	     ;; If this is a test just for exact match, return nil ot t
	     (if (and (equal pov-completion-flag 'lambda) (not (equal match 't)))
		 nil
	       match))))
	;; If flag is t, this was called by all-completions. Return
	;; list of all possible completions
	(pov-completion-flag
	 pov-completion-all)))

(defun pov-complete-word ()
  "Complete word at current point based on POV syntax."
  (interactive)
  (let* ((b (save-excursion (skip-chars-backward "a-zA-Z0-9#_") (point)))
	 (e (save-excursion (skip-chars-forward "a-zA-Z0-9#_") (point)))
	 (pov-completion-str (buffer-substring b e))
	 ;; The following variable is used in pov-completion
	 ;(pov-buffer-to-use (current-buffer))
	 (allcomp (all-completions pov-completion-str 'pov-completion))
	 (match (try-completion
		 pov-completion-str (mapcar '(lambda (elm)
					       (cons elm 0)) allcomp))))
    ;; Delete old string
    (delete-region b e)
    ;; Insert match if found, or the original string if no match
    (if (or (null match) (equal match 't))
	(progn (insert "" pov-completion-str)
	       (message "(No match)"))
      (insert "" match))
    ;; Give message about current status of completion
    (cond ((equal match 't)
	   (if (not (null (cdr allcomp)))
	       (message "(Complete but not unique)")
	     (message "(Sole completion)")))
	  ;; Display buffer if the current completion didn't help
	  ;; on completing the label.
	  ((and (not (null (cdr allcomp))) (= (length pov-completion-str)
					      (length match)))
	   (with-output-to-temp-buffer "*Completions*"
	     (display-completion-list allcomp))
	   ;; Wait for a keypress. Then delete *Completion*  window
	   (momentary-string-display "" (point))
	   (delete-window (get-buffer-window (get-buffer "*Completions*")))))))


;;; initialize the keymap if it doesn't already exist
(if (null pov-mode-map)
    (progn
      (setq pov-mode-map (make-sparse-keymap))
      (define-key pov-mode-map "{" 'pov-open)
      (define-key pov-mode-map "}" 'pov-close)
      (define-key pov-mode-map "\t" 'pov-tab)
      (define-key pov-mode-map "\r" 'pov-newline)
      (define-key pov-mode-map "\C-c\C-c" 'pov-command-query) ;AS
      (define-key pov-mode-map [(shift f1)] 'pov-keyword-help) ;AS
      (define-key pov-mode-map "\C-c\C-l" 'pov-show-render-output) ;AS
      (define-key pov-mode-map "\C-ci" 'pov-open-include-file)
      (define-key pov-mode-map "\M-\t" 'pov-complete-word)))

;; Hack to redindent end/else/break
(if pov-autoindent-endblocks
    (progn
      (define-key pov-mode-map "e" 'pov-autoindent-endblock)
      (define-key pov-mode-map "k" 'pov-autoindent-endblock)
      (define-key pov-mode-map "d" 'pov-autoindent-endblock)))

; ***********************
; *** povkeyword help ***
; ***********************
(defun pov-keyword-help nil
  (interactive)
  "look up the appropriate place for keyword in the POV documentation"
  "keyword can be entered and autocompleteted, default is word at point /AS"
  (let* ((default (current-word))
	 (input (completing-read
		 (format "lookup keyword (default %s): " default)
		 pov-keyword-completion-alist))
	 (kw (if (equal input "")
		 default
	       input)))
    (get-buffer-create pov-doc-buffer-name)
    (switch-to-buffer-other-window pov-doc-buffer-name)
    (find-file-read-only (concat pov-home-dir pov-help-file))
    ;;Try to look up a keyword in the povray-documentation:
    ;;uses a heuristic to find the appropriate entry
    ;;since the povray-docu is formatted rather arbitrarily
    ;;try:
    (cond
     ((progn
       (goto-char (point-min))
       (search-forward-regexp
	;;first: the language description is in section four, so look for:
	(concat
	 "^4\\.[0-9]+\\(\\.[0-9]+\\)?\\(\\.[0-9]+\\)?\\(\\.[0-9]+\\)?[ 	]+"
	 ;;change light_source -> light_source OR light source (that's
	 ;;the usual spelling in the headings)
	 ;;(wouldn't a working replace-in-string be nice, even for
	 ;;FSF-emacs ???)
	 (if (string-match "\\(.*\\)_\\(.*\\)" kw)
	     (concat (match-string 1 kw)
		     "[_ 	]"
		     (match-string 2 kw)
		     ".*\\>$")
	   kw))
	nil t))			;return nil if not found
       ;; make the line of the match the top line of screen XXX
       (recenter 0))

     ;;second: if that didn't work:
     ;;same again with a relaxed regexp that allows more matches:
     ((progn
	(goto-char (point-min))
	(search-forward-regexp
	 (concat
	  "^4\\.[0-9]+\\(\\.[0-9]+\\)?\\(\\.[0-9]+\\)?\\(\\.[0-9]+\\)?[ 	]+.*"
	  (if (string-match "\\(.*\\)_\\(.*\\)" kw)
	      (concat
	       (match-string 1 kw)
	       "[_ 	]"
	       (match-string 2 kw))
	    kw))
	 nil t))
      (recenter 0))
     ;;third try:
     ;;syntactic definitions appear like this: "KEYWORD:"
     ((progn
	(goto-char (point-min))
	(search-forward-regexp
	 (concat "\\<" (upcase kw) ":")
	 nil t)))
      ;;last try: simply search keyword from beginning of buffer
     ((progn
       (goto-char (point-min))
       (while (y-or-n-p (concat "Continue to look for " kw))
	 (search-forward-regexp
	  (concat  "\\<" kw  "\\>")
	  nil t))))
     ;;OK, that's it: we failed
     (t (error (concat "Couldn't find keyword: " kw
		      ", maybe you misspelled it?"))))
    ))

; **********************************
; *** Open standard include file ***
; **********************************
(defun pov-open-include-file nil
  (interactive)
  "Open one of the standard include files"
  (let* ((default (current-word))
	 (input (completing-read
		 (format "File to open (default %s): " default)
		 pov-keyword-completion-alist))
	 (kw (if (equal input "")
		 default
	       input)))
    ;(get-buffer-create kw)
    ;(switch-to-buffer-other-window kw)
    ;(message (concat pov-include-dir (concat kw ".inc")))
    (find-file-read-only (concat pov-include-dir (concat kw ".inc")))
))

; ***************************
; *** Commands for povray ***
; ***************************

;;; Execution of Povray and View processes
(defvar pov-next-default-command "Render" ;XXX
  "The default command to run next time pov-command-query is run")
(defvar pov-last-render-command "Render" ;XXX
  "The last command used to render a scene")
(defvar pov-rendered-succesfully nil
  "Whether the last rendering completed without errors")
(defvar pov-doc-buffer-name "*Povray Doc*"
  "The name of the buffer in which the documentation will be displayed")
;; will be set to *Pov Render <buffer-name>*
(defvar pov-render-buffer-name ""
  "The name of the buffer that contains the rendering output")
(defvar pov-current-render-process nil
  "The process rendering at the moment or nil")
(defvar pov-current-view-processes (make-hash-table)
  "The processes that display pictures at the moment")
(defvar pov-buffer-modified-tick-at-last-render 0
  "The number of modifications at time of last render")

;;make all the render variables buffer-local that are pov-file
;;dependent, so that users can render more than one file at the same
;;time etc.  Note: for the *view processes* a hash is used (rather
;;then making the variables local, because somebody might want to view
;;a file from a different render buffer.

(mapc 'make-variable-buffer-local
      '(pov-command-alist ;because of history XXX
	pov-next-default-command
	pov-last-render-command
	pov-image-file
	pov-render-buffer-name
	pov-buffer-modified-tick-at-last-render
	pov-current-render-process))

(defvar pov-image-file ""
  "The name of the rendered image that should be displayed"
  )

(defun pov-default-view-command ()
  "Return the default view command (internal or external)"
  (if pov-default-view-internal
      pov-internal-view
    pov-external-view))

(defun pov-command-query () ;XXX
  "Query the user which command to execute"
  ;;XXX this one is still a mess
  (interactive)
  ;;Check whether the buffer has been modified since last call,
  ;;and the last rendering was succesful. If so he probably
  ;;wants to render, otherwise he wants to view.
  (let* ((default
	   (if (and (= (buffer-modified-tick)
		       pov-buffer-modified-tick-at-last-render)
		    pov-rendered-succesfully)
	       (pov-default-view-command)
	     pov-last-render-command))
	 (completion-ignore-case t)
	 (pov-command (completing-read
		       (format "Which command (default: %s)? " default)
		       pov-command-alist nil t nil t)))
    (setq pov-command
	  (if (not (string-equal pov-command ""))
	      pov-command
	    default))
    (setq pov-next-default-command pov-command)
  ;;XXX argl: all this information should be in pov-command-alist
  (cond ((string-match pov-command pov-internal-view)
	 (pov-display-image-xemacs pov-image-file)) ;XXX
	((string-match pov-command pov-external-view)
	 (pov-display-image-externally pov-image-file t))
	(t
	   (setq pov-buffer-modified-tick-at-last-render
		 (buffer-modified-tick))
	;   (message (format
	;	     "DEBUG: buffer %s modified tick%d "
	;	     (buffer-name)
	;	     (buffer-modified-tick)))
	   (pov-render-file pov-command (buffer-file-name) t)
	   ))))

(defun pov-render-file (pov-command file verify-render)
  "Render a file using pov-command."
  ;;XXX Check that there isn't already a render running
  (when
      (or
       (not pov-current-render-process)
       (and pov-current-render-process
	    (cond ((y-or-n-p
		    ;;XXX could theoretically be also running in other buffer...
		    "There is a render process already running: abort it?")
		   (kill-process pov-current-render-process)
		   (message "Process killed")
		   t)
		  )))
    (let ((render-command nil)
	  (render-command-options nil)
	  (render-command-history nil)
	  (old-buffer (current-buffer))
	  (process nil))

      ;; if the user hasn't saved his pov-file, ask him
    (if (buffer-modified-p)
	(and (y-or-n-p
	      (concat (buffer-name (current-buffer)) " modified; save ? "))
	     (save-buffer)))
    ;; assign the buffer local value of the render buffer name
    (setq pov-render-buffer-name (format "*Povray Render %s*" file))
    (set-buffer (get-buffer-create pov-render-buffer-name))
    ;(switch-to-buffer (buffer-name))   % XXX use this for 2.11, and fix it
    (erase-buffer)
    (setq render-command (second (assoc pov-command pov-command-alist)))
    (setq render-command-options (format
				  (third (assoc pov-command pov-command-alist))
				  file))
    (setq render-command-history
	  (fourth (assoc pov-command pov-command-alist)))
    ;(message (format "DEBUG FUCK %s %s"render-command-options (or
    ;		render-command-history "NIL")))
    (if verify-render
	 (setq render-command-options
	       (read-string "Render with the following options: "
			    render-command-options
			    'render-command-history)))
    (message (format "Running %s on %s" pov-command file))
    (insert (format "Running %s on %s with: %s %s..." pov-command file
		    render-command  render-command-options))

    (setq process (apply 'start-process pov-command (current-buffer)
			 render-command
			 (split-string render-command-options)))
    ;; memorize what we are doing
    (setq pov-last-render-command pov-command)
    ;; FIXME this might be dubious
    (setf (fourth (assoc pov-command pov-command-alist))
	  render-command-history)
    ;;(message (format "DEBUG proc: %s" process))
    ;;XXX 'coz pov-current-render-process is buffer-local
    ;(get-buffer old-buffer)
    (set-buffer old-buffer)
    (setq pov-current-render-process process)
    (set-process-filter process 'pov-render-filter)
    (set-process-sentinel process 'pov-render-sentinel))))

(defun pov-show-render-output ()
  "Pop up the output of the last render command."
  (interactive)
  (let ((buffer (get-buffer pov-render-buffer-name)))
    (if buffer
	(let ((old-buffer (current-buffer)))
	  (pop-to-buffer buffer t)
	  (bury-buffer buffer)
	  (goto-char (point-max))
	  (pop-to-buffer old-buffer))
      (error "No rendering done so far"))))

(defun pov-render-sentinel (process event)
 "Sentinel for povray call."
 ;;so we aren't rendering any more ;XXX
 (setq pov-current-render-process nil)
 ;;If the process exists successfully then kill the ouput buffer
 (cond ((equal 0 (process-exit-status process))
	(setq pov-rendered-succesfully t)
	(message "Image rendered succesfully"))
       (t
	(message (concat "Errors in " (process-name process)
			", press C-c C-l to display"))
	(setq pov-rendered-succesfully nil))))


(defun pov-render-filter (process string)
  "Filter to process povray output. Scrolls and extracts the
filename of the output image (XXX with a horrible buffer-local-hack...)"
  ;(message (format "DEBUG buffer name %s" (buffer-name (current-buffer))))
  (let ((image-file nil))
    (save-excursion
      (set-buffer (process-buffer process))
      (save-excursion
	;; find out how our file is called
	(if (string-match "^ *Output file: \\(.*\\), [0-9]+ bpp .+$" string)
	    (setq image-file (match-string 1 string)))
	(goto-char (process-mark process))
	(insert-before-markers string)
	(set-marker (process-mark process) (point))))
    (if image-file  (setq pov-image-file image-file))))

(defun pov-external-view-sentinel (process event)
  ;;seems like we finished viewing => remove process from hash
  (cl-remhash (process-name process) pov-current-view-processes)
  (if (equal 0 (process-exit-status process))
      (message (concat "view completed successfully")) ;XXX
    (message (format "view exit status %d"
		     (process-exit-status process)))))

(defun pov-display-image-externally (file verify-display)
  "Display the rendered image using external viewer"
  ;;if we don't have a file, prompt for one
  (when (or (not file) (string-equal file ""))
    (setq file
	  (read-file-name "Which image file should I display? ")))
  (let ((view-command nil)
	(view-options nil)
	(view-history nil)
	(other-view (cl-gethash (concat pov-external-view file) 
				pov-current-view-processes))
	(process nil))
    (if (and other-view (processp other-view))  ;external
	(if (not (y-or-n-p
		  (format "Do yo want to want to kill the old view of %s?" file)))
	    (kill-process other-view)))
    (setq view-command (second (assoc pov-external-view pov-command-alist)))
    (setq view-options (format
			(third (assoc pov-external-view pov-command-alist))
			file))
    (setq view-history (fourth (assoc pov-external-view pov-command-alist)))
    (if verify-display 
	(setq view-options (read-string "View with the following options: "
					view-options
					view-history)))
    (message (format "Viewing %s with %s %s" file view-command view-options))
    (setq process (apply 'start-process (concat pov-external-view file) nil
			 view-command (split-string view-options)))
    ;;; remember what we have done
    (cl-puthash (process-name process) process pov-current-view-processes)
    ;; update history
    (setf (fourth (assoc pov-external-view pov-command-alist)) view-history)
    ;;Sentinel for viewer call (XXX argl, what a hack)
    (set-process-sentinel process 'pov-external-view-sentinel)))
    ;;	'(lambda (process event)

(defun pov-display-image-xemacs (file)
  "Display the rendered image in a Xemacs frame"
  ;;TODO: set frame according to image-size (seems difficult)
  (when (or (not file) (string-equal file ""))
      (setq file
	    (read-file-name "Which image file should I display? ")))
  (let ((buffer (get-buffer-create
		 (format "*Povray View %s*" file))))
    (save-excursion
      (set-buffer buffer)
      (toggle-read-only -1)
      (erase-buffer)
      (insert-file-contents file)
      (toggle-read-only 1)
      ;;this will either bring the old frame with the picture to the forground
      ;;or create a new one
      (make-frame-visible
       (or (get-frame-for-buffer (current-buffer))
	   (get-frame-for-buffer-make-new-frame (current-buffer)))))))
  ;(concat
  ; (third (assoc pov-command pov-command-alist))
  ; file

; *************
; *** Imenu ***
; *************
(defun pov-helper-imenu-setup ()
  (interactive)
  (require `imenu) ;; Make an index for imenu
  (make-local-variable imenu-create-index-function)
  (setq imenu-create-index-function `pov-helper-imenu-index)
  (imenu-add-to-menubar "PoV")
)

;; C.H.: to avoid flooding the function menu set 'pov-imenu-only-macros'
(if pov-imenu-only-macros
    (defvar imenu-pov-declare-regexp
      (concat
       "\\(#macro\\)"          ; Begin declaration
       "\\s-+"				; Whitespace
       "\\([A-Za-z_][A-Za-z_0-9]*\\)"	; Name
       ";?"                               ; A possible ; at the end
       )
      "Expression to recognize POV declares."
      )
  (defvar imenu-pov-declare-regexp
    (concat
     "#\\(declare\\|macro\\)"          ; Begin declaration
     "\\s-+"				; Whitespace
     "\\([A-Za-z_][A-Za-z_0-9]*\\)"	; Name
     )
    "Expression to recognize POV declares."
    )
  )

;(defvar imenu-pov-declare-regexp
;  (concat
;   "^[ \t]*\\<#\\(declare\\|local\\|macro\\)\\>+[ \t]?"
;   "\\([a-zA-Z0-9_*]+\\)+[ \t]?"
;   ))

(defun search-list (data-to-find list)
  (princ data-to-find)
  (message "")
  (princ list)
  (message "----")
  (cond ((null list)       nil)
	((null (car list)) (equal (car (car list)) (car data-to-find)))
	(t                 (if (equal (car (car list)) (car data-to-find))
			       (setcar list (cons (car data-to-find)
						  (cons (car list) data-to-find)))
			     (search-list data-to-find (cdr list))
			     ))
	)
  )

(defun pov-helper-imenu-index ()
  "Return an table of contents for an html buffer for use with Imenu."
  ;(message "pov-helper-imenu-index")
  (let ((space ?\ ) ; a char
	(toc-index '())
	toc-str)
    (goto-char (point-min))
    (imenu-progress-message prev-pos 0)
    ;; Search
    (save-match-data
      (while (re-search-forward imenu-pov-declare-regexp nil t)
	;(imenu-progress-message prev-pos)
	(setq toc-str (match-string 2))
	(beginning-of-line)
	(unless (search-list (cons toc-str (point)) toc-index)
	  (setq toc-index (cons (cons toc-str (point)) toc-index)))
	(end-of-line)))
    ;(imenu-progress-message prev-pos 100)
    ;(if toc-index
    ;(princ (nreverse toc-index)))))
    (nreverse toc-index)))

;;; Renderdialog
(defun pov-render-dialog ()
  "Opens a dialog to let you set the rending options"
  (interactive)
  (popup-dialog-box pov-render-dialog-desc)
  )

;; Let's try to find where the InsertMenu is located...
(setq pov-insertmenu-location
      (locate-data-directory "InsertMenu" (cons (file-name-directory
						 (locate-library "pov-mode"))
						(if font-pov-is-Emacs
						    data-directory
						  data-directory-list))))

(defun pov-im-get-submenunames ()
  (interactive)
  (pov-im-get-dirs (cddr (directory-files pov-insertmenu-location t)))
  )

(defun pov-im-get-dirs (dirs)
  (when (eq dirs nil)
    (return ()))
  (catch '--cl-block-nil--
    (if (file-directory-p (car dirs))
	(return (cons
		 (car dirs)
		 (if (eq (cdr dirs) nil)
		     nil
		   (pov-im-get-dirs (cdr dirs)))
		 ))
      (return (pov-im-get-dirs (cdr dirs)))))
  )

(defun pov-im-make-menu ()
  (easy-menu-define
   pov-im-menu
   pov-mode-map
   "The POV-Ray Insert menu"
   (cons "Insert" (pov-im-create-menu (pov-im-get-submenunames))))
  )

(defun pov-im-create-menu (dirs)
  (when (eq dirs nil)
    (return ()))
  (catch '--cl-block-nil--
    (return (cons
	     (pov-im-create-submenu (car dirs))
	     (if (eq (cdr dirs) nil)
		 nil
	       (pov-im-create-menu (cdr dirs)))
	     )))
  )

(defun pov-im-create-submenu (dir)
  (cons (substring (file-name-nondirectory dir) 5) 
	(pov-im-get-menuitems (directory-files dir t ".*txt")))
  )

(defun pov-im-get-menuitems (items)
  (when (eq items nil)
    (return nil))
  (catch '--cl-block-nil--
    (if (string-match "-.txt" (car items))
	(return (cons
		 "----"
		 (if (eq (cdr items) nil)
		     nil
		   (pov-im-get-menuitems (cdr items)))
		 ))
      (if (string-match " - " (file-name-nondirectory (car items)))
	  (return (cons
		   (vector (substring (file-name-sans-extension
				       (file-name-nondirectory (car items))) 5)
			   (list 'pov-im-include-file (car items)) t)
		   (if (eq (cdr items) nil)
		       nil
		     (pov-im-get-menuitems (cdr items)))
		   ))
	(return (cons
		 (vector (file-name-sans-extension
			  (file-name-nondirectory (car items)))
			 (list 'pov-im-include-file (car items)) t)
		 (if (eq (cdr items) nil)
		     nil
		   (pov-im-get-menuitems (cdr items)))
		 ))
	)))
  )

(defun pov-im-include-file (file)
  (insert-file-contents file)
  )

(provide 'pov-mode)
;;; pov-mode.el ends here
