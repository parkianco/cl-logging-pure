# cl-logging-pure

Pure Common Lisp configurable logging library with zero external dependencies.

## Installation

```lisp
(asdf:load-system :cl-logging-pure)
```

## Usage

```lisp
(use-package :cl-logging-pure)

;; Basic logging
(log-info "app" "Server started on port ~D" 8080)
(log-error "db" "Connection failed: ~A" error)

;; Define a logger
(deflogger myapp :level +debug+)
(log-debug *myapp-logger* "Processing request")

;; Change global log level
(setf *log-level* +warn+)

;; Temporary log level
(with-log-level +debug+
  (log-debug "app" "Debugging..."))

;; Rotating logs
(let ((log (make-rotating-log "/var/log/app.log"
                               :max-size (* 10 1024 1024)
                               :max-files 5)))
  (setf *log-output* log))
```

## Log Levels

- `+debug+` (0) - Debug messages
- `+info+` (1) - Informational messages
- `+warn+` (2) - Warning messages
- `+error+` (3) - Error messages
- `+off+` (4) - Disable logging

## API

- `deflogger` - Define a named logger
- `log-message` - Log at specified level
- `log-debug`, `log-info`, `log-warn`, `log-error` - Level-specific logging
- `with-logging` - Temporary logging configuration
- `*log-level*` - Global minimum log level
- `*log-output*` - Global log output stream
- `make-rotating-log` - Create rotating log file

## License

BSD-3-Clause. Copyright (c) 2024-2026 Parkian Company LLC.
