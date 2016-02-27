#!/bin/bash
### Variables
Norm=`pwd`
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
	read -n 1 -p "Choice: " Arch;echo
	if [ "$Arch" = "" ]
	then
		Arch=2
	fi
}
sleepydot()
{
	sleep 1
	echo -n "."
	sleep 1
	echo -n "."
	sleep 1
	echo "."
}
stats()
{
	numfmt --to=iec-i --suffix=B --format="Size: %f" $Size
	numfmt --to=iec-i --suffix=B --format="Temp Space: %f" $TAvail
	numfmt --to=iec-i --suffix=B --format="Drive Space: %f" $DAvail
}
pfilter()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%c' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}
retrieve()
{
	cd "$Temp"
	echo "Downloading..."
	wget --progress=bar:force "$1" 2>&1 | pfilter
	if [ "$Post" = 0 ]
	then
		mv * "${Root}/_ISO/${2}/${3}.iso"
	else
		find . -type f -exec mv '{}' ./compressed \;
		echo "Extracting..."
		eval $4 ./compressed &> /dev/null
		rm compressed
		dest="${Root}/_ISO/${2}/${3}.iso"
		find . -iname '*.iso' -exec mv '{}' "$dest" \;
	fi
	cd "$Norm"
	rm -r "$Temp"&&mkdir "$Temp"
	echo -n "DONE"
	sleepydot
}
sufficient()
{
	DAvail=`stat -f --printf="%a * %s\n" "$Root" | bc`
	TAvail=`stat -f --printf="%a * %s\n" "$Temp" | bc`
	Size=`curl -sIL $1 | grep -i Content-Length | awk '{print $2}' | tr -d '\r'`
	if [ "$DAvail" -le "$Size" ] || [ "$TAvail" -le "$Size" ]
	then
		return 1
	else
		return 0
	fi
}

init
for i in isofunct/*.inc
do
	clear
	section=`head -n 1 "$i" | sed 's/#//'`
	. $i
	echo "$section"
	if sufficient "$URL"
	then
		stats
		read -n 1 -p "Install? [y/n] " inst;echo
		if [ "$inst" = "y" ]
		then
			retrieve "$URL" "$Out" "$Name" "$Post"
		fi
	else
		stats
		echo -n "Insufficient space, skipping"
		sleepydot
	fi
done
echo "Cleaning up... "
rm -r "$Temp"
echo "DONE"
