<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		version="1.1"
                exclude-result-prefixes="doc">
  
  <!-- Localización de las hojas de estilo XSL para docbook de Norman
  Walsh --> 
<!--    <xsl:import  href="../../nwalsh/html/autoidx.xsl"/> -->
<!--    <xsl:import href="../../nwalsh/html/chunk-common.xsl"/> -->
<!--    <xsl:include href="../../nwalsh/html/chunker.xsl"/> -->



  <doc:reference xmlns="">
    <referenceinfo>
      <releaseinfo role="meta">
	$Id: navigation-module.xsl,v 1.1 2002/03/31 12:46:52 jorge Exp $
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


  <!--
     Parámetros
    -->
  <xsl:param name="chunk.first.sections" select="'0'"/>
  <!--
  <xsl:variable name="freek.nav.img.siguiente">../comun/img/navegacion/flecha-derecha.gif</xsl:variable>
  <xsl:variable
  name="freek.nav.img.anterior">../comun/img/navegacion/flecha-izda.gif</xsl:variable>
  -->
  <xsl:variable name="freek.nav.img.siguiente">../../../img/navegacion/flecha-derecha.gif</xsl:variable>
  <xsl:variable name="freek.nav.img.anterior">../../../img/navegacion/flecha-izda.gif</xsl:variable>
  <xsl:variable name="freek.nav.box.color">#a7dfdf</xsl:variable>
  <xsl:variable name="freek.nav.box.width">95%</xsl:variable>


  <!--
     Templates
    -->

  <doc:template name="header.navigation" xmlns="">
    <refpurpose>Muestra la cabecera de las páginas</refpurpose>
    <refdescription>
      <para>
	Dibuja una caja en la parte superior con el nombre de la
	sección actual junto con dos flechas de navegación para ir a
	las páginas anterior o siguiente.
      </para>
    </refdescription>
    <refparameter>
      <variablelist>
	<varlistentry><term>prev</term>
	  <listitem>
	    <para>URL de la página anterior.</para>
	  </listitem>
	</varlistentry>
	<varlistentry><term>next</term>
	  <listitem>
	    <para>URL de la página siguiente.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>

  <xsl:template name="header.navigation">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>

    <xsl:if test="$suppress.navigation = '0'">
      <div class="navheader">
	<table bgcolor="{$freek.nav.box.color}"
	width="{$freek.nav.box.width}" summary="Cabecera de navegacion"> 
	  <tr>
	    <td align="left" valign="middle">
	      <xsl:if test="count($prev)>0">
		<a accesskey="p" class="textoicono">
		  <xsl:attribute name="href">
		    <xsl:call-template name="href.target">
		      <xsl:with-param name="object" select="$prev"/>
		    </xsl:call-template>
		  </xsl:attribute>
		  <img src="{$freek.nav.img.anterior}" width="16"
		       height="18" border="0" align="top"/>
		  <xsl:call-template name="gentext.nav.prev"/>
		</a>
	      </xsl:if>
	    </td>
	    <td align="right" valign="middle">
	      <xsl:if test="count($next)>0">
		<a accesskey="n" class="textoicono">
		  <xsl:attribute name="href">
		    <xsl:call-template name="href.target">
		      <xsl:with-param name="object" select="$next"/>
		    </xsl:call-template>
		  </xsl:attribute>
		  <xsl:call-template name="gentext.nav.next"/>
		  <img src="{$freek.nav.img.siguiente}" width="16" height="18"
		       border="0" align="top" />
		</a>
	      </xsl:if>
	    </td>
	  </tr>
	  
	  <tr bgcolor="#ffffff">
	    <td colspan="2" align="center">
	      <span class="navegacion">
		<xsl:value-of select="/article/artheader/title"/>
		<xsl:value-of select="/article/articleinfo/title"/>
	      </span>
	    </td>
	  </tr>
	</table>
      </div>
    </xsl:if>
    <!--
    <table class="margenes" width="100%">
      <tr>
        <td>
          <h1><xsl:apply-templates select="."
		mode="object.title.markup"/></h1>
        </td>
      </tr>
    </table>
    -->
  </xsl:template>

  <doc:template name="footer.navigation" xmlns="">
    <refpurpose>Muestra el pie de navegación de las páginas</refpurpose>
    <refdescription>
      <para>
	Dibuja una caja en la parte superior junto con dos flechas de
	navegación para ir a las páginas anterior o siguiente. Debajo
	de estas flechas se muestra el nombre de la siguiente sección.
      </para>
    </refdescription>
    <refparameter>
      <variablelist>
	<varlistentry><term>prev</term>
	  <listitem>
	    <para>URL de la página anterior.</para>
	  </listitem>
	</varlistentry>
	<varlistentry><term>next</term>
	  <listitem>
	    <para>URL de la página siguiente.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>


  <xsl:template name="footer.navigation">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>

    <xsl:if test="$suppress.navigation = '0'">
      <div class="navfooter">
	<table bgcolor="{$freek.nav.box.color}"
	width="{$freek.nav.box.width}" summary="Pie de navegación"> 
	  <tr>
	    <td align="left" valign="middle" width="40%">
	      <xsl:if test="count($prev)>0">
		<a accesskey="p" class="textoicono">
		  <xsl:attribute name="href">
		    <xsl:call-template name="href.target">
		      <xsl:with-param name="object" select="$prev"/>
		    </xsl:call-template>
		  </xsl:attribute>
		  <img src="{$freek.nav.img.anterior}" width="16"
		       height="18" border="0" align="top"/>
		  <xsl:call-template name="gentext.nav.prev"/>
		</a>
		<xsl:text>&#160;</xsl:text>
	      </xsl:if>
	    </td>
	    <td width="20%" align="center">
	      <xsl:choose>
		<xsl:when test="$home != .">
		  <a accesskey="h" class="textoicono">
		    <xsl:attribute name="href">
		      <xsl:call-template name="href.target">
			<xsl:with-param name="object" select="$home"/>
		      </xsl:call-template>
		    </xsl:attribute>
		    <xsl:call-template name="gentext.nav.home"/>
		  </a>
		</xsl:when>
		<xsl:otherwise>&#160;</xsl:otherwise>
	      </xsl:choose>
	    </td>
	    <td width="40%" align="right" valign="middle">
	      <xsl:text>&#160;</xsl:text>
	      <xsl:if test="count($next)>0">
		<a accesskey="n" class="textoicono">
		  <xsl:attribute name="href">
		    <xsl:call-template name="href.target">
		      <xsl:with-param name="object" select="$next"/>
		    </xsl:call-template>
		  </xsl:attribute>
		  <xsl:call-template name="gentext.nav.next"/>
		  <img src="{$freek.nav.img.siguiente}" width="16" height="18"
		       border="0" align="top" />
		</a>
	      </xsl:if>
	    </td>
	  </tr>

	  <tr bgcolor="#ffffff">
	    <td width="40%" align="left">
	      <xsl:apply-templates select="$prev" mode="object.title.markup"/>
	      <xsl:text>&#160;</xsl:text>
	    </td>
	    <td width="20%" align="center">
	      <xsl:choose>
		<xsl:when test="count($up)>1">
		  <a accesskey="u" class="textoicono">
		    <xsl:attribute name="href">
		      <xsl:call-template name="href.target">
			<xsl:with-param name="object" select="$up"/>
		      </xsl:call-template>
		    </xsl:attribute>
		    <xsl:call-template name="gentext.nav.up"/>
		  </a>
		</xsl:when>
		<xsl:otherwise>&#160;</xsl:otherwise>
	      </xsl:choose>
	    </td>
	    <td width="40%" align="right">
	      <xsl:text>&#160;</xsl:text>
	      <xsl:apply-templates select="$next" mode="object.title.markup"/>
	    </td>
	  </tr>
	</table>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

