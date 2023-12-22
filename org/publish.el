(require 'ox-publish)
(setq sidebar-links '(:about
					  (("About" "about.html")
					   ("Professional Work" "professional-work.html"))
					  :projects
					  (("Perseus Cluster Project" "perseus.html")
					   ("Deep Learning" "deep-learning.html"))
					  :blog
					  (("Posts" "posts.html"))))

(defun prepare-sidebar-links (sidebar-links prop)
  (apply #'concat
		 (mapcar (lambda (l)
				   (format "<li><a href=\"%s\">%s</a></li>\n"
						   (nth 1 l)
						   (nth 0 l)))
				 (plist-get sidebar-links prop))))

(setq sidebar
	  (concat
	   "<div id=\"sidebar\" class=\"sidebar\">\n"
	   "<div class=\"flex items-center mb-5\" onclick=\"location.href='/'\">\n"
	   "<img src=\"./images/horse.svg\" class=\"shadow-none h-12 rounded-none m-0\"/>\n"
	   "<span class=\"block text-2xl text-fg0 font-bold font-mono ms-2\">sawyer-p</span>\n"
	   "</div>\n"
	   "<ul>\n"
	   (prepare-sidebar-links sidebar-links :about)
	   "<hr/>\n"
	   (prepare-sidebar-links sidebar-links :projects)
	   "<hr/>\n"
	   (prepare-sidebar-links sidebar-links :blog)
	   "</ul>\n"
	   "</div>\n"))

(defun sawyer-html-src-block (src-block contents info)
  (let* ((code (org-html-format-code src-block info))
		 (lang (org-element-property :language src-block)))
	(format "<pre><code class=\"language-%s\">%s</code></pre>"
			lang
			code)))

(defun sawyer-html-inner-template (contents info)
  (concat
   contents
   (org-html-footnote-section info)))

