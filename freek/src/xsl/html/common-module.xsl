<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		version="1.1"
                exclude-result-prefixes="doc">
  
  <doc:reference xmlns="">
    <referenceinfo>
      <releaseinfo role="meta">
	$Id: common-module.xsl,v 1.1 2002/03/31 12:46:52 jorge Exp $
      </releaseinfo>
      <author>
	<surname>Ferrer</surname>
	<firstname>Jorge</firstname>
      </author>
      <copyright><year>2001</year>
	<holder>Jorge Ferrer</holder>
      </copyright>
    </referenceinfo>
    <title>Free Knowledge Project Stylesheet</title>
    <partintro>
      <section>
	<title>Descripción</title>
	<para>
	  Esta hoja de estilo es usada por el proyecto "Free
	  Knowledge" para publicar documento escritos en Docbook. Esta
	  plantilla genera una página HTML por cada sección de primer
	  nivel, <sgmltag>sect1</sgmltag> además de una portada.
	</para>
	<para>
	  Esta hoja de estilo necesita las hojas de estilo XSL para
	  DocBook de Norman Walsh que pueden obtenerse en
	  http://docbook.sourceforge.net
	</para>
      </section>
    </partintro>
  </doc:reference>


  <xsl:param name="html.stylesheet">../../../css/articulo.css</xsl:param>
  <xsl:param name="section.autolabel" select="1" doc:type="boolean"/>


  <!-- This sets the extension for HTML files to ".html".     -->	
  <!-- (The stylesheet's default for XHTML files is ".xhtm".) -->
  <xsl:param name="html.ext" select="'.html'"/>

</xsl:stylesheet>

