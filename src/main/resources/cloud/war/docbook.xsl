<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
		xmlns:db="http://docbook.org/ns/docbook"
		xmlns:tp="http://docbook.org/xslt/ns/template/private"
		xmlns:mp="http://docbook.org/xslt/ns/mode/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:raxm="http://docs.rackspace.com/api/metadata"
		exclude-result-prefixes="h f m fn db t ghost tp mp xs raxm"
		version="2.0">

  <xsl:import href="dist/xslt/base/html/docbook.xsl"/>
  <!-- 
  <xsl:import href="static-header.xsl"/>
  -->
  <xsl:import href="changebars.xsl"/>
	
  <xsl:include href="dist/xslt/base/html/chunktemp.xsl"/>
  
  <xsl:param name="IndexWar">/IndexWar</xsl:param>
  <xsl:param name="resource.root" select="concat($IndexWar,'/common/docbook/')"/>
  <xsl:param name="input.filename"/>
  <xsl:param name="use.id.as.filename" select="'1'"/>
  <!-- <xsl:param name="html.ext" select="'.jspx'"/> -->
  <xsl:param name="linenumbering" as="element()*">
  <!--  <ln xmlns="http://docbook.org/ns/docbook" path="literallayout" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>-->
    <!-- <ln xmlns="http://docbook.org/ns/docbook"  -->
    <!-- 	path="programlisting"  -->
    <!-- 	everyNth="2"  -->
    <!-- 	width="3"  -->
    <!-- 	separator=" "  -->
    <!-- 	padchar=" "  -->
    <!-- 	minlines="3"/> -->
    <!--<ln xmlns="http://docbook.org/ns/docbook" path="programlistingco" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="screen" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="synopsis" everyNth="2" width="3" separator=" " padchar=" " minlines="3"/>
    <ln xmlns="http://docbook.org/ns/docbook" path="address" everyNth="0"/>-->
    <ln xmlns="http://docbook.org/ns/docbook" path="epigraph/literallayout" everyNth="0"/>
  </xsl:param>

  <xsl:param name="toc.section.depth">1</xsl:param>
  <xsl:param name="chunk.section.depth">1</xsl:param>
	
	<xsl:param name="branding">not set</xsl:param>
	<xsl:param name="enable.disqus">0</xsl:param>
	<xsl:param name="disqus.shortname">
		<xsl:choose>
			<xsl:when test="$branding = 'test'">jonathan-test-dns</xsl:when>
			<xsl:when test="$branding = 'rackspace'">rc-api-docs</xsl:when>
			<xsl:when test="$branding = 'openstack'">openstackdocs</xsl:when>
			<xsl:when test="$branding = 'openstackextension'">openstackdocs</xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="use.version.for.disqus">0</xsl:param>
	<xsl:variable name="version.for.disqus">
		<xsl:choose>
			<xsl:when test="$use.version.for.disqus!='0'">
				<xsl:value-of select="translate(/*/db:info/db:releaseinfo[1],' ','')"/>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>       
	</xsl:variable>	
	<xsl:param name="use.disqus.id">1</xsl:param>
	<xsl:param name="feedback.email" select="f:pi(processing-instruction('rax'),'feedback.email')"/>
	

  <xsl:param name="base.dir" select="'target/docbkx/xhtml/example/'"/>

  <xsl:param name="preprocess" select="'profile normalize'"/>
  <xsl:param name="project.build.directory">/home/dcramer/rax/published/cloud-servers-2x-upstream/target</xsl:param>
  <xsl:param name="glossary.collection" select="concat($project.build.directory,'/mvn/com.rackspace.cloud.api/glossary/glossary.xml')"/>  

  <xsl:param name="security">external</xsl:param>
  <xsl:param name="root.attr.status"><xsl:if test="/*[@status = 'draft']">draft;</xsl:if></xsl:param>
  <xsl:param name="profile.security">
    <xsl:choose>
      <xsl:when test="$security = 'external'"><xsl:value-of select="$root.attr.status"/>external</xsl:when>
      <xsl:when test="$security = 'internal'"><xsl:value-of select="$root.attr.status"/>internal;external</xsl:when>
      <xsl:when test="$security = 'reviewer'"><xsl:value-of select="$root.attr.status"/>reviewer;internal;external</xsl:when>
      <xsl:when test="$security = 'writeronly'"><xsl:value-of select="$root.attr.status"/>reviewer;internal;external;writeronly</xsl:when>
      <xsl:when test="$security = 'external'"><xsl:value-of select="$root.attr.status"/>external</xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes"> 
	  ERROR: The value "<xsl:value-of select="$security"/>" is not valid for the security paramter. 
	         Valid values are: external, internal, reviewer, and writeronly. 
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="show.comments">
    <xsl:choose>
      <xsl:when test="$security = 'reviewer' or $security = 'writeronly'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>


  <xsl:param name="generate.toc" as="element()*">
    <tocparam xmlns="http://docbook.org/ns/docbook" path="appendix" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="article/appendix" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="article" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="book" toc="0" title="1" figure="1" table="1" example="1" equation="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="chapter" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="part" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="preface" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="qandadiv" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="qandaset" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="reference" toc="0" title="1"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect1" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect2" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect3" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect4" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="sect5" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="section" toc="0"/>
    <tocparam xmlns="http://docbook.org/ns/docbook" path="set" toc="0" title="1"/>
  </xsl:param>
  

