<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		version="1.1"
                exclude-result-prefixes="doc">
  <xsl:output method="html"
	      encoding="ISO-8859-1"
	      indent="no"/>

  <xsl:template match="article">
    <xsl:choose>
      <xsl:when test="articleinfo">
	<xsl:apply-templates select="articleinfo"/>
      </xsl:when>
      <xsl:when test="artheader">
	<xsl:apply-templates select="artheader"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="articleinfo|artheader">
    <xsl:variable name="link">articulos/<xsl:value-of select="../@id"/>/index.html</xsl:variable>

    <!-- === ARTÍCULO: <xsl:value-of select="title"/> === -->
    <table bgcolor="#ffffff" border="0" cellspacing="0" cellpadding="0"
	   width="95%">
      <tr>
	<td colspan="2"
	    rowspan="2"><img
			     src="../img/adornos/borde-rojo-top-izda.gif"
			     width="6" 
			     height="4" border="0" /></td>
	<td bgcolor="#ce6363"><img src="../img/pixel.gif"
				   class="spacer"
				   width="1"
				   height="1" /></td>
	<td colspan="2"
	    rowspan="2"><img src="../img/adornos/borde-rojo-top-dcha.gif"
			     width="6" 
			     height="4"
			     border="0" /></td>
      </tr>

      <tr>
	<td><img src="../img/pixel.gif" class="spacer" width="1"
		 height="3" /></td> 
      </tr>

      <tr>
	<td bgcolor="#ce6363"><img src="../img/pixel.gif"
				   class="spacer"
				   width="1" 
				   height="1" /></td>

	<td><img src="../img/pixel.gif" class="spacer" width="5"
		 height="1" /></td> 

	<td>
	  <table width="100%" cellpadding="3" cellspacing="1"
		 border="0">
	    <tr bgcolor="#ffffff">
	      <td>
		<table cellpadding="0" cellspacing="0" border="0">
		  <tr>
		    <td><b><font face="verdana,arial,helvetica">
			  <a class="oro"><xsl:attribute
			  name="href"><xsl:value-of 
			  select="$link" /></xsl:attribute> 
			    <xsl:value-of select="title"/></a>
			</font></b></td>
		  </tr>
		</table>
	      </td>
	    </tr>
	  </table>
	</td>

	<td><!-- Estas celdas controla la sombra por la derecha
	--><img	src="../img/pixel.gif" class="spacer" width="3"
	height="1" /></td> 

	<td bgcolor="#ce6363"><img src="../img/pixel.gif"
				   class="spacer" width="3" 
				   height="1" /></td>
      </tr>

      <tr>
	<td colspan="5"
	    bgcolor="#ce6363"><img src="../img/pixel.gif"
				   class="spacer" 
				   width="1" height="1"/></td> 
      </tr>

      <tr>
	<td bgcolor="#ce6363"><img src="../img/pixel.gif"
				   class="spacer" width="1" 
				   height="1" /></td>
	
	<td><img src="../img/pixel.gif"
		 class="spacer" width="1"
		 height="1" /></td> 

	<td>
	  <table width="100%" cellpadding="3" cellspacing="1"
		 border="0">
	    <tr bgcolor="#ffffff">
	      <td>
		<table width="100%">
		  <tr>
		    <td><font color="#ce6363" size="-1">
			Autor: <xsl:apply-templates select="author" />
			<xsl:value-of select="pubdate" /></font></td>
		  </tr>

		  <tr>
		    <td cellpadding="5" bgcolor="#ffffff">
		      <a><xsl:attribute name="href"><xsl:value-of
			select="$link" /></xsl:attribute> 
			<img align="left"
			     src="../img/logos/logo-articulo.jpeg"
			     alt="[ARTICULO]" 
			     width="48" height="48" border="0" /></a>
		      <xsl:apply-templates select="abstract"/>
		      <xsl:call-template name="section"/>

		    </td>
		  </tr>
		</table>
	      </td>
	    </tr>
	  </table>
	</td>

	<td><img src="../img/pixel.gif" class="spacer" width="1"
		 height="1" /></td> 

	<td bgcolor="#ce6363"><img src="../img/pixel.gif"
				   class="spacer" width="1" 
				   height="1" /></td>
      </tr>

      <tr>
	<td colspan="5" bgcolor="#ce6363"><img src="../img/pixel.gif"
					       class="spacer" 
					       width="1" height="1" /></td>
      </tr>

      <tr>
	<td bgcolor="#ce6363"><img src="../img/pixel.gif"
				   class="spacer" width="1" 
				   height="1" /></td>

	<td><img src="../img/pixel.gif" class="spacer" width="1"
		 height="1" /></td> 

	<td>
	  <table width="100%" cellpadding="3" cellspacing="1"
		 border="0">
	    <tr bgcolor="#ffffff" cellpadding="0">
	      <td><a class="oro"><xsl:attribute name="href"><xsl:value-of
		  select="$link" /></xsl:attribute> 
		  &gt;&gt;Leer el artículo</a></td>
	    </tr>
	  </table>
	</td>
	
	<td><img src="../img/pixel.gif" class="spacer" width="1"
		 height="1" /></td> 

	<td bgcolor="#ce6363"><img src="../img/pixel.gif"
				   class="spacer" width="1" 
				   height="1" /></td>
      </tr>

      <tr>
	<td colspan="2"
	    rowspan="2"><img
			     src="../img/adornos/borde-rojo-bottom-izda.gif"
			     width="6"
			     height="4" border="0" /></td>

	<td>
	  <!-- Esta celda controla la sombra por abajo: height=4 -
	  sombra --><img src="../img/pixel.gif" class="spacer"
			 width="1" height="1" /></td> 

	<td colspan="2"
	    rowspan="2"><img
			     src="../img/adornos/borde-rojo-bottom-dcha.gif"
			     width="6" height="4" border="0" /></td>
      </tr>

      <tr>
	<td bgcolor="#ce6363">
	  <!-- Esta celda controla la sombra por abajo: height=sombra
	  --><img src="../img/pixel.gif" class="spacer" width="1"
		  height="3" /></td> 
      </tr>
    </table>
  </xsl:template>

  <xsl:template match="author">
    <xsl:value-of select="firstname"/> <xsl:value-of select="surname"/>,
  </xsl:template>

  <xsl:template name="section">
    <p align="right">
      Sección: <a href=".html" target="content"></a>
    </p>
  </xsl:template>    

</xsl:stylesheet>