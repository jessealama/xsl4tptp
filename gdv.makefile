.SECONDARY:

.PHONY: all problems

gdv-stylesheet = $(srcdir)/gdv.xsl
render-tptp-stylesheet = $(srcdir)/render-tptp.xsl

# functions
extract-axioms = xsltproc --output $2 --stringparam action "axioms" --stringparam problem "$1" $(gdv-stylesheet) leibniz.xml || (rm -f $2; false)
extract-problem = xsltproc --output $2 --stringparam action "problem" --stringparam problem "$1" $(gdv-stylesheet) leibniz.xml || rm -f $2
render-tptp = xsltproc --output $2 $(render-tptp-stylesheet) $1 || rm -f $2

all: problems

theorems.txt : leibniz.p
	tptp4X -c -x -umachine $< > $@1 || (rm -f $@1; false)
	(grep --fixed-string ',theorem,' $@1 | cut -f 1 -d ',' | cut -f 2 -d '(') > $@ || (rm -f $@; false)
	rm -f $@1

lemmas.txt : leibniz.p
	tptp4X -c -x -umachine $< > $@1 || rm -f $@1
	(grep --fixed-string ',lemma,' $@1 | cut -f 1 -d ',' | cut -f 2 -d '(' > $@) || (rm -f $@; false)
	rm -f $@1

problems.txt : theorems.txt lemmas.txt
	cat theorems.txt lemmas.txt > $@

problems: problems.txt
	cat problems.txt | sed -e 's/$$/.eproof/' | xargs $(MAKE)

leibniz.xml : leibniz.p
	tptp4X -c -x -umachine -fxml leibniz.p > leibniz.xml || rm -f leibniz.xml

%.ax : $(render-tptp-stylesheet)
	$(call extract-axioms,$*,$@1)
	$(call render-tptp,$@1,$@)
	rm -f $@1

%.p : leibniz.xml $(render-tptp-stylesheet)
	$(call extract-problem,$*,$@1)
	$(call render-tptp,$@1,$@)
	rm -f $@1

%.model : %.ax
	paradox --model $< > $@ || rm -f $@

%.eproof : %.p
	eproof --tstp-format --auto $< > $@ || rm -f $@
