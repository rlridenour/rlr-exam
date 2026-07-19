PKG_NAME    := exam
PKG_VERSION := 0.1.0
UNAME       := $(shell uname)

ifeq ($(UNAME),Darwin)
TYPST_LOCAL_PKG_DIR := $(HOME)/Library/Application Support/typst/packages/local
else
TYPST_LOCAL_PKG_DIR := $(or $(XDG_DATA_HOME),$(HOME)/.local/share)/typst/packages/local
endif

.PHONY: install uninstall typ pdf versions versions-pdf example

# Symlink typst/ in as the local Typst package @local/exam:0.1.0, so
# generated .typ files can `#import "@local/exam:0.1.0": *`.
install:
	mkdir -p "$(TYPST_LOCAL_PKG_DIR)/$(PKG_NAME)"
	ln -sfn "$(CURDIR)/typst" "$(TYPST_LOCAL_PKG_DIR)/$(PKG_NAME)/$(PKG_VERSION)"
	@echo "Installed @local/$(PKG_NAME):$(PKG_VERSION) -> $(CURDIR)/typst"

uninstall:
	rm -rf "$(TYPST_LOCAL_PKG_DIR)/$(PKG_NAME)/$(PKG_VERSION)"

# make typ FILE=path/to/exam.org
# Writes path/to/exam-exam.typ and path/to/exam-key.typ.
typ:
	emacs --batch -Q -l elisp/ox-exam.el \
		--eval "(progn (find-file \"$(FILE)\") (org-mode) (org-exam-export-to-typst))"

# make pdf FILE=path/to/exam.org
# Writes the .typ files above, then compiles both to PDF.
pdf:
	emacs --batch -Q -l elisp/ox-exam.el \
		--eval "(progn (find-file \"$(FILE)\") (org-mode) (org-exam-export-to-pdf))"

N ?= 2

# make versions FILE=path/to/exam.org N=3
# Writes N shuffled version pairs: path/to/exam-A-exam.typ, -A-key.typ,
# -B-exam.typ, -B-key.typ, ...
versions:
	emacs --batch -Q -l elisp/ox-exam.el \
		--eval "(progn (find-file \"$(FILE)\") (org-mode) (org-exam--do-export-versions $(N)))"

# make versions-pdf FILE=path/to/exam.org N=3
# Writes the .typ files above, then compiles each to PDF.
versions-pdf:
	emacs --batch -Q -l elisp/ox-exam.el \
		--eval "(progn (find-file \"$(FILE)\") (org-mode) (mapc #'org-exam--typst-compile (org-exam--do-export-versions $(N))))"

example:
	$(MAKE) pdf FILE=examples/sample-exam.org
