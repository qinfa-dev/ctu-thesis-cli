.PHONY: all install test test-ci lint clean bundle help

PREFIX ?= $(HOME)/.local
DIST_DIR = dist
BUNDLE_SCRIPT = $(DIST_DIR)/ctu-thesis
TEMPLATES_TAR = $(DIST_DIR)/templates.tar.gz

all: help

install:
	@echo "Installing ctu-thesis to $(PREFIX)/bin ..."
	@mkdir -p $(PREFIX)/bin
	@cp bin/ctu-thesis $(PREFIX)/bin/ctu-thesis
	@chmod +x $(PREFIX)/bin/ctu-thesis
	@mkdir -p $(PREFIX)/lib/ctu-thesis
	@cp -r lib/* $(PREFIX)/lib/ctu-thesis/
	@mkdir -p $(HOME)/.ctu-thesis/templates
	@cp -r templates/* $(HOME)/.ctu-thesis/templates/
	@echo "Done. Add $(PREFIX)/bin to your PATH if needed."

test:
	@bats tests/

test-ci:
	@bats --tap tests/

lint:
	@shellcheck bin/ctu-thesis lib/core.sh lib/commands/*.sh install.sh

clean:
	@rm -rf tests/tmp-*
	@rm -f $(BUNDLE_SCRIPT) $(TEMPLATES_TAR)

bundle:
	@echo "Creating bundled distribution..."
	@mkdir -p $(DIST_DIR)
	@cat lib/version.sh > $(BUNDLE_SCRIPT)
	@echo '' >> $(BUNDLE_SCRIPT)
	@cat lib/core.sh >> $(BUNDLE_SCRIPT)
	@echo '' >> $(BUNDLE_SCRIPT)
	@for cmd in init build validate doctor clean config chapter update help; do \
		echo "# -- command: $$cmd --" >> $(BUNDLE_SCRIPT); \
		cat lib/commands/$$cmd.sh >> $(BUNDLE_SCRIPT); \
		echo '' >> $(BUNDLE_SCRIPT); \
	done
	@cat bin/ctu-thesis >> $(BUNDLE_SCRIPT)
	@chmod +x $(BUNDLE_SCRIPT)
	@tar czf $(TEMPLATES_TAR) -C templates .
	@echo "Bundle created: $(BUNDLE_SCRIPT), $(TEMPLATES_TAR)"

help:
	@echo "ctu-thesis-cli Makefile"
	@echo "  make install  - Install CLI to PREFIX (default: ~/.local)"
	@echo "  make test     - Run bats tests"
	@echo "  make lint     - Run shellcheck"
	@echo "  make bundle   - Create distribution artifacts in dist/"
	@echo "  make clean    - Remove test and build artifacts"
