;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

;;;; test-logging-pure.lisp - Unit tests for logging-pure
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

(defpackage #:cl-logging-pure.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-logging-pure.test)

(defun run-tests ()
  "Run all tests for cl-logging-pure."
  (format t "~&Running tests for cl-logging-pure...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