<xsl:template name="t:system-head-content">
  <xsl:param name="node" select="."/>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <!-- system.head.content is like user.head.content, except that
       it is called before head.content. This is important because it
       means, for example, that <style> elements output by system-head-content
       have a lower CSS precedence than the users stylesheet. -->

  <!-- See http://remysharp.com/2009/01/07/html5-enabling-script/ -->
  <!--
  <xsl:comment>[if lt IE 9]>
&lt;script src="http://html5shim.googlecode.com/svn/trunk/html5.js">&lt;/script>
&lt;![endif]</xsl:comment>
  -->
</xsl:template>

<xsl:template name="t:javascript">
  <xsl:param name="node" select="."/>

  <xsl:if test="//db:annotation">
    <script type="text/javascript" src="{concat($resource.root, 'js/AnchorPosition.js')}">&#160;</script>
    <script type="text/javascript" src="{concat($resource.root, 'js/PopupWindow.js')}">&#160;</script>
    <script type="text/javascript" src="{concat($resource.root, 'js/annotation.js')}">&#160;</script>
  </xsl:if>

  <script type="text/javascript" src="{concat($resource.root, 'js/dbmodnizr.js')}">&#160;</script>
  
</xsl:template>

  <xsl:param name="docbook.css" select="''"/>

<xsl:param name="autolabel.elements">
  <db:refsection/>
