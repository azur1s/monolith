(defsystem "monolith"
  :version "0.0.1"
  :author ""
  :license ""
  :depends-on ("str")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :build-operation "program-op"
  :build-pathname "build/monolith"
  :entry-point "monolith:main"
  :in-order-to ((test-op (test-op "monolith/tests"))))

(defsystem "monolith/tests"
  :author ""
  :license ""
  :depends-on ("monolith"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for monolith"
  :perform (test-op (op c) (symbol-call :rove :run c)))
