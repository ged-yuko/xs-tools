How to use these XSLT transformations during build process via VS:

Ensure you have XSLT-processor on your build-machine.

The example uses msxsl.exe as XSLT-processor, but the solution can be easily adapted for any other similar utility.

Use following set of commands in pre-build step of your project:
 - call VS Development Environment configuration script to make xsd.exe available;
 - execute transformation to expand complex content groups which couldn't be processed by xsd.exe in a certain situations;
 - execute xsd.exe to generate XML-serializable classes based on expanded version of your XSD-schema, generated during previous step;
 - execute transformation to prepare visitor interfaces and backing partial classes to support OO-style analysis of deserialized classes.

Example pre-build script:
call "$(DevEnvDir)..\Tools\VsDevCmd.bat"

msxsl.exe $(ProjectDir)schema.xsd $(ProjectDir)expandGroups.xslt -o $(ProjectDir)schema.expanded.xsd
xsd /c $(ProjectDir)schema.expanded.xsd /o:$(ProjectDir)\
msxsl.exe $(ProjectDir)schema.xsd $(ProjectDir)expandVisitors.xslt -o $(ProjectDir)schema_visitors.cs

Note that xsd.exe always uses nearest common base class for a members implementing choose groups. So don't forget to explicitly define base complex type for all choice member types.


