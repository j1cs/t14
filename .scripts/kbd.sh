#!/usr/bin/bash

display='wayland'; bar='_'
[[ -z "${WAYLAND_DISPLAY}" ]] && display='xorg'; bar='─'
icon="notification-keyboard-brightness"
notify=`which dunstify`
replace_file=/tmp/kbd-notification-$display
dev=sysfs/leds/tpacpi::kbd_backlight

function get_kbd {
    val=$(light -Grs $dev)
    if [ $val = "0" ]; then
	    echo 0
    elif [ $val = "1" ]; then
	    echo 30
    else
	    echo 60
    fi
}

function get_bar {
    kbd=`get_kbd`
    res=$(seq -s "$bar" $(($kbd / 2)) | sed 's/[0-9]//g')
    if [ -z $res ] || [ $res = "1" ]; then
	printf '%s' '""'
    else
	echo $res
    fi
}

function kbd_notification {
    kbd=`get_kbd`
    bar=`get_bar`
    if [ ! -s $replace_file ]
    then
        exec $notify --printid -u normal -i $icon $bar > $replace_file
    else
        exec $notify -r `cat $replace_file` -u normal -i $icon $bar
    fi
}

case $1 in
    up)
        light -Ars $dev 1
        kbd_notification
        ;;
    down)
        light -Urs $dev 1
        kbd_notification
	    ;;
    *)
        echo "Usage: $0 up | down"
        ;;
esac