</xsl:param>

  <xsl:template match="/" priority="10">
    <xsl:choose>
      <xsl:when test="$rootid = ''">
        <xsl:apply-templates select="$chunks" mode="m:chunk"/>
      </xsl:when>
      <xsl:when test="$chunks[@xml:id = $rootid]">
        <xsl:apply-templates select="$chunks[@xml:id = $rootid]" mode="m:chunk"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>There is no chunk with the ID: </xsl:text>
          <xsl:value-of select="$rootid"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <db:book/>
    
    <xsl:result-document 
        href="{$base.dir}/bookinfo.xml" 
        method="xml" indent="yes" encoding="UTF-8">
	<!--
    Here we write out the book info. It looks like this:		
    <products xmlns="">
        <product>
          <id>1</id>
          <types>
            <type>
              <id>1</id>
              <displayname>Legal notice</displayname>
              <url>/example/example-foo.html</url>
              <sequence>2</sequence> 
            </type>
            ...
          </types>     
        </product>
      </products>  
    	-->    
      
      <xsl:variable name="productid">
      	<xsl:choose>
      		<xsl:when test="//db:productname"><xsl:apply-templates select="//db:productname" mode="bookinfo"/></xsl:when>
      		<xsl:otherwise>1</xsl:otherwise>
      	</xsl:choose>
      </xsl:variable>
      
      <products xmlns="">
        <product>
          <!-- HACK...FIXME -->
          <id><xsl:value-of select="$productid"/></id>
           <types>
      <xsl:choose>
        <xsl:when test="$rootid = ''">
          <xsl:apply-templates select="$chunks" mode="bookinfo"/>
        </xsl:when>
        <xsl:when test="$chunks[@xml:id = $rootid]">
          <xsl:apply-templates select="$chunks[@xml:id = $rootid]" mode="bookinfo"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            <xsl:text>There is no chunk with the ID: </xsl:text>
            <xsl:value-of select="$rootid"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
           </types>
        </product>
      </products>
    </xsl:result-document>
    
    <xsl:result-document 
      href="{$base.dir}/WEB-INF/web.xml" 
      method="xml" indent="yes" encoding="UTF-8">
      <web-app version="2.4" xmlns="http://java.sun.com/xml/ns/j2ee"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="
        http://java.sun.com/xml/ns/j2ee  http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">
       <xsl:comment>Noop</xsl:comment>
      </web-app>
    </xsl:result-document>
    
  </xsl:template>
  
  <xsl:template match="*" mode="bookinfo">
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="processing-instruction('rax')">
          <xsl:value-of select="f:pi(processing-instruction('rax'),'type')"/>
        </xsl:when>
        <xsl:when test="ancestor::*[processing-instruction('rax')]">
          <xsl:value-of select="f:pi(ancestor::*[processing-instruction('rax')]/processing-instruction('rax')[1],'type')"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="idNumber">
      <xsl:choose>
        <xsl:when test="$type = 'concepts'">1</xsl:when>
        <xsl:when test="$type = 'apiref'">2</xsl:when>
        <xsl:when test="$type = 'advanced'">3</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="priority"><xsl:value-of select="f:pi(processing-instruction('rax'),'priority')"/></xsl:variable>
    
    <xsl:variable name="priorityCalculated">
      <xsl:choose>
        <xsl:when test="normalize-space($priority) != ''">
          <xsl:value-of select="normalize-space($priority)"/>
        </xsl:when>
        <xsl:otherwise>100000</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <type xmlns="">
      <id><xsl:value-of select="$idNumber"/></id>
      <displayname><xsl:value-of select="db:title|db:info/db:title"/></displayname>
      <url><xsl:value-of select="concat('/',$input.filename, '/', f:href(/,.))"/></url>
      <sequence><xsl:value-of select="$priorityCalculated"/></sequence> 
    </type>
  </xsl:template>

  <xsl:template match="db:productname" mode="bookinfo">
    <xsl:choose>
      <xsl:when test="preceding::db:productname"/>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Servers')">1</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Databases')">2</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Monitoring')">3</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Block Storage')">4</xsl:when>
      <xsl:when test="starts-with(normalize-space(.),'Cloud Files')">5</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>  
  </xsl:template>
  
  <xsl:template match="text()" mode="bookinfo"/>

  <xsl:template match="*" mode="m:chunk" priority="10">
    <xsl:variable name="chunkfn" select="f:chunk-filename(.)"/>
    
    <xsl:variable name="pinav"
      select="(f:pi(./processing-instruction('dbhtml'), 'navigation'),'true')[1]"/>
    
    <xsl:variable name="chunk" select="key('id', generate-id(.), $chunk-tree)"/>
    <xsl:variable name="nchunk" select="($chunk/following::h:chunk|$chunk/descendant::h:chunk)[1]"/>
    <xsl:variable name="pchunk" select="($chunk/preceding::h:chunk|$chunk/parent::h:chunk)[last()]"/>
    <xsl:variable name="uchunk" select="$chunk/ancestor::h:chunk[1]"/>
    
    <!--
    <xsl:message>Creating chunk: <xsl:value-of select="concat($base.dir,$chunkfn)"/></xsl:message>
    -->
    
    <xsl:result-document href="{$base.dir}{$chunkfn}" method="xhtml" indent="no">
      <html>
        <xsl:call-template name="t:head">
          <xsl:with-param name="node" select="."/>
        </xsl:call-template>
        <body  class="hybrid-home">

	  <!-- START HEADER -->
	  <div id="raxdocs-header">
	    <xsl:comment/>
	    <!--  
	    -->
	  </div>
	  <!-- END HEADER -->


			<div id="content-home-wrap">
				<div class="container_12">
					
					<div id="sidebar">
						<div id="treeDiv">
							<div id="ulTreeDiv">
								<ul id="tree" class="filetree">
									<xsl:apply-templates select="/*" mode="mp:toc">
