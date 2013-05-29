.SECONDARY:

source-tptp = leibniz.p
source-tptp-xml = $(addsuffix .xml,$(basename $(source-tptp)))
gdv-stylesheet = $(srcdir)/gdv.xsl
render-tptp-stylesheet = $(srcdir)/render-tptp.xsl
gdv-makefile = $(srcdir)/gdv.makefile

.PHONY: all problems clean $(source-tptp) $(gdv-stylesheet) $(render-tptp-stylesheet)

# functions
exec-or-trash-output = ($1 > $2) || (rm -f $2; false)
extract-axioms = $(call exec-or-trash-output,xsltproc --stringparam action "axioms" --stringparam problem "$1" $(gdv-stylesheet) $(source-tptp-xml),$2)
extract-problem = $(call exec-or-trash-output,xsltproc --stringparam action "problem" --stringparam problem "$1" $(gdv-stylesheet) $(source-tptp-xml),$2)
render-tptp = $(call exec-or-trash-output,xsltproc $(render-tptp-stylesheet) $1,$2)

all: problems

theorems.txt : $(source-tptp)
	tptp4X -c -x -umachine $< > $@1 || (rm -f $@1; false)
	(grep --fixed-string ',theorem,' $@1 | cut -f 1 -d ',' | cut -f 2 -d '(') > $@ || (rm -f $@; false)
	rm -f $@1

lemmas.txt : $(source-tptp)
	tptp4X -c -x -umachine $< > $@1 || rm -f $@1
	(grep --fixed-string ',lemma,' $@1 | cut -f 1 -d ',' | cut -f 2 -d '(' > $@) || (rm -f $@; false)
	rm -f $@1

problems.txt : theorems.txt lemmas.txt
	cat theorems.txt lemmas.txt > $@

problems: problems.txt
	cat problems.txt | sed -e 's/$$/.eproof/' | xargs $(MAKE) -C `pwd` --makefile=$(gdv-makefile)

$(source-tptp-xml) : $(source-tptp)
	$(call exec-or-trash-output,tptp4X -c -x -umachine -fxml $(source-tptp),$(source-tptp-xml))

%.ax : $(render-tptp-stylesheet)
	$(call extract-axioms,$*,$@1)
	$(call render-tptp,$@1,$@)
	rm -f $@1

%.p : $(source-tptp-xml) $(render-tptp-stylesheet)
	$(call extract-problem,$*,$@1)
	$(call render-tptp,$@1,$@)
	rm -f $@1

%.model : %.ax
	$(call exec-or-trash-output,paradox --model $<,$@)

%.eproof : %.p
	$(call exec-or-trash-output,eproof --tstp-format --auto $<,$@)

clean:
	rm -f $(wildcard *.ax)
	rm -f $(wildcard *.eproof)
	rm -f $(wildcard *.model)
	rm -f problems.txt
	rm -f lemmas.txt
	rm -f theorems.txt
