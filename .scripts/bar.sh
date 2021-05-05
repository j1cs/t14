#!/bin/bash

# Strict script
#set -e causes the shell to exit when an unguarded statement evaluates to a false value (i have to disable because of cap lock function)
set -u
#set -x

hdd(){
	hdd="`df -h | awk 'NR==5{print $5}'`"
	echo -e "+@fg=7;+@fg=0; $hdd"
}


mem() {
	mem=`free | awk '/Mem/ {printf "%d%\n",$3/$2 *100}'`
	printf "+@fg=7;+@fg=0; %s" `echo "$mem"`
}

bri(){
	brightness=`light`
	value=`printf "%.0f" $brightness`
	if [ $value -gt 70 ]; then
		display="+@fg=0;+@fg=0;"
	elif [ $value -eq 0 ]; then
		display="+@fg=8;+@fg=0;"
	elif [ $value -lt 30 ]; then
		display="+@fg=7;+@fg=0;"
	else
		display="+@fg=7;+@fg=0;"
	fi
	printf "$display %.0f%%" `echo "$brightness"`
}

cpu() {
	read cpu a b c previdle rest < /proc/stat
  	prevtotal=$((a+b+c+previdle))
  	sleep 0.5
  	read cpu a b c idle rest < /proc/stat

	total=$((a+b+c+idle))
 	cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
	printf "+@fg=7;+@fg=0; %s%%" `echo "$cpu"`

}

vol(){
	vol=`pacmd list-sinks | awk '/\tvolume:/ { print $5 }'  | tail -n1 | cut -d '%' -f 1`
	muted=`pacmd list-sinks | awk '/muted/ { print $2 }' | head -n1`

    if [ $muted == 'yes' ]
    then
		printf "+@fg=7;+@fg=0; muted"
    else
		if [ $vol -gt 70 ]; then
			icon=""
		elif [ $vol -eq 0 ]; then
			icon=""
		elif [ $vol -lt 30 ]; then
			icon=""
		else
			icon=""
		fi
		printf "+@fg=7;$icon+@fg=0; %s%%" `echo "$vol"`
    fi
}

mic(){
	source=`pactl list short sources | grep input | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,'`
	mic=`pactl list sources | grep -A 10 -w "Source #$source" | grep '^[[:space:]]Volume:' | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'`
	mute=`pactl list sources | grep '^[[:space:]]Mute:' | tail -n 1 | awk '{ print $2 }'`
    if [ "$mute" = "yes" ]; then
		printf "+@fg=7;+@fg=0; muted"
    else
		printf "+@fg=7;+@fg=0; %s%%" `echo "$mic"`
    fi
}

dte() {
	dte=" `date +"%Y-%m-%d"`  `date +"%H:%M"`"
	echo -e "$dte"
}

bat() {
	current=`cat /sys/class/power_supply/BAT$2/capacity`
	status=`cat /sys/class/power_supply/BAT$2/status`


	if [ $status = "Full" ]; then
		printf "+@fg=5; +@fg=0;100%"
	fi
	if [ $status = "Unknown" ]; then
		if [ $current -eq 100 ]; then
			icon="+@fg=5;+@fg=0;"
		elif [ $current -gt 60 ]; then
			icon="+@fg=5;+@fg=0;"
		elif [ $current -gt 50 ]; then
			icon="+@fg=4;+@fg=0;"
		elif [ $current -gt 25 ]; then
			icon="+@fg=4;+@fg=0;"
		else
			icon="+@fg=6;+@fg=0;"
		fi
		printf "$icon %s%%" `echo "$current" | bc`
	fi
	if [ $status = "Discharging" ]; then
		if [ $current -eq 100 ]; then
			icon="+@fg=5;+@fg=0;"
		elif [ $current -gt 60 ]; then
			icon="+@fg=5;+@fg=0;"
		elif [ $current -gt 50 ]; then
			icon="+@fg=4;+@fg=0;"
		elif [ $current -gt 25 ]; then
			icon="+@fg=4;+@fg=0;"
		else
			icon="+@fg=6;+@fg=0;"
		fi
		printf "$icon %s%%" `echo "$current" | bc`
	fi

	if [ $status = "Charging" ]; then
		if [ $1 -eq 4 ]; then
			icon=""
		elif [ $1 -eq 3 ]; then
			icon=""
		elif [ $1 -eq 2 ]; then
			icon=""
		elif [ $1 -eq 1 ]; then
			icon=""
		else
			icon=""
		fi
		printf "+@fg=4;$icon+@fg=0; %s%%" `echo "$current" | bc`
	fi

}

layout() {
	lay_result="`xset -q | grep -i "led mask" | grep -o "....1..."`"
	lay="`[ -z $lay_result ] && echo "latam" || echo "es"`"
	echo -e " $lay"
}

lock() {
	cap_result=`xset q | grep -q 'Caps Lock: *on'`
	cap="`[ $? == 0 ] && echo " a" || echo ""`"
	num_result=`xset q | grep -q 'Num Lock: *on'`
	num="`[ $? == 0 ] && echo " 1" || echo ""`"
	echo -e "+@fg=7;$cap+@fg=0;+@fg=7;$num+@fg=0;"
}


SLEEP_SEC=0.1
I=0
BAT_ITER=4
while :; do
	if [ $I -gt $BAT_ITER ]; then
		I=0
	fi
	echo "`hdd`  `vol`  `mic`  `bri`  `layout` `bat $I 0` `lock`  `dte`"
	I=`expr $I + 1`
	sleep $SLEEP_SEC
done