<xsl:with-param name="toc-context" select="."/>
									</xsl:apply-templates>									  

								</ul>
							</div>
						</div>
					</div>

					<!-- END TOC -->

					<div id="main-content">
						
						<div class="page">
							<xsl:call-template name="t:body-attributes"/>
							<xsl:if test="@status">
								<xsl:attribute name="class" select="@status"/>
							</xsl:if>
							
							<div class="content">
								<xsl:if test="$pinav = 'true'">
									<xsl:call-template name="t:user-header-content">
										<xsl:with-param name="node" select="."/>
										<xsl:with-param name="next" select="key('genid', $nchunk/@xml:id)"/>
										<xsl:with-param name="prev" select="key('genid', $pchunk/@xml:id)"/>
										<xsl:with-param name="up" select="key('genid', $uchunk/@xml:id)"/>
									</xsl:call-template>
								</xsl:if>
								
								<div class="body">
								  
								  <h3>Tutorial: <xsl:apply-templates select="key('genid', $uchunk/@xml:id)" mode="m:object-title-markup"/></h3>
								  <xsl:apply-templates select="key('genid', $uchunk/@xml:id)" mode="beadbar">
								    <xsl:with-param name="current-node" select="generate-id(.)"/>
								  </xsl:apply-templates>
								  								  
									<xsl:apply-templates select=".">
										<xsl:with-param name="override-chunk" select="true()"/>
									</xsl:apply-templates>
								</div>
							</div>
							
							<xsl:if test="$pinav = 'true'">
								<xsl:call-template name="t:user-footer-content">
									<xsl:with-param name="node" select="."/>
									<xsl:with-param name="next" select="key('genid', $nchunk/@xml:id)"/>
									<xsl:with-param name="prev" select="key('genid', $pchunk/@xml:id)"/>
									<xsl:with-param name="up" select="key('genid', $uchunk/@xml:id)"/>
								</xsl:call-template>
							</xsl:if>
						</div>
					</div>					
				</div>
			</div>
        	
       
          <!-- BEGIN FOOTER -->
           
	  <div id="rax-footer">
	   <!-- 
	  -->
	  </div>
	  
	  <!-- END FOOTER -->
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>
  
  
  <xsl:template name="anchor">
    <xsl:param name="node" select="."/>
    <xsl:param name="force" select="0"/>
    
    <xsl:if test="$force != 0 or ($node/@id or $node/@xml:id)">
      <a name="{f:node-id($node)}" id="{f:node-id($node)}">&#160;</a>
    </xsl:if>
  </xsl:template>
  

<xsl:template name="t:user-head-content">
  <xsl:param name="node" select="."/>
  
<script type="text/javascript" src="http://rackspace.com/min/?g=js-header&amp;1332945039">&#160;</script>
<link rel="stylesheet" type="text/css" href="http://rackspace.com/min/?g=css&amp;1333990221"/>
<script type="text/javascript" src="{$IndexWar}/common/scripts/newformat.js">&#160;</script>
<link rel="stylesheet" type="text/css" href="{$IndexWar}/common/css/custom.css"/>
<link rel="stylesheet" type="text/css" href="{$IndexWar}/common/css/jquery-ui-1.8.2.custom.css"/>
<link rel="stylesheet" type="text/css" href="{$IndexWar}/common/css/jquery.treeview.css"/>
<link rel="stylesheet" type="text/css" href="{$IndexWar}/common/css/jquery.qtip.css"/>
<link rel="stylesheet" type="text/css" href="http://rackspace.com/min/?f=css/managed.rackspace.css"/>
<link rel="stylesheet" type="text/css" href="{$IndexWar}/common/css/newformat.css"/>
<link rel="stylesheet" type="text/css" href="{$IndexWar}/common/css/style-new.css"/>
<link rel="stylesheet" type="text/css" href="{$IndexWar}/common/css/rackspace-header1.css"/>
<script type="text/javascript" src="{$IndexWar}/common/scripts/docs.js">&#160;</script>
<script type="text/javascript" src="{$IndexWar}/common/scripts/rackspace-header2.js">&#160;</script>
<script type="text/javascript" src="{$IndexWar}/common/scripts/smartbutton.js">&#160;</script>
<script type="text/javascript" src="{$IndexWar}/common/scripts/munchkin.js">&#160;</script>


