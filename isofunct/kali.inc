#Kali Linux
Out="LINUX"
Name="Kali Linux"

if [ "$Arch" = 1 ]
then
	URL="http://cdimage.kali.org/kali-2016.1/kali-linux-2016.1-i386.iso"
	Append="32-bit"
elif [ "$Arch" = 2 ]
then
	URL="http://cdimage.kali.org/kali-2016.1/kali-linux-2016.1-amd64.iso"
	Append="64-bit"
fi
Post=0
