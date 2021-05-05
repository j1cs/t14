#!/usr/bin/bash

# Volume notification: pipewire and dunst
display='wayland'; bar='_'
[[ -z "${WAYLAND_DISPLAY}" ]] && display='xorg'; bar='─'
icon_low="notification-display-brightness-low"
icon_med="notification-display-brightness-medium"
icon_high="notification-display-brightness-high"
icon_full="notification-display-brightness-full"
icon_off="notification-display-brightness-off"
notify=`which dunstify`
replace_file=/tmp/brightness-notification-$display

function get_brightness {
    printf "%.0f\n" $(light -G / 1)
}

function get_brightness_icon {
    if [ "$1" -lt 0 ]
    then
        echo -n $icon_off
    elif [ "$1" -lt 25 ]
    then
        echo -n $icon_low
    elif [ "$1" -lt 50 ]
    then
        echo -n $icon_med
    elif [ "$1" -lt 75 ]
    then
        echo -n $icon_high
    elif [ "$1" -le 100 ]
    then
        echo -n $icon_full
    fi
}

function get_bar {
    brightness=`get_brightness`
    seq -s "$bar" $(($brightness / 5)) | sed 's/[0-9]//g'
}

function brightness_notification {
    brightness=`get_brightness`
    icon=`get_brightness_icon $brightness`
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
        light -A 5
        brightness_notification
        ;;
    down)
        light -U 5
        brightness_notification
	    ;;
    *)
        echo "Usage: $0 up | down"
        ;;
esac