<script>
    $(function(){
	 $.getJSON("<xsl:value-of select="$IndexWar"/>/IndexServlet?headerfooter=1",{"headerfooter" : "1"},function(data){
		 getHeader(data);
	 });
    });
  </script><script>
    $(function(){
	 $.getJSON("<xsl:value-of select="$IndexWar"/>/IndexServlet?headerfooter=2",{"headerfooter" : "2"},function(data){
		 getFooter(data);
	 });
     });
  </script>  

</xsl:template>

	<!-- Overriding this so I can add the preferred classes and ids -->
	<xsl:template name="tp:make-toc">
		<xsl:param name="toc-context" select="."/>
		<xsl:param name="toc.title" select="true()"/>
		<xsl:param name="nodes" select="()"/>
		
		<xsl:variable name="toc.title">
			<xsl:if test="$toc.title">
				<p>
					<b>
						<xsl:call-template name="gentext">
							<xsl:with-param name="key">TableofContents</xsl:with-param>
						</xsl:call-template>
					</b>
				</p>
			</xsl:if>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$manual.toc != ''">
				<xsl:variable name="id" select="f:node-id(.)"/>
				<xsl:variable name="toc" select="document($manual.toc, .)"/>
				<xsl:variable name="tocentry" select="$toc//db:tocentry[@linkend=$id]"/>
				<xsl:if test="$tocentry and $tocentry/*">
					<div class="ulTreeDiv">
						<xsl:copy-of select="$toc.title"/>
						<ul id="tree" class="filetree">
							<xsl:call-template name="t:manual-toc">
								<xsl:with-param name="tocentry" select="$tocentry/*[1]"/>
							</xsl:call-template>
						</ul>
					</div>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$nodes">
					<div class="ulTreeDiv">
						<xsl:copy-of select="$toc.title"/>
						<ul id="tree" class="filetree">
							<xsl:apply-templates select="$nodes" mode="mp:toc">
								<xsl:with-param name="toc-context" select="$toc-context"/>
							</xsl:apply-templates>
						</ul>
					</div>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="t:user-footer-content">
		<xsl:param name="node" select="."/>
		<xsl:param name="next" select="()"/>
		<xsl:param name="prev" select="()"/>
		<xsl:param name="up" select="()"/>
		
		<xsl:variable name="nextfile"/>
			
	  <img src="{$IndexWar}/common/images/BigTutorialArrow.png" class="bigtutorialarrow"/>
	  <div class="bigtypeprogress">Success!</div>
		<br/>
	  <br/>

		<div id="prevnextbuttons">
			<xsl:if test="$prev">
			<div id = "previouslink">
				<span id="previousbutton">
					<a>
						<xsl:attribute name="href">
							<xsl:choose>
								<xsl:when test="$prev and not($prev = $node)">
									<xsl:value-of select="f:href(/,$prev[1])"/>
								</xsl:when>
								<xsl:otherwise>#</xsl:otherwise>
							</xsl:choose>	
						</xsl:attribute>
						&lt;&#160;Previous
					</a>
				</span>
				<span id="previouschunk">
					<xsl:apply-templates select="$prev" mode="m:object-title-markup"/>
				</span>
			</div>
			</xsl:if>
			<xsl:if test="$next">
				<div id="nextlink">
				<span id="nextbutton">
					<a>
						<xsl:attribute name="href">
							<xsl:choose>
								<xsl:when test="$next and not($next = $node)">
								<xsl:value-of select="f:href(/,$next[1])"/>
								</xsl:when>
								<xsl:otherwise>#</xsl:otherwise>
							</xsl:choose>							
						</xsl:attribute>
						Next&#160;&gt;
					</a>
				</span>
				<span id="nextchunk">
					<xsl:apply-templates select="$next" mode="m:object-title-markup"/>
				</span>
			</div>
			</xsl:if>
		</div>
		
		<xsl:if test="$enable.disqus!='0' and (//db:section[not(@xml:id)] or //db:chapter[not(@xml:id)] or //db:part[not(@xml:id)] or //db:appendix[not(@xml:id)] or //db:preface[not(@xml:id)] or /*[not(@xml:id)])">
			<xsl:message terminate="yes"> 
				<xsl:for-each select="//db:section[not(@xml:id)]|//db:chapter[not(@xml:id)]|//db:part[not(@xml:id)]|//db:appendix[not(@xml:id)]|//db:preface[not(@xml:id)]|/*[not(@xml:id)]">
					ERROR: The <xsl:value-of select="local-name()"/> "<xsl:value-of select=".//db:title[1]"/>" is missing an id.
				</xsl:for-each>
				When Disqus comments are enabled, the root element and every part, chapter, appendix, preface, and section must have an xml:id attribute.
			</xsl:message>
		</xsl:if>
		
		<!-- Alternate location for SyntaxHighlighter scripts -->
		
		
