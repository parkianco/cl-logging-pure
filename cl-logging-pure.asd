;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-logging-pure.asd
;;;; Configurable logging with zero external dependencies

(asdf:defsystem #:cl-logging-pure
  :description "Pure Common Lisp configurable logging library"
  :author "Park Ian Co"
  :license "Apache-2.0"
  :version "0.1.0"
  :serial t
             (:module "src"
                :components ((:file "package")
                             (:file "conditions" :depends-on ("package"))
                             (:file "types" :depends-on ("package"))
                             (:file "cl-logging-pure" :depends-on ("package" "conditions" "types")))))))

(asdf:defsystem #:cl-logging-pure/test
  :description "Tests for cl-logging-pure"
  :depends-on (#:cl-logging-pure)
  :serial t
  :components ((:module "test"
                :components ((:file "test-logging-pure"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-logging-pure.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
