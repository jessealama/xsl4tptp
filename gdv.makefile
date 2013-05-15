.SECONDARY:

gdv-stylesheet = $(srcdir)/gdv.xsl
render-tptp-stylesheet = $(srcdir)/render-tptp.xsl

# functions
extract-axioms = xsltproc --output $2 --stringparam action "axioms" --stringparam problem "$1" $(gdv-stylesheet) leibniz.xml || (rm -f $2; false)
extract-problem = xsltproc --output $2 --stringparam action "problem" --stringparam problem "$1" $(gdv-stylesheet) leibniz.xml || rm -f $2
render-tptp = xsltproc --output $2 $(render-tptp-stylesheet) $1 || rm -f $2

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
