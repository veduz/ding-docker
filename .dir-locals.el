;;; .dir-locals.el --- Local dir variables           -*- lexical-binding: t; -*-

;; Copyright (C) 2015, 2016  Arne Jørgensen

;; Author: Arne Jørgensen <arne@arnested.dk>
;; Keywords: data

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Link issue numbers to Redmine.

;;; Code:

((nil . ((bug-reference-bug-regexp . "\\(#\\([0-9]+\\)\\)")
         (bug-reference-url-format . "http://platform.dandigbib.org/issues/%s")
         (mode . bug-reference-prog))))

;;; .dir-locals.el ends here
