(defpackage monolith/tests/main
  (:use :cl
        :monolith
        :rove))
(in-package :monolith/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :monolith)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
