;;; lsp-purescript.el --- LSP mode

;; Copyright (C) 2020 Vance Palacio

;; Author: Vance Palacio <vanceism7@gmail.com>
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; purescript analysis server client

;;; Code:

(defgroup lsp-purescript nil
  "LSP support for Purescript, using purescript analysis server."
  :group 'lsp-mode
  ;; :link '(url-link "https://github.com/purescript-lang/sdk/tree/master/pkg/analysis_server")
  )

;; Config
(defcustom lsp-purescript-pursExe "purs"
  "Location of purs executable (resolved wrt PATH)"
  :type 'string
  :group 'lsp-purescript)

(defcustom lsp-purescript-useCombinedExe t
  "Whether to use the new combined purs executable. This will default to true in the future then go away."
  :type 'boolean
  :group 'lsp-purescript)

(defcustom lsp-purescript-pscIdeServerExe "psc-ide-server"
  "Location of legacy psc-ide-server executable (resolved wrt PATH)"
  :type 'string
  :group 'lsp-purescript)

;; (defcustom lsp-purescript-pscIdePort nil
;;   "Port to use for purs IDE server (whether an existing server or to start a new one). By default a random port is chosen (or an existing port in .psc-ide-port if present), if this is specified no attempt will be made to select an alternative port on failure."
;;   :type [ "integer", "null" ]
;;   :group 'lsp-purescript)

(defcustom lsp-purescript-autoStartPscIde t
  "Whether to automatically start/connect to purs IDE server when editing a PureScript file (includes connecting to an existing running instance). If this is disabled, various features like autocomplete, tooltips, and other type info will not work until start command is run manually.",
  :type 'boolean
  :group 'lsp-purescript)


(defcustom lsp-purescript-packagePath "bower_components"
  "Path to installed packages. Will be used to control globs passed to IDE server for source locations.  Change requires IDE server restart."
  :type 'string
  :group 'lsp-purescript)

(defcustom lsp-purescript-addPscPackageSources nil
  "Whether to add psc-package sources to the globs passed to the IDE server for source locations (specifically the output of `psc-package sources`, if this is a psc-package project). Update due to adding packages/changing package set requires psc-ide server restart.",
  :type 'boolean
  :group 'lsp-purescript)

(defcustom lsp-purescript-addSpagoSources nil
  "Whether to add spago sources to the globs passed to the IDE server for source locations (specifically the output of `spago sources`, if this is a spago project). Update due to adding packages/changing package set requires psc-ide server restart.",
  :type 'boolean
  :group 'lsp-purescript)

(defcustom lsp-purescript-sourcePath "src"
  "Path to application source root. Will be used to control globs passed to IDE server for source locations. Change requires IDE server restart.",
 :type 'string
 :group 'lsp-purescript)

(defcustom lsp-purescript-buildCommand "pulp build -- --json-errors"
  "Build command to use with arguments. Not passed to shell. eg `pulp build -- --json-errors` (this default requires pulp >=10)"
  :type 'string
  :group 'lsp-purescript)

(defcustom lsp-purescript-fastRebuild t
  "Enable purs IDE server fast rebuild",
  :type 'boolean
  :group 'lsp-purescript)

;; "title": "Censor warnings",
;; (defcustom lsp-purescript-censorWarnings () ;; default []
;; "title": "Censor warnings",
;; "description": "The warning codes to censor, both for fast rebuild and a full build. Unrelated to any psa setup. e.g.: [\"ShadowedName\",\"MissingTypeDeclaration\"]",
;; "type": "array",
;; "default": [],
;; "items": {
;; "type": "string"
;; },
;; "scope": "resource"

(defcustom lsp-purescript-autocompleteAllModules t
  "Whether to always autocomplete from all built modules, or just those imported in the file. Suggestions from all modules always available by explicitly triggering autocomplete."
  :type 'boolean
  :group 'lsp-purescript)

(defcustom lsp-purescript-autocompleteAddImport t
  "Whether to automatically add imported identifiers when accepting autocomplete result.",
  :type 'boolean
  :group 'lsp-purescript)

;; (defcustom lsp-purescript-autocompleteLimit nil
;;   "Maximum number of results to fetch for an autocompletion request. May improve performance on large projects.",
;;   :type [
;;           "null",
;;           "integer"
;;           ],
;;   :group 'lsp-purescript)

(defcustom lsp-purescript-autocompleteGrouped t
  "Whether to group completions in autocomplete results. Requires compiler 0.11.6",
  :type 'boolean
  :group 'lsp-purescript)

;; (defcustom lsp-purescript-importsPreferredModules
;;  :type 'array
;;  "items": {
;;  "type": "string"
;;  :group 'lsp-purescript)
;;  "default": [
;;              "Prelude"
;;              ],
;;  "description": "Module to prefer to insert when adding imports which have been re-exported. In order of preference, most preferred first.",
;;  "scope": "resource"
;;  :group 'lsp-purescript)

 (defcustom lsp-purescript-preludeModule"
 :type 'string"
 "default": "Prelude",
 "description": "Module to consider as your default prelude, if an auto-complete suggestion comes from this module it will be imported unqualified.",
 "scope": "resource"
 :group 'lsp-purescript)

(defcustom lsp-purescript-addNpmPath nil
  "Whether to add the local npm bin directory to the PATH for purs IDE server and build command.",
  :type 'boolean
  :group 'lsp-purescript)

(defcustom lsp-purescript-pscIdelogLevel ""
  "Log level for purs IDE server",
  :type 'string
  :group 'lsp-purescript)

(defcustom lsp-purescript-editorMode nil
  "Whether to set the editor-mode flag on the IDE server",
  :type 'boolean
  :group 'lsp-purescript)

(defcustom lsp-purescript-polling nil
  "Whether to set the polling flag on the IDE server",
  :type 'boolean
  :group 'lsp-purescript)

(defcustom lsp-purescript-outputDirectory nil
  "Override purs ide output directory (output/ if not specified). This should match up to your build command",
  :type 'string
  :group 'lsp-purescript)

 ;; (defcustom lsp-purescript-trace.server"
 ;; "scope": "window",
 ;; :type 'string"
 ;; "enum": [
 ;;          "off",
 ;;          "messages",
 ;;          "verbose"
 ;;          ],
 ;; "default": "off",
 ;; "description": "Traces the communication between VSCode and the PureScript language service."
 ;; :group 'lsp-purescript)

;; (defcustom lsp-purescript-codegenTargets nil
;;   "List of codegen targets to pass to the compiler for rebuild. e.g. js, corefn. If not specified (rather than empty array) this will not be passed and the compiler will default to js. Requires 0.12.1+"
;;   :type 'array
;;   "default": null,
;;   "items": {
;;   "type": "string"
;;   :group 'lsp-purescript)

(defun lsp-purescript--server-command ()
  "Generate LSP startup command."
  "npx purescript-language-server --stdio")
  ;; (if lsp-purescript-use-npm-bin
  ;;     (expand-file-name "./node_modules/bin/purs ide")
  ;;     (expand-file-name "purs ide")))
   ;; lsp-purescript-server-command
   ;; `(,(expand-file-name (f-join lsp-purescript-sdk-dir "bin/purescript"))
   ;;   ,(expand-file-name (f-join lsp-purescript-sdk-dir "bin/snapshots/analysis_server.purescript.snapshot"))
   ;;   "--lsp")))

;; TODO: Need function to convert all config options into json

(lsp-register-client
 (make-lsp-client :new-connection
                  (lsp-stdio-connection
                   'lsp-purescript--server-command)
                  :major-modes '(purescript-mode)
                  :priority -1
                  :initialization-options
                  `((onlyAnalyzeProjectsWithOpenFiles . ,lsp-purescript-only-analyze-projects-with-open-files)
                    (suggestFromUnimportedLibraries . ,lsp-purescript-suggest-from-unimported-libraries))
                  :server-id 'purescript_language_server))

(provide 'lsp-purescript)

;;; lsp-purescript.el ends here

;; Local Variables:
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; End:
