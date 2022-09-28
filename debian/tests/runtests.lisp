(require "asdf")

(defmacro with-writable-locations (&body body)
  `(let* ((tmpdir (uiop:getenv "AUTOPKGTEST_TMP"))
          (asdf:*user-cache* tmpdir) ; Store FASL in some temporary dir
          (*default-pathname-defaults* (parse-namestring (concatenate 'string tmpdir "/")))) ; Compile test libs in temporary directory, see cffi-tests.patch
     ,@body))

(with-writable-locations
    (asdf:load-system "cffi-tests"))

(with-writable-locations
    ;; The following is needed when executing compiled static programs
    ;; (otherwise they won't find modules such as ASDF, or won't be able to
    ;; compile them)
    (setf (uiop:getenv "SBCL_HOME") "/usr/lib/sbcl"
          (uiop:getenv "HOME") (uiop:getenv "AUTOPKGTEST_TMP"))
    ;; Can't use ASDF:TEST-SYSTEM, its return value is meaningless
    (unless (null (cffi-tests:run-all-cffi-tests))
        (uiop:quit 1)))
