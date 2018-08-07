PANDOC = /usr/local/bin/pandoc --quiet

all: README.html

%.html: %.md
	${PANDOC} -t slidy --standalone -o $@ $^
	open $@

self-contained: README.md
	${RM} README.html
	${PANDOC} -t slidy --standalone --self-contained -o README.html $^


resize:
	cd templates && make resize

# prep to zip this folder.
prep:
	make clean
	make self-contained
	@echo ready to zip!

clean:
	${RM} *.html *.bak 16x32.png

