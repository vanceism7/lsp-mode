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
(require 'lsp-mode)

(defgroup lsp-purescript nil
  "LSP support for Purescript, using purescript analysis server."
  :group 'lsp-mode
  ;; :link '(url-link "https://github.com/purescript-lang/sdk/tree/master/pkg/analysis_server")
  )

;;; Config
;;; Generated with lsp-generate-settings from vscode config
(defcustom lsp-purescript-purs-exe "purs"
  "Location of purs executable (resolved wrt PATH)"
  :type (quote string)
  :group 'lsp-purescript)

(defcustom lsp-purescript-use-combined-exe t
  "Whether to use the new combined purs executable. This will default to true in the future then go away."
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-psc-ide-server-exe "psc-ide-server"
  "Location of legacy psc-ide-server executable (resolved wrt PATH)"
  :type (quote string)
  :group 'lsp-purescript)

(defcustom lsp-purescript-psc-ide-port nil
  "Port to use for purs IDE server (whether an existing server or to start a new one). By default a random port is chosen (or an existing port in .psc-ide-port if present), if this is specified no attempt will be made to select an alternative port on failure."
  :type (quote (repeat number))
  :group 'lsp-purescript)

(defcustom lsp-purescript-auto-start-psc-ide t
  "Whether to automatically start/connect to purs IDE server when editing a PureScript file
(includes connecting to an existing running instance). If this is disabled, various features like autocomplete, tooltips, and other type info will not work until start command is run manually."
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-package-path "bower_components"
  "Path to installed packages. Will be used to control globs passed to IDE server for source locations.  Change requires IDE server restart."
  :type (quote string)
  :group 'lsp-purescript)

(defcustom lsp-purescript-add-psc-package-sources nil
  "Whether to add psc-package sources to the globs passed to the IDE server for source locations
(specifically the output of `psc-package sources`, if this is a psc-package project). Update due to adding packages/changing package set requires psc-ide server restart."
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-add-spago-sources nil
  "Whether to add spago sources to the globs passed to the IDE server for source locations
(specifically the output of `spago sources`, if this is a spago project). Update due to adding packages/changing package set requires psc-ide server restart."
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-source-path "src"
  "Path to application source root. Will be used to control globs passed to IDE server for source locations. Change requires IDE server restart."
:type (quote string)
  :group 'lsp-purescript)

(defcustom lsp-purescript-build-command "pulp build -- --json-errors"
  "Build command to use with arguments. Not passed to shell. eg `pulp build -- --json-errors` (this default requires pulp >=10)"
  :type (quote string)
  :group 'lsp-purescript)

(defcustom lsp-purescript-fast-rebuild t
  "Enable purs IDE server fast rebuild"
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-censor-warnings nil
  "The warning codes to censor, both for fast rebuild and a full build. Unrelated to any psa setup. e.g.: [\"ShadowedName\",\"MissingTypeDeclaration\"]"
  :type (quote lsp-string-vector)
  :group 'lsp-purescript)

(defcustom lsp-purescript-autocomplete-all-modules t
  "Whether to always autocomplete from all built modules, or just those imported in the file. Suggestions from all modules always available by explicitly triggering autocomplete."
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-autocomplete-add-import t
  "Whether to automatically add imported identifiers when accepting autocomplete result."
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-autocomplete-limit nil
  "Maximum number of results to fetch for an autocompletion request. May improve performance on large projects."
  :type (quote (repeat nil))
  :group 'lsp-purescript)

(defcustom lsp-purescript-autocomplete-grouped t
  "Whether to group completions in autocomplete results. Requires compiler 0.11.6"
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-imports-preferred-modules ["Prelude"]
  "Module to prefer to insert when adding imports which have been re-exported. In order of preference, most preferred first."
  :type (quote lsp-string-vector)
  :group 'lsp-purescript)

(defcustom lsp-purescript-prelude-module "Prelude"
  "Module to consider as your default prelude, if an auto-complete suggestion comes from this module it will be imported unqualified."
  :type (quote string)
  :group 'lsp-purescript)

(defcustom lsp-purescript-add-npm-path nil
  "Whether to add the local npm bin directory to the PATH for purs IDE server and build command."
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-psc-idelog-level ""
  "Log level for purs IDE server"
  :type (quote string)
  :group 'lsp-purescript)

(defcustom lsp-purescript-editor-mode nil
  "Whether to set the editor-mode flag on the IDE server"
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-polling nil
  "Whether to set the polling flag on the IDE server"
  :type (quote boolean)
  :group 'lsp-purescript)

(defcustom lsp-purescript-output-directory nil
  "Override purs ide output directory (output/ if not specified). This should match up to your build command"
  :type (quote string)
  :group 'lsp-purescript)

(defcustom lsp-purescript-trace-server "off"
  "Traces the communication between VSCode and the PureScript language service."
  :type (quote (choice (:tag "off" "messages" "verbose")))
  :group 'lsp-purescript)

(defcustom lsp-purescript-codegen-targets nil
  "List of codegen targets to pass to the compiler for rebuild. e.g. js, corefn. If not specified (rather than empty array) this will not be passed and the compiler will default to js. Requires 0.12.1+"
  :type (quote lsp-string-vector)
  :group 'lsp-purescript)

(lsp-register-custom-settings
 (quote
  (("purescript.codegenTargets" lsp-purescript-codegen-targets)
   ("purescript.trace.server" lsp-purescript-trace-server)
   ("purescript.outputDirectory" lsp-purescript-output-directory)
   ("purescript.polling" lsp-purescript-polling t)
   ("purescript.editorMode" lsp-purescript-editor-mode t)
   ("purescript.pscIdelogLevel" lsp-purescript-psc-idelog-level)
   ("purescript.addNpmPath" lsp-purescript-add-npm-path t)
   ("purescript.preludeModule" lsp-purescript-prelude-module)
   ("purescript.importsPreferredModules" lsp-purescript-imports-preferred-modules)
   ("purescript.autocompleteGrouped" lsp-purescript-autocomplete-grouped t)
   ("purescript.autocompleteLimit" lsp-purescript-autocomplete-limit)
   ("purescript.autocompleteAddImport" lsp-purescript-autocomplete-add-import t)
   ("purescript.autocompleteAllModules" lsp-purescript-autocomplete-all-modules t)
   ("purescript.censorWarnings" lsp-purescript-censor-warnings)
   ("purescript.fastRebuild" lsp-purescript-fast-rebuild t)
   ("purescript.buildCommand" lsp-purescript-build-command)
   ("purescript.sourcePath" lsp-purescript-source-path)
   ("purescript.addSpagoSources" lsp-purescript-add-spago-sources t)
   ("purescript.addPscPackageSources" lsp-purescript-add-psc-package-sources t)
   ("purescript.packagePath" lsp-purescript-package-path)
   ("purescript.autoStartPscIde" lsp-purescript-auto-start-psc-ide t)
   ("purescript.pscIdePort" lsp-purescript-psc-ide-port)
   ("purescript.pscIdeServerExe" lsp-purescript-psc-ide-server-exe)
   ("purescript.useCombinedExe" lsp-purescript-use-combined-exe t)
   ("purescript.pursExe" lsp-purescript-purs-exe))))

;;;
;;; Server Startup Settings
;;;
;; (lsp-dependency 'purescript-language-server
;;                 '(:system "purescript-language-server")
;;                 '(:npm :package "purescript-language-server"
;;                        :path "purescript-language-server"))

;; Download language server automatically
;; Unused for now since a self-installed purescript-language-server detects project paths better
;; (defun lsp-purescript--server-command ()
;;   "Generate LSP startup command."
;;   (cons
;;    (lsp-package-path 'purescript-language-server)
;;    '("--stdio")))

(defcustom lsp-purescript-use-npx t
  "Whether to execute purescript-language-server using npx or a globally installed version. Defaults to Npx"
  :type '(choice (const :tag "Npx" t)
                 (const :tag "Global" nil))
  :group 'lsp-purescript)

(defun lsp-purescript--server-command ()
  "Generate LSP startup command."
  (if lsp-purescript-use-npx
      '("npx" "purescript-language-server" "--stdio")
    '("purescript-language-server" "--stdio")))

;; Add language id for lsp-purescript
(add-to-list
 'lsp-language-id-configuration
 '(purescript-mode . "purescript"))

(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection (lsp-purescript--server-command))
                  :major-modes '(purescript-mode)
                  :priority -1
                  :initialized-fn (lambda (workspace)
                                    (with-lsp-workspace workspace
                                      (lsp--set-configuration
                                       (lsp-configuration-section "purescript"))))))
                  :server-id 'purescript_language_server
                  ;; :download-server-fn (lambda (_client callback error-callback _update?)
                  ;;                       (lsp-package-ensure
                  ;;                        'purescript-language-server
                  ;;                        callback
                  ;;                        error-callback))))

(provide 'lsp-purescript)

;;; lsp-purescript.el ends here

;; Local Variables:
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; End:
