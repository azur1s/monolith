(uiop:define-package monolith
  (:use #:cl #:str)
  (:export #:main))
(in-package #:monolith)

(setf *random-state* (make-random-state t))

(defvar *delims* (coerce "`~!@#$%^&*()-=_+[]{};:'\",./?\\|" 'list))

(defun space-delims (str)
  "Inserts a space before and after each delimiter in the string."
  (reduce (lambda (s c)
            (if (member c *delims*)
                (concatenate 'string s " " (string c) " ")
                (concatenate 'string s (string c))))
          str
          :initial-value ""))

(defun to-id (words)
  "Takes a list of strings and returns a list of indices and a lookup hash table."
  (let ((lookup (make-hash-table :test #'equal))
        (next-id 0)
        (result nil))
    (dolist (str words)
      (multiple-value-bind (index exists-p)
        (gethash str lookup)
        (if exists-p
          (push index result)
          (progn
            (setf (gethash str lookup) next-id)
            (push next-id result)
            (incf next-id)))))
    (values (nreverse result) lookup)))

(defun reverse-lookup (value table)
  "Returns the key for a given value in a hash table."
  (loop for k being the hash-keys of table
        using (hash-value v)
        when (eql value v)
        return k))

(defun from-id (tokens table)
  "Converts a list of indices to a list of strings using a lookup table."
  (mapcar (lambda (token) (reverse-lookup token table)) tokens))

(defun print-lookup (table)
  "Prints the contents of a lookup table."
  (loop for k being the hash-keys of table
        using (hash-value v)
        do (format t "~a => ~a~%" k v)))

(defun tokenize (str)
  (to-id (str:words (space-delims str))))

(defun window (lst n)
  "Returns a list of n-tuples from the list lst."
  (loop for i from 0 to (- (length lst) n)
        collect (subseq lst i (+ i n))))

(defun split-last (lst)
  (if (null lst)
      nil
      (values (butlast lst) (car (last lst)))))

(defun make-chains (tokens chain-len)
  (let ((chains (make-hash-table :test #'equal))
        (xs (window tokens (+ chain-len 1))))
    ;; For each n-tuple, get the prefix and the next word and add it to the hash
    ;; table. If the prefix already exists, add the next word to the list of
    ;; next words.
    (dolist (x xs)
      (multiple-value-bind (prefix next) (split-last x)
        (push next (gethash prefix chains nil))))
    chains))

(defun keys (table)
  (loop for k being the hash-keys of table collect k))

(defun pick-random (lst)
  (nth (random (length lst)) lst))

(defun generate (chains start-tokens end-tokens)
  (let ((start (or start-tokens (pick-random (keys chains))))
        (result nil))
    ;; Add the start tokens to the result
    (dolist (token start)
      (push token result))
    ;; Generate the rest of the tokens
    (loop
      (let ((prefix (reverse (subseq result 0 (length start)))))
        ;; If the prefix is not in the chains or the last token is an end token,
        ;; return the result
        (unless (or (gethash prefix chains) (member (car (last result)) end-tokens))
          (return))
        ;; Add a random next token to the result
        (push (pick-random (gethash prefix chains)) result)))
    (reverse result)))

(defun ensure-end-token (str)
  (if (string= (car (last (str:words str))) "<end>")
      str
      (concatenate 'string str " <end>")))

(defun main ()
  (format t "Enter a sentence: ")
  (finish-output)
  (multiple-value-bind (tokens lookup)
      (tokenize (ensure-end-token (read-line)))
    (let* ((chains (make-chains tokens 2))
           (end-token (gethash "<end>" lookup))
           (result (split-last (from-id (generate chains nil '(end-token)) lookup)))
           (gen (format nil "~{~a ~}" result)))
      (format t (string-trim '(#\Space) gen)))))