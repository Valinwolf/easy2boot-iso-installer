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
ProgressBar()
{
	let _progress=(${1}*100/${2}*100)/100
	let _done=(${_progress}*4)/10
	let _left=40-$_done
	_fill=$(printf "%${_done}s")
	_empty=$(printf "%${_left}s")
	printf "\r${_progress}%% [${_fill// /=}${_empty// /-}]"
}
pmv()
{
	echo "Preparing to move..."
	orig_size=$(stat -c %s $1)
	dest_size=0
	echo "Moving..."
	mv "$1" "$2" &
	pid=$!
	while [ $orig_size -gt $dest_size ]
	do
		if kill -0 $pid
		then
			dest_size=$(stat -c %s $2)
			pct=$((( 100 * $dest_size ) / $orig_size ))
			ProgressBar $pct 100
		else
			echo
			echo "It seems mv died."
			echo "This means it either failed or finished between checks. Be sure to check the integrity of the file."
			return 1
		fi
		sleep 0.5
	done
	echo
	return 0
}
retrieve()
{
	cd "$Temp"
	echo "Downloading..."
	wget -O download "$1" --progress=bar:force 2>&1 | pfilter
	if [ "$Post" = 0 ]
	then
		pmv download "${Root}/_ISO/${2}/${3}.iso"
	else
		echo "Extracting..."
		eval $4 ./download &> /dev/null
		rm download
		dest="${Root}/_ISO/${2}/${3}.iso"
		find . -iname '*.iso' -exec pmv '{}' "$dest" \;
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
