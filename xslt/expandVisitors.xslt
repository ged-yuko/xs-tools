<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="msxsl #default"
                id="expandVisitorsTransform"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:u="http://tempuri.org/expandUtils.xsd"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt">

  <xsl:output method="text" omit-xml-declaration="yes" indent="yes" />

  <xsl:template match="@* | node()">
      <xsl:apply-templates select="@* | node()"/>
  </xsl:template>

  <xsl:template match="/xs:schema" >
    <xsl:variable name="modelNsName" select="./@u:modelNamespace" />
    
namespace <xsl:value-of select="$modelNsName"/>
{
      <xsl:apply-templates select="@* | node()"/>
}
  </xsl:template>

  <xsl:template match="/xs:schema/xs:complexType[@abstract='true' and count(./xs:complexContent/xs:extension)=0]">
    <xsl:variable name="baseName" select="./@name" />
    <xsl:variable name="visitorName" select="(concat('I', $baseName,'Visitor'))" />
    
    public interface <xsl:value-of select="$visitorName" />&lt;TArg, TRet&gt;
    {
      <xsl:call-template name="expandVisitorMethods">
        <xsl:with-param name="baseName" select="$baseName" />
      </xsl:call-template>
    }

    abstract partial class <xsl:value-of select="$baseName" />
    {
        public TRet Apply&lt;TArg, TRet&gt;(<xsl:value-of select="$visitorName" />&lt;TArg, TRet&gt; visitor, TArg arg)
        {
            return this.ApplyImpl&lt;TArg, TRet&gt;(visitor, arg);
        }

        protected abstract TRet ApplyImpl&lt;TArg, TRet&gt;(<xsl:value-of select="$visitorName" />&lt;TArg, TRet&gt; visitor, TArg arg);
    }

    <xsl:call-template name="expandChildClasses">
      <xsl:with-param name="baseName" select="$baseName" />
      <xsl:with-param name="visitorName" select="$visitorName" />
  </xsl:call-template>
  </xsl:template>

  <xsl:template name="expandVisitorMethods">
    <xsl:param name="baseName" />
    <xsl:variable name="childs" select="/xs:schema/xs:complexType[(./xs:complexContent/xs:extension[@base=$baseName])]" />
    <xsl:for-each select="$childs" >
      <xsl:variable name="currName" select="./@name" />
      <xsl:if test="not(@abstract='true')">
        TRet Visit<xsl:value-of select="$currName" />(<xsl:value-of select="$currName" /> node, TArg arg);
      </xsl:if>
      <xsl:call-template name="expandVisitorMethods">
        <xsl:with-param name="baseName" select="$currName" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  
  <xsl:template name="expandChildClasses">
    <xsl:param name="baseName" />
    <xsl:param name="visitorName" />
    <xsl:variable name="childs" select="/xs:schema/xs:complexType[(./xs:complexContent/xs:extension[@base=$baseName])]" />
    <xsl:for-each select="$childs" >
      <xsl:variable name="currName" select="./@name" />
      <xsl:if test="not(@abstract='true')">
    partial class <xsl:value-of select="$currName" />
    {
        protected override TRet ApplyImpl&lt;TArg, TRet&gt;(<xsl:value-of select="$visitorName" />&lt;TArg, TRet&gt; visitor, TArg arg)
        {
            return visitor.Visit<xsl:value-of select="$currName" />(this, arg);
        }
    }
      </xsl:if>
      <xsl:call-template name="expandChildClasses">
        <xsl:with-param name="baseName" select="$currName" />
        <xsl:with-param name="visitorName" select="$visitorName" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
