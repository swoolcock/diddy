Strict

Import diddy.xml

Function Main:Int()
	Local parser:XMLParser = New XMLParser
	Local doc:XMLDocument = parser.ParseString(LoadString("server.xml"))
	'Local doc:XMLDocument = parser.ParseString("<?xml version=~q1.0~q encoding=~qUTF-8~q?><Server port=~q8005~q shutdown=~qSHUTD&amp;&lt;OWN~q>  <Listener className=~qorg.apache.catalina.core.AprLifecycleListener~q/>  <Listener className=~qorg.apache.catalina.mbeans.ServerLifecycleListener~q/>  <Listener className=~qorg.apache.catalina.mbeans.GlobalResourcesLifecycleListener~q/>  <Listener className=~qorg.apache.catalina.storeconfig.StoreConfigLifecycleListener~q/>  <GlobalNamingResources>    <Environment name=~qsimpleValue~q type=~qjava.lang.Integer~q value=~q30~q/>    <Resource auth=~qContainer~q driverClassName=~qoracle.jdbc.OracleDriver~q maxActive=~q20~q maxIdle=~q10~q maxWait=~q-1~q name=~qjdbc/tmsicsd~q password=~qpndev~q type=~qjavax.sql.DataSource~q url=~qjdbc:oracle:thin:@//pnlvsun30:9086/TMSV10D~q username=~qtms_own~q/>    <Resource auth=~qContainer~q driverClassName=~qoracle.jdbc.OracleDriver~q maxActive=~q20~q maxIdle=~q10~q maxWait=~q-1~q name=~qjdbc/tmsicss~q password=~qTMSS1TS~q type=~qjavax.sql.DataSource~q url=~qjdbc:oracle:thin:@//pnlvsun30:9186/TMSV10S~q username=~qTMS_OWN~q/>  </GlobalNamingResources>  <Service name=~qCatalina~q>    <Connector acceptCount=~q100~q connectionTimeout=~q20000~q disableUploadTimeout=~qtrue~q enableLookups=~qfalse~q maxHttpHeaderSize=~q8192~q maxSpareThreads=~q75~q maxThreads=~q150~q minSpareThreads=~q25~q port=~q8080~q redirectPort=~q8443~q/>    <Connector enableLookups=~qfalse~q port=~q8009~q protocol=~qAJP/1.3~q redirectPort=~q8443~q/>    <Engine defaultHost=~qlocalhost~q name=~qCatalina~q>      <Host appBase=~qwebapps~q autoDeploy=~qtrue~q name=~qlocalhost~q unpackWARs=~qtrue~q xmlNamespaceAware=~qfalse~q xmlValidation=~qfalse~q>        <Context docBase=~qFreightWeb~q path=~q/FreightWeb~q reloadable=~qtrue~q source=~qorg.eclipse.jst.j2ee.server:FreightWeb~q>          <!--<ResourceLink global=~qjdbc/tmsicsd~q name=~qjdbc/pnonline~q type=~qjavax.sql.DataSource~q/>-->          <ResourceLink global=~qjdbc/tmsicsd~q name=~qjdbc/pnonline~q type=~qoracle.jdbc.pool.OracleDataSource~q/>          <!-- <ResourceLink global=~qjdbc/tmsicss~q name=~qjdbc/pnonline~q type=~qjavax.sql.DataSource~q/> -->        </Context>      <Context docBase=~qPNOnline~q path=~q/PNOnline~q reloadable=~qtrue~q source=~qorg.eclipse.jst.j2ee.server:PNOnline~q/></Host>    </Engine>  </Service></Server>")
	Print doc.root.GetAttribute("shutdown")
	Print doc.root.Children.Get(0).Parent.Name
	Print doc.ExportString()
#Rem
	Local doc:XMLDocument = New XMLDocument
	doc.root = New XMLElement
	doc.root.name = "root"
	
	Local child1 := New XMLElement
	child1.name = "mychild"
	child1.SetAttribute("foo", "bar")
	child1.SetAttribute("hello", "world")
	doc.root.AddChild(child1)
	
	Local child2 := New XMLElement
	child2.name = "mychild"
	child2.SetAttribute("david", "jones")
	child2.SetAttribute("harvey", "norman")
	doc.root.AddChild(child2)
	
	Print(doc.ExportString())
	Print(doc.ExportString(False))
	Return 0
#End
End