;; Made some modifications to allow me to have an INTRO headline
;; TODO probably would be good to find a better way to hook into this
;; rather than c/p the original source code with a couple line modification
(defun sawyer-html-headline (headline contents info)
  (unless (org-element-property :footnote-section-p headline)
    (let* ((numberedp (org-export-numbered-headline-p headline info))
		   (numbers (org-export-get-headline-number headline info))
		   (level (+ (org-export-get-relative-level headline info)
                     (1- (plist-get info :html-toplevel-hlevel))))
		   (todo (and (plist-get info :with-todo-keywords)
					  (let ((todo (org-element-property :todo-keyword headline)))
                        (and todo (org-export-data todo info)))))
		   (todo-type (and todo (org-element-property :todo-type headline)))
		   (priority (and (plist-get info :with-priority)
						  (org-element-property :priority headline)))
		   (text (org-export-data (org-element-property :title headline) info))
		   (tags (and (plist-get info :with-tags)
					  (org-export-get-tags headline info)))
		   (full-text (funcall (plist-get info :html-format-headline-function)
							   todo todo-type priority text tags info))
		   (contents (or contents ""))
		   (id (org-html--reference headline info))
		   (formatted-text
			(if (plist-get info :html-self-link-headlines)
				(format "<a href=\"#%s\">%s</a>" id full-text)
			  full-text)))
	  (if (org-export-low-level-p headline info)
		  ;; This is a deep sub-tree: export it as a list item.
		  (let* ((html-type (if numberedp "ol" "ul")))
			(concat
			 (and (org-export-first-sibling-p headline info)
				  (apply #'format "<%s class=\"org-%s\">\n"
						 (make-list 2 html-type)))
			 (org-html-format-list-item
			  contents (if numberedp 'ordered 'unordered)
			  nil info nil
			  (concat (org-html--anchor id nil nil info) formatted-text)) "\n"
			 (and (org-export-last-sibling-p headline info)
				  (format "</%s>\n" html-type))))
		;; Standard headline.  Export it as a section.
        (let ((extra-class
			   (org-element-property :HTML_CONTAINER_CLASS headline))
			  (headline-class
			   (org-element-property :HTML_HEADLINE_CLASS headline))
			  (first-content (car (org-element-contents headline))))
		  (format "<%s id=\"%s\" class=\"%s\">%s%s</%s>\n"
				  (org-html--container headline info)
				  (format "outline-container-%s" id)
				  (if (string-equal formatted-text "INTRO") "intro"
					(concat (format "outline-%d" level)
							(and extra-class " ")
							extra-class))
				  (if (string-equal formatted-text "INTRO") "\n"
					(format "\n<h%d id=\"%s\"%s>%s</h%d>\n"
							level
							id
							(if (not headline-class) ""
							  (format " class=\"%s\"" headline-class))
							(concat
							 (and numberedp
                                  (format
                                   "<span class=\"section-number-%d\">%s</span> "
                                   level
                                   (concat (mapconcat #'number-to-string numbers ".") ".")))
							 formatted-text)
							level))
				  ;; When there is no section, pretend there is an
				  ;; empty one to get the correct <div
				  ;; class="outline-...> which is needed by
				  ;; `org-info.js'.
				  contents
				  (org-html--container headline info)))))))

(defun sawyer-html-template (contents info)
	(concat
	 "<!DOCTYPE html>\n"
	 "<html lang=\"en\">"
	 (sawyer-html-build-head info)
	 "<body>\n"
	 "<div class=\"content\">\n"
	 sidebar
	 "<div class=\"org-content\">\n"
	 (when (plist-get info :with-title)
       (let ((title (and (plist-get info :with-title)
						 (plist-get info :title)))
			 (subtitle (plist-get info :subtitle))
			 (html5-fancy (org-html--html5-fancy-p info)))
		 (when title
		   (if subtitle
			   (format "<h1 class=\"title\">%s</h1>\n<div class=\"subtitle\">%s</div>\n"
					   (org-export-data title info)
					   (org-export-data subtitle info) "")
			 (format "<h1 class=\"title\">%s</h1>\n"
					 (org-export-data title info))))))
	 (let ((hero (plist-get (nth 1 (nth 0 (plist-get info :hero))) :raw-link)))
	   (format "<img src=\"%s\" class=\"hero\">\n" hero))
	 (format "<div class=\"status\"><p class=\"author\">Written by <a target=\"_blank\" href=\"https://www.linkedin.com/in/sawyerhpowell/\">Sawyer Powell</a> - %s</p></div>\n"
			 (format-time-string
			  (plist-get info :html-metadata-timestamp-format)))
	 "<img src=\"./images/tiger.svg\" class=\"justify-self-center shadow-none h-12 rounded-none m-0 mb-5\"/>\n"
	 contents
	 "</div>\n"
	 (let ((depth (plist-get info :with-toc)))
       (when depth (org-html-toc depth info)))
	 "</div>\n"
	 "<div class=\"fixed bottom-10 flex space-x-3\">"
	 "<div id=\"menu-btn\" class=\"h-12 w-12 p-2 rounded-full bg-aqua text-fg flex justify-center items-center cursor-pointer shadow-lg fill-white 2xl:hidden\">"
	 "<i class=\"fa-regular fa-bars-sort fa-xl\" style=\"color:white\"></i>"
	 "</div>"
	 "<div id=\"toc-btn\" class=\"h-12 w-12 p-2 rounded-full bg-blue text-fg flex justify-center items-center cursor-pointer shadow-lg fill-white xl:hidden\"><i class=\"fa-regular fa-list-tree fa-xl\" style=\"color:white\"></i>"
	 "</div></div>"
	 "</body>\n"
	 "<script>hljs.highlightAll();</script>\n" ; Does syntax highlighting on code blocks
	 "</html>"))

(defun sawyer-html-build-head (info)
  (concat
   "<head>\n"
   (org-html--build-meta-info info)
   (org-html--build-head info)
   "<link rel=\"stylesheet\" type=\"text/css\" href=\"css/index.css\"/>\n"
   "<script defer src=\"./js/fontawesome/all.min.js\"></script>\n"
   "<link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/base16/gruvbox-light-medium.min.css\">\n"
   "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js\"></script>\n"
   "<script src=\"./js/index.js\"></script>\n"
   "<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">"
   "<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin> "
   "<link href=\"https://fonts.googleapis.com/css2?family=Fira+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&family=JetBrains+Mono:wght@400;500;600;700&family=Merriweather:ital,wght@0,400;0,700;0,900;1,400;1,700;1,900&display=swap\" rel=\"stylesheet\">"
   "</head>\n"))

;; (with-current-buffer "index.org"
;;   (org-export-to-buffer 'sawyerp-html "test_index.html"))

(org-export-define-derived-backend 'sawyer-html 'html
  :options-alist '((:hero "HERO" nil nil parse))
  :translate-alist '((src-block . sawyer-html-src-block)
					 (template . sawyer-html-template)
					 (inner-template . sawyer-html-inner-template)
					 (headline . sawyer-html-headline)))

(defun org-sawyer-html-publish-to-html (plist filename pub-dir)
  (org-publish-org-to 'sawyer-html filename
					  (concat (when (> (length org-html-extension) 0) ".")
							  (or (plist-get plist :html-extension)
								  org-html-extension
								  "html"))
					  plist pub-dir))

(setq org-publish-project-alist
	  '(("org-notes"
		 :base-directory "."
		 :base-extension "org"
		 :publishing-directory "../public_html"
		 :recursive t
		 :publishing-function org-sawyer-html-publish-to-html
		 :headline-levels 4
		 :auto-preamble t)
		("org-static"
		 :base-directory "~/org/"
		 :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
		 :publishing-directory "~/public_html/"
		 :recursive t
		 :publishing-function org-publish-attachment)
		("org" :components ("org-notes" "org-static"))))
