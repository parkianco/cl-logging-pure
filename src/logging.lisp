;;;; logging.lisp
;;;; Configurable logging implementation

(in-package #:cl-logging-pure)

;;; Log Levels

(defconstant +debug+ 0 "Debug log level.")
(defconstant +info+ 1 "Info log level.")
(defconstant +warn+ 2 "Warning log level.")
(defconstant +error+ 3 "Error log level.")
(defconstant +off+ 4 "Logging disabled.")

;;; Global Configuration

(defvar *log-level* +info+
  "Global minimum log level. Messages below this level are ignored.")

(defvar *log-output* *error-output*
  "Global log output stream.")

(defvar *log-format* "[~A] [~A] ~A: ~A~%"
  "Format string for log messages: timestamp, level, logger-name, message.")

(defvar *log-timestamp-format* :iso8601
  "Timestamp format: :iso8601, :unix, or a format string.")

;;; Logger Structure

(defstruct (logger (:constructor %make-logger))
  "A named logger with its own level and output settings."
  (name "default" :type string)
  (level nil :type (or null (integer 0 4)))
  (output nil :type (or null stream)))

(defun make-logger (name &key level output)
  "Create a new logger with NAME."
  (%make-logger :name (string name)
                :level level
                :output output))

;;; Timestamp Formatting

(defun format-timestamp (stream)
  "Write a timestamp to STREAM using *log-timestamp-format*."
  (multiple-value-bind (sec min hour day month year)
      (decode-universal-time (get-universal-time))
    (case *log-timestamp-format*
      (:iso8601
       (format stream "~4,'0D-~2,'0D-~2,'0DT~2,'0D:~2,'0D:~2,'0D"
               year month day hour min sec))
      (:unix
       (format stream "~D" (get-universal-time)))
      (otherwise
       (format stream "~4,'0D-~2,'0D-~2,'0D ~2,'0D:~2,'0D:~2,'0D"
               year month day hour min sec)))))

(defun level-name (level)
  "Return the string name for a log level."
  (case level
    (0 "DEBUG")
    (1 "INFO")
    (2 "WARN")
    (3 "ERROR")
    (otherwise "UNKNOWN")))

;;; Core Logging Function

(defun log-message (level logger-or-name format-string &rest args)
  "Log a message at LEVEL from LOGGER-OR-NAME."
  (let* ((logger (if (logger-p logger-or-name)
                     logger-or-name
                     (make-logger logger-or-name)))
         (effective-level (or (logger-level logger) *log-level*))
         (effective-output (or (logger-output logger) *log-output*)))
    (when (>= level effective-level)
      (let ((timestamp (with-output-to-string (s) (format-timestamp s)))
            (message (apply #'format nil format-string args)))
        (format effective-output *log-format*
                timestamp
                (level-name level)
                (logger-name logger)
                message)
        (force-output effective-output)))))

;;; Convenience Functions

(defun log-debug (logger-or-name format-string &rest args)
  "Log a debug message."
  (apply #'log-message +debug+ logger-or-name format-string args))

(defun log-info (logger-or-name format-string &rest args)
  "Log an info message."
  (apply #'log-message +info+ logger-or-name format-string args))

(defun log-warn (logger-or-name format-string &rest args)
  "Log a warning message."
  (apply #'log-message +warn+ logger-or-name format-string args))

(defun log-error (logger-or-name format-string &rest args)
  "Log an error message."
  (apply #'log-message +error+ logger-or-name format-string args))

;;; Context Macros

(defmacro with-logging ((&key level output) &body body)
  "Execute BODY with modified logging configuration."
  `(let (,@(when level `((*log-level* ,level)))
         ,@(when output `((*log-output* ,output))))
     ,@body))

(defmacro with-log-level (level &body body)
  "Execute BODY with a specific log level."
  `(let ((*log-level* ,level))
     ,@body))

;;; Logger Definition Macro

(defmacro deflogger (name &key level output)
  "Define a logger as a special variable."
  (let ((var-name (intern (format nil "*~A-LOGGER*" (string-upcase name)))))
    `(defvar ,var-name
       (make-logger ,(string-downcase (string name))
                    :level ,level
                    :output ,output))))

;;; Rotating Log

(defstruct (rotating-log (:constructor %make-rotating-log))
  "A rotating log that switches files based on size or time."
  (base-path nil :type (or null pathname string))
  (max-size (* 10 1024 1024) :type integer)  ; 10MB default
  (max-files 5 :type integer)
  (current-stream nil :type (or null stream))
  (current-size 0 :type integer)
  (current-file nil :type (or null pathname)))

(defun make-rotating-log (base-path &key (max-size (* 10 1024 1024)) (max-files 5))
  "Create a rotating log with BASE-PATH as the base filename."
  (let ((log (%make-rotating-log :base-path (pathname base-path)
                                  :max-size max-size
                                  :max-files max-files)))
    (open-rotating-log log)
    log))

(defun rotating-log-path (log index)
  "Return the path for log file at INDEX."
  (let ((base (rotating-log-base-path log)))
    (if (zerop index)
        base
        (make-pathname :name (format nil "~A.~D"
                                     (pathname-name base)
                                     index)
                       :defaults base))))

(defun open-rotating-log (log)
  "Open or reopen the rotating log file."
  (when (rotating-log-current-stream log)
    (close (rotating-log-current-stream log)))
  (let ((path (rotating-log-path log 0)))
    (setf (rotating-log-current-file log) path)
    (setf (rotating-log-current-stream log)
          (open path :direction :output
                     :if-exists :append
                     :if-does-not-exist :create))
    (setf (rotating-log-current-size log)
          (file-length (rotating-log-current-stream log)))))

(defun rotate-log (log)
  "Rotate the log files."
  (when (rotating-log-current-stream log)
    (close (rotating-log-current-stream log)))
  ;; Rotate existing files
  (loop for i from (1- (rotating-log-max-files log)) downto 0
        for old-path = (rotating-log-path log i)
        for new-path = (rotating-log-path log (1+ i))
        when (probe-file old-path)
          do (if (>= (1+ i) (rotating-log-max-files log))
                 (delete-file old-path)
                 (rename-file old-path new-path)))
  ;; Open fresh file
  (open-rotating-log log))

(defmethod stream-write-string ((log rotating-log) string &optional start end)
  "Write STRING to the rotating log, rotating if necessary."
  (let ((start (or start 0))
        (end (or end (length string))))
    (incf (rotating-log-current-size log) (- end start))
    (when (> (rotating-log-current-size log) (rotating-log-max-size log))
      (rotate-log log))
    (write-string string (rotating-log-current-stream log) :start start :end end)
    (force-output (rotating-log-current-stream log))))
