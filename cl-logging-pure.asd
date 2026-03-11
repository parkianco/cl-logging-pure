;;;; cl-logging-pure.asd
;;;; Configurable logging with zero external dependencies

(asdf:defsystem #:cl-logging-pure
  :description "Pure Common Lisp configurable logging library"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "logging")))))