<!--		<script type="text/javascript" src="../common/main.js">
            <xsl:comment></xsl:comment>
        </script>-->
		
		<xsl:if test="$enable.disqus != '0'">
			<hr />
			<xsl:choose>
				<xsl:when test="$enable.disqus = 'intranet'">
					<xsl:if test="$feedback.email =''">
						<xsl:message terminate="yes">
							ERROR: Feedback email not set but internal comments are enabled.
						</xsl:message>
					</xsl:if>
					<script language="JavaScript" src="/comments.php?email={$feedback.email}" type="text/javascript"><xsl:comment/></script>
					<noscript>You must have JavaScript enabled to view and post comments.</noscript>
				</xsl:when>
				<xsl:otherwise>
					
					<div id="disqus_thread">
						<script type="text/javascript">
	      var disqus_shortname = '<xsl:value-of select="$disqus.shortname"/>';
	      <xsl:if test="$use.disqus.id != '0'">
	      var disqus_identifier = '<xsl:value-of select="/*/@xml:id"/><xsl:value-of select="$version.for.disqus"/><xsl:value-of select="@xml:id"/>';
	      </xsl:if>
	    </script>
						<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
						<script type="text/javascript" src="../common/comments.js"><xsl:comment/></script>
					</div>	  
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		
		
	</xsl:template>

	<!-- ======================================== -->
	<!-- Customized from html/autotoc.xsl         -->
	<!-- Adding id="currentchapter" to <li> so we -->
	<!-- can style it.                            -->
	<!-- ======================================== -->
