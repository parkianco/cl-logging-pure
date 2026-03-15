;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; package.lisp
;;;; Package definition for cl-logging-pure

(defpackage #:cl-logging-pure
  (:use #:cl)
  (:export
   #:with-logging-pure-timing
   #:logging-pure-batch-process
   #:logging-pure-health-check;; Logger definition
   #:deflogger
   #:make-logger
   #:logger
   #:logger-name
   #:logger-level
   #:logger-output
   ;; Logging functions
   #:log-message
   #:log-debug
   #:log-info
   #:log-warn
   #:log-error
   ;; Context macros
   #:with-logging
   #:with-log-level
   ;; Global configuration
   #:*log-level*
   #:*log-output*
   #:*log-format*
   #:*log-timestamp-format*
   ;; Log levels
   #:+debug+
   #:+info+
   #:+warn+
   #:+error+
   #:+off+
   ;; Rotating logs
   #:make-rotating-log
   #:rotating-log
   #:rotate-log))
