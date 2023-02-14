setlocal EnableDelayedExpansion

for %%F in (%0) do (
	set toolPath=%%~dpF
)

set xsdTool=xsd
set xslTool=%toolPath%msxsl.exe
set getNsNameTool=%toolPath%getNsName.bat

set expandGroupsXslt=%toolPath%expandGroups.xslt
set expandVisitorsXslt=%toolPath%expandVisitors.xslt

set inputSchemaXsd=%1

for %%F in (%1) do (
	set location=%%~dpF
	set schemaName=%%~nF
	set schemaNamePath=%%~dpnF
)

set outputSchemaXsd=%schemaNamePath%_expanded.xsd
set outputClassesCs=%schemaNamePath%_expanded.cs
set outputVisitorsCs=%schemaNamePath%_visitors.cs

for /f "tokens=* delims=" %%# in ('%getNsNameTool% "%inputSchemaXsd%"') do set "nsName=%%#"
echo NAMESPACE: %nsName%

%xslTool% %inputSchemaXsd% %expandGroupsXslt% -o %outputSchemaXsd%
%xslTool% %inputSchemaXsd% %expandVisitorsXslt% -o %outputVisitorsCs%
%xsdTool% /c %outputSchemaXsd% /n:%nsName% /o:%location%

