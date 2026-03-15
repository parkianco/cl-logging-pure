;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-logging-pure)

;;; Core types for cl-logging-pure
(deftype cl-logging-pure-id () '(unsigned-byte 64))
(deftype cl-logging-pure-status () '(member :ready :active :error :shutdown))
