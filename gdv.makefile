leibniz.xml : leibniz.p
	tptp4X -c -x -umachine -fxml leibniz.p > leibniz.xml || rm -f leibniz.xml

%.ax.xml : leibniz.xml gdv.xsl
	xsltproc --output $@ --stringparam problem "$*" gdv.xsl leibniz.xml

%.ax : %.ax.xml render-tptp.xsl
	xsltproc --output $@ render-tptp.xsl $< || rm -f $@
