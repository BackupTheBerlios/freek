<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		version="1.1"
                exclude-result-prefixes="doc">
  <xsl:import  href="../../nwalsh/html/chunk.xsl"/>
  <xsl:param name="html.stylesheet">../../../css/articulo.css</xsl:param>
  <xsl:param name="section.autolabel" select="1" doc:type="boolean"/>
  <!--  <xsl:include   href="common-module.xsl"/>-->
  <xsl:include   href="navigation-module.xsl"/>
</xsl:stylesheet>