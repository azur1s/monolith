(pushnew (uiop:getcwd) ql:*local-project-directories*)
(ql:quickload :monolith)
(asdf:make :monolith)