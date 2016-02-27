#Ubuntu Studio
Out="LINUX"
Name="Ubuntu Studio"

if [ $Arch -eq 1 ]
then
	URL="http://cdimage.ubuntu.com/ubuntustudio/releases/14.04.4/release/ubuntustudio-14.04.4-dvd-i386.iso"
	Append="32-bit"
elif [ $Arch -eq 2 ]
then
	URL="http://cdimage.ubuntu.com/ubuntustudio/releases/14.04.4/release/ubuntustudio-14.04.4-dvd-amd64.iso"
	Append="64-bit"
fi
Post=0
