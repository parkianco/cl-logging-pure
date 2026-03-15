;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-logging-pure)

(define-condition cl-logging-pure-error (error)
  ((message :initarg :message :reader cl-logging-pure-error-message))
  (:report (lambda (condition stream)
             (format stream "cl-logging-pure error: ~A" (cl-logging-pure-error-message condition)))))
