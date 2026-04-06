.NOTPARALLEL:

.PHONY: sync test

EXCLUDES = \
	.git \
	.hg \
	.sl \
	Makefile \
	LICENSE

EXCLUDE_FLAGS = $(EXCLUDES:%=--exclude='%')

sync:
	rsync -av $(EXCLUDE_FLAGS) . ~

test:
	rsync -avn $(EXCLUDE_FLAGS) . ~
