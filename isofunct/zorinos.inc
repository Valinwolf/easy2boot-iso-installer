#ZorinOS Core
Out="LINUX"
Name="ZorinOS Core"

if [ "$Arch" = 1 ]
then
	URL="http://downloads.sourceforge.net/project/zorin-os/9/zorin-os-9-core-32.iso"
	Append="32-bit"
elif [ "$Arch" = 2 ]
then
	URL="http://downloads.sourceforge.net/project/zorin-os/9/zorin-os-9.1-core-64.iso"
	Append="64-bit"
fi
Post=0
