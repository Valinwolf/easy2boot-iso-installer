#!/bin/bash
### Variables
Temp=`mktemp -d`
Root=/media/root/E2B
Arch=2
Post=0
Size=0
Append=""
URL=""
Out=""
DAvail=0
TAvail=0

### Helper Functions
init()
{
	read -p "Path to E2B drive: (Default = /media/root/E2B) " Root
	if [ "$Root" = "" ]
	then
		Root=/media/root/E2B
	fi
	cd Root
	echo
	echo " What Architecture?"
	echo "   1) 32-bit"
	echo "   2) 64-bit (Default)"
	read -p "Choice: " Arch
	if [ "$Arch" = "" ]
	then
		Arch=2
	fi
}
retrieve()
{
	rm -r "$Temp"&&mkdir "$Temp"
	cd "$Temp"
	wget -q "$1"
	if [ "$Post" = 0 ]
	then
		mv * "${Root}/_ISO/${2}/${3}.iso"
	else
		find . -type f -exec mv '{}' ./compressed \;
		eval $4 ./compressed
		rm compressed
		dest="${Root}/_ISO/${2}/${3}.iso"
		find . -iname '*.iso' -exec mv '{}' "$dest" \;
	fi
	cd "${Root}/_ISO"
}
sufficient()
{
	DAvail=`df "$Root"|tail -n 1|awk '{print $4}'`
	TAvail=`df "$Temp"|tail -n 1|awk '{print $4}'`
	Size=`curl -sI $1 | grep -i Content-Length | awk '{print $2}' | tr -d '\r'`
	if [ "$DAvail" -le "$Size" ]
	then
		echo "Insufficient space on install device..."
	elif [ "$TAvail" -le "$Size" ]
	then
		echo "Insufficient space in temporary folder..."
	else
		return 0
	fi
	return 1
}

init
for i in isofunct/*.inc
do
	clear
	section=`head -n 1 "$i" | sed 's/#//'`
	. $i
	echo "$section"
	numfmt --to=iec-i --suffix=B --format="Size: %f" $Size
	numfmt --to=iec-i --suffix=B --format="Temp Space: %f" $TAvail
	numfmt --to=iec-i --suffix=B --format="Drive Space: %f" $DAvail
	if sufficient "$URL"
	then
		read -n 1 -p "Install? [y/n] " inst
		if [ "$inst" = "y" ]
		then
			retrieve "$URL" "$Out" "$Name" "$Post"
		fi
	else
		echo "Skipping."
	fi
done
