gdv-stylesheet = $(srcdir)/gdv.xsl
render-tptp-stylesheet = $(srcdir)/render-tptp.xsl

leibniz.xml : leibniz.p
	tptp4X -c -x -umachine -fxml leibniz.p > leibniz.xml || rm -f leibniz.xml

%.ax.xml : leibniz.xml $(gdv-stylesheet)
	xsltproc --output $@ --stringparam problem "$*" $(gdv-stylesheet) leibniz.xml

%.ax : %.ax.xml $(render-tptp-stylesheet)
	xsltproc --output $@ $(render-tptp-stylesheet) $< || rm -f $@
