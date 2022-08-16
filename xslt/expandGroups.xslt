<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="msxsl #default xs"
                id="expandGroupsTransform"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt">

  <xsl:output method="xml" indent="yes" />

  <xsl:template match="*">
    <xsl:element name="{concat('xs:',local-name())}" >
      <xsl:for-each select="@*">
        <xsl:attribute name="{local-name()}">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each> 
      <xsl:if test="count(./*)!=0">
        <xsl:apply-templates/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/xs:schema" >
    <xsl:copy>
      <!--<xsl:copy-of select=".//namespace::*"/>-->
      <xsl:copy-of select="./@*"/>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//xs:complexType//xs:group">
    <xsl:variable name="groupName" select="./@ref" />
    <xsl:variable name="minOccurs" select="./@minOccurs" />
    <xsl:variable name="maxOccurs" select="./@maxOccurs" />
    <xsl:variable name="groupExpansion">
        <xsl:apply-templates select="/xs:schema/xs:group[@name=$groupName]/*" />
    </xsl:variable>
    <xsl:for-each select="msxsl:node-set($groupExpansion)/*">
      <xsl:element name="{name(.)}">
        <xsl:copy-of select="$minOccurs" />
        <xsl:copy-of select="$maxOccurs" /> 
        <xsl:copy-of select="./*" />
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
