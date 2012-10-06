java = java
xsltxt.jar = xsltxt.jar

stylesheets = ignore-axioms \
              ignore-conjecture \
              name-formulas \
              normalize-step-names \
              paradox-interpretation \
              prepare-problem \
              render-tptp \
              sort-tstp \
              tptp-info \
              tptp-to-latex \
              tptp-to-lisp \
              tstp-dependencies \
              used-premises

xsls = $(addsuffix .xsl,$(stylesheets))
xsltxts = $(addsuffix .xsltxt,$(stylesheets))
editable-files = $(xsltxts) Makefile .gitignore $(xsls)
emacs-backups = $(addsuffix ~,$(editable-files))

%.xsl: %.xsltxt
	$(java) -jar $(xsltxt.jar) toXSL $*.xsltxt $*.xsl || (rm -f $*.xsl; false);

all: $(xsls)

clean:
	rm -f $(emacs-backups)
	rm -f $(xsls)
