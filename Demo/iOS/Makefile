# Close any currently-open project in Xcode before regenerating the .xcodeproj file, and re-open.
# If the script fails, the project is not open and we can simply regenerate the project.
# This is the default target if a user types 'make' without arguments.	
project:
	@test $(shell osascript bin/kill-xcode.applescript "$(xcodeproj_path)") && ($(MAKE) xcodegen && sleep 1 && open -g "$(xcodeproj_path)") || $(MAKE) xcodegen

# The actual invocation of `xcodegen`, followed by project sanitization to optimize incremental
# build performance.
xcodegen:	
	@mint run xcodegen
	@mint run velocity sanitize-xcodegen-project \
		--xcodeproj-path $(xcodeproj_file) \
		--modules-yml-path project-modules.yml \
		--project-yml-paths project.yml

# Used to manually run the Swift formatter. This is typically invoked by githooks, so is not
# necessary to run manually.
format:
	@mint run swiftformat --config .swiftformat .

# This command should be run any time the dependencies.yml file is updated. It makes sure
# The client has the latest dependency versions, and generates project-dependencies.yml
pulldeps:
	@mint run velocity pull-dependencies --verbose
	@mint run velocity generate-xcodegen-deps \
		--dependency-output-path local \
		--verbose

# This performs work needed when the internal module graph is updated.
# 1. Calls generate-inject to update the run-time injection code
# 2. Calls generate-xcodegen-modules to update project-modules.yml
modules:
	@mint run velocity generate-inject \
		--modules-path Modules \
		--output-file Modules/Injection/Injection/Injection.swift \
		--inject-function-name registerInjections \
		--verbose
	@mint run velocity generate-xcodegen-modules \
		--regen-imports \
		--regen-info-plists \
		--root-path Modules \
		--platforms iOS \
		--verbose

# Install all project dependencies and create the project file.
bootstrap:
	@brew install mint
	@mint bootstrap
	# Add this to normal projects (unnecessary in this demo) to install format-on-commit hooks.
	# @cp bin/githooks/pre-commit .git/hooks/.
	$(MAKE) pulldeps
	$(MAKE) modules
	$(MAKE) xcodegen

# Commands are not associated directly with files are declared in the .PHONY section
.PHONY: project \
		xcodegen \
		format \
		modules \
		bootstrap

xcodeproj_file := "ConfigPanelDemo.xcodeproj"
xcodeproj_path := $(abspath $(xcodeproj_file))
