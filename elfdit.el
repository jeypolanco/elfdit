(defun header-values/table-entries ()
  "For listing the fields and values of a given elf header"
  ;; This list is returned and read by the tabulated-list-entries.  In order to
  ;; have it work properly the list must be a list of list.  Each sublist is a
  ;; entry and should have the form `(ID contents)'.  Contents is a vector with
  ;; the same number fo elements as the `tabulated-list-format'.
  (require 'bindat)
  (let (decoded 
	(elf-header-spec 
	 '(("Magic" vec 4) ("Class" vec 1) ("Data" vec 1) ("Version" vec 1) 
	   ("OS/ABI" vec 1) ("ABI Version" vec 1) ("Null Pad" vec 7) ("Type" u16r) 
	   ("Machine" u16r) ("Version" u32r) ("Entry point address" vec 2 u32r) 
	   ("Start of program headers" vec 2 u32r) ("Start of section headers" vec 2 u32r)
	   ("Flags" u32r) ("Size of this header" u16r) ("Size of program headers" u16r)
	   ("Number of program headers" u16r) ("Size of section headers" u16r)
	   ("Number of section headers" u16r) ("Section header string table index" u16r))
	 )
	(num 0)
	result
	) 
    (setq decoded 
	  (bindat-unpack elf-header-spec 
			 (string-to-unibyte 
			  ;; mytest is an actual multi-byte string
			  ;; representation of a binary elf object file
			  (buffer-substring-no-properties 1 65)
			  )
			 )
	  )
    (while (< num (length decoded))
      (setq result 
	    (push (list 'nil 
			(vector 
			 (car (nth num decoded)) 
			 (prin1-to-string (cdr (nth num decoded)))))
		  result))
      (setq num (1+ num)))
    result))

(define-derived-mode elfdit-mode tabulated-list-mode "elfdit"
  "Major mode for seeing elf header fields and corresponding values."
  (setq tabulated-list-entries 'header-values/table-entries)
  (setq tabulated-list-format [("Fields" 20 nil) ("Values" 20 nil)])
  (tabulated-list-init-header)
  (tabulated-list-print))

