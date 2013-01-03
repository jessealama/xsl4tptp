java = java
xsltxt.jar = xsltxt.jar

stylesheets = $(basename $(wildcard *.xsltxt))

xsls = $(addsuffix .xsl,$(stylesheets))
xsltxts = $(addsuffix .xsltxt,$(stylesheets))
editable-files = $(xsltxts) Makefile .gitignore $(xsls)
emacs-backups = $(addsuffix ~,$(editable-files))

%.xsl: %.xsltxt
	java -jar xsltxt.jar toXSL $*.xsltxt $*.xsl || (rm -f $*.xsl; false);

all: $(xsls)

clean:
	rm -f $(emacs-backups)
	rm -f $(xsls)