<xsl:template name="tp:subtoc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="nodes" select="()"/>

  <xsl:variable name="subtoc" as="element()">
    <ul class="toc">
      <xsl:apply-templates mode="mp:toc" select="$nodes">
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:apply-templates>
    </ul>
  </xsl:variable>

  <xsl:variable name="depth" as="xs:integer">
    <xsl:choose>
      <xsl:when test="self::db:section">
        <xsl:value-of select="count(ancestor::db:section) + 1"/>
      </xsl:when>
      <xsl:when test="self::db:sect1">1</xsl:when>
      <xsl:when test="self::db:sect2">2</xsl:when>
      <xsl:when test="self::db:sect3">3</xsl:when>
      <xsl:when test="self::db:sect4">4</xsl:when>
      <xsl:when test="self::db:sect5">5</xsl:when>
      <xsl:when test="self::db:refsect1">1</xsl:when>
      <xsl:when test="self::db:refsect2">2</xsl:when>
      <xsl:when test="self::db:refsect3">3</xsl:when>
      <xsl:when test="self::db:simplesect">
	<!-- sigh... -->
	<xsl:choose>
	  <xsl:when test="parent::db:section">
            <xsl:value-of select="count(ancestor::db:section)"/>
          </xsl:when>
          <xsl:when test="parent::db:sect1">2</xsl:when>
          <xsl:when test="parent::db:sect2">3</xsl:when>
          <xsl:when test="parent::db:sect3">4</xsl:when>
          <xsl:when test="parent::db:sect4">5</xsl:when>
          <xsl:when test="parent::db:sect5">6</xsl:when>
          <xsl:when test="parent::db:refsect1">2</xsl:when>
          <xsl:when test="parent::db:refsect2">3</xsl:when>
          <xsl:when test="parent::db:refsect3">4</xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="depth.from.context"
		select="count(ancestor::*)-count($toc-context/ancestor::*)"/>

  <xsl:variable name="subtoc.list" select="$subtoc"/>

  <xsl:variable name="show.subtoc" as="xs:boolean"
		select="count($subtoc/*) &gt; 0
			and $toc.section.depth > $depth and exists($nodes)
			and $toc.max.depth > $depth.from.context"/>

  <li>
    <xsl:if test="f:href(/,.) = f:href(/,$toc-context)">
      <xsl:attribute name="id">currentchapter</xsl:attribute>
    </xsl:if>

    <xsl:call-template name="tp:toc-line">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
    <xsl:if test="$show.subtoc">
      <xsl:copy-of select="$subtoc.list"/>
    </xsl:if>
  </li>
</xsl:template>
	<!-- ======================================== -->
	<!-- End of autotoc.xsl customization         -->
	<!-- ======================================== -->

  <xsl:template match="*" mode="beadbar">
    <xsl:param name="current-node"/>
    <div class="progressindicator">
      <xsl:apply-templates select="db:section" mode="beadbar-steps">
        <xsl:with-param name="current-node" select="$current-node"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="db:section" mode="beadbar-steps">
    <xsl:param name="current-node"/>

    <xsl:variable name="gray">
      <xsl:choose>
        <xsl:when test="following-sibling::db:section[generate-id(.) = $current-node] or generate-id(.) = $current-node"/>
        <xsl:otherwise>gray</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
    <xsl:when test="position() &lt; 6">
    <div>
      <xsl:attribute name="id">
        <xsl:value-of select="concat('step',position() - 1)"/>
      </xsl:attribute>
     <xsl:choose>
       <xsl:when test="position() = 1">
         <a href="{f:href(/,.)}">
          <span class="firstbead"><img src="{$IndexWar}/common/images/bead.png"/></span>
          <span class="firststeptext  currentstep">
             <xsl:attribute name="class">
               <xsl:choose>
                 <xsl:when test="$current-node = generate-id(.)">firststeptext currentstep</xsl:when>
                 <xsl:otherwise>firststeptext</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="." mode="m:object-title-markup"/></span>
           </a>
       </xsl:when>
       <xsl:otherwise>
         <span class="stepline"><img class="stepline" src="{$IndexWar}/common/images/line{$gray}.png"/></span>
         <span class="stepbead"><a href="{f:href(/,.)}"><img src="{$IndexWar}/common/images/bead{$gray}.png"/></a></span>
         <span class="steptext">
           <xsl:attribute name="class">
             <xsl:choose>
               <xsl:when test="$current-node = generate-id(.)">steptext currentstep</xsl:when>
               <xsl:otherwise>steptext</xsl:otherwise>
             </xsl:choose>
           </xsl:attribute>
           <a href="{f:href(/,.)}"><xsl:apply-templates select="." mode="m:object-title-markup"/></a></span>
       </xsl:otherwise>
     </xsl:choose> 
    </div>
    </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!          
WARNING: No more than five steps are allowed in a tutorial.
         Step number <xsl:value-of select="position()"/> truncated. 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
