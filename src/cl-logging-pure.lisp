;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package :cl_logging_pure)

(defun init ()
  "Initialize module."
  t)

(defun process (data)
  "Process data."
  (declare (type t data))
  data)

(defun status ()
  "Get module status."
  :ok)

(defun validate (input)
  "Validate input."
  (declare (type t input))
  t)

(defun cleanup ()
  "Cleanup resources."
  t)


;;; Substantive API Implementations
;;; These are wrappers/re-exports from the implementation modules

;;; Convenience error logging

(defun log-error (logger-or-name format-string &rest args)
  "Log an error message."
  (apply #'log-message +error+ logger-or-name format-string args))

;;; Batch logging operations

(defun log-batch (logger-or-name messages &key (level +info+))
  "Log multiple messages at once."
  (dolist (msg messages)
    (log-message level logger-or-name msg)))

(defun log-exception (logger-or-name exception &key (level +error+))
  "Log an exception with full details."
  (log-message level logger-or-name "Exception: ~A~%  Type: ~A"
               (princ-to-string exception)
               (type-of exception)))

;;; Logger collection management

(defvar *loggers* (make-hash-table :test #'equal)
  "Global registry of named loggers.")

(defun get-logger (name)
  "Retrieve or create a logger by name."
  (or (gethash name *loggers*)
      (let ((logger (make-logger name)))
        (setf (gethash name *loggers*) logger)
        logger)))

(defun register-logger (name logger)
  "Register a logger in the global registry."
  (setf (gethash name *loggers*) logger))

(defun clear-loggers ()
  "Clear all registered loggers."
  (clrhash *loggers*))

(defun list-loggers ()
  "Return list of all registered logger names."
  (loop for name being the hash-keys of *loggers*
        collect name))

;;; Log level configuration

(defun set-global-level (level)
  "Set the global minimum log level."
  (setf *log-level* level))

(defun get-global-level ()
  "Get the current global minimum log level."
  *log-level*)

(defun level-enabled-p (level)
  "Check if a log level is currently enabled."
  (<= level *log-level*))

;;; Output redirection

(defun set-log-output (stream)
  "Set the global log output stream."
  (setf *log-output* stream))

(defun log-to-file (filename &key (if-exists :append))
  "Redirect log output to a file."
  (let ((stream (open filename :direction :output :if-exists if-exists
                     :if-does-not-exist :create)))
    (set-log-output stream)
    stream))

(defun log-to-null ()
  "Disable logging by redirecting to null stream."
  (set-log-output (open *null-device* :direction :output)))

;;; Buffered logging

(defvar *log-buffer* nil
  "Buffer for accumulated log messages.")

(defvar *buffering-enabled* nil
  "Whether log buffering is enabled.")

(defmacro with-buffered-logging (&body body)
  "Execute BODY with log message buffering enabled."
  `(let ((*log-buffer* nil)
         (*buffering-enabled* t))
     (prog1
         (progn ,@body)
       (flush-log-buffer))))

(defun flush-log-buffer ()
  "Write all buffered log messages to output."
  (when *log-buffer*
    (dolist (msg (nreverse *log-buffer*))
      (write-string msg *log-output*))
    (setf *log-buffer* nil)
    (force-output *log-output*)))

;;; Log filtering and processing

(defvar *log-filter* nil
  "Function to filter log messages (NIL = accept all).")

(defun set-log-filter (predicate)
  "Set a filter function for log messages.
   PREDICATE receives (level logger-name message) and returns T to log."
  (setf *log-filter* predicate))

(defun clear-log-filter ()
  "Remove any active log filter."
  (setf *log-filter* nil))


;;; ============================================================================
;;; Standard Toolkit for cl-logging-pure
;;; ============================================================================

(defmacro with-logging-pure-timing (&body body)
  "Executes BODY and logs the execution time specific to cl-logging-pure."
  (let ((start (gensym))
        (end (gensym)))
    `(let ((,start (get-internal-real-time)))
       (multiple-value-prog1
           (progn ,@body)
         (let ((,end (get-internal-real-time)))
           (format t "~&[cl-logging-pure] Execution time: ~A ms~%"
                   (/ (* (- ,end ,start) 1000.0) internal-time-units-per-second)))))))

(defun logging-pure-batch-process (items processor-fn)
  "Applies PROCESSOR-FN to each item in ITEMS, handling errors resiliently.
Returns (values processed-results error-alist)."
  (let ((results nil)
        (errors nil))
    (dolist (item items)
      (handler-case
          (push (funcall processor-fn item) results)
        (error (e)
          (push (cons item e) errors))))
    (values (nreverse results) (nreverse errors))))

(defun logging-pure-health-check ()
  "Performs a basic health check for the cl-logging-pure module."
  (let ((ctx (initialize-logging-pure)))
    (if (validate-logging-pure ctx)
        :healthy
        :degraded)))


;;; Substantive Domain Expansion

(defun identity-list (x) (if (listp x) x (list x)))
(defun flatten (l) (cond ((null l) nil) ((atom l) (list l)) (t (append (flatten (car l)) (flatten (cdr l))))))
(defun map-keys (fn hash) (let ((res nil)) (maphash (lambda (k v) (push (funcall fn k) res)) hash) res))
(defun now-timestamp () (get-universal-time))