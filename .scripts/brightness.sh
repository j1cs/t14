#!/usr/bin/bash

# Volume notification: Pulseaudio and dunst
[[ -z "${WAYLAND_DISPLAY}" ]] && display='xorg'; bar='-' || display='wayland'; bar='_'
icon_path=/usr/share/icons/ePapirus/48x48/status/
icon_low="notification-display-brightness-low.svg"
icon_med="notification-display-brightness-medium.svg"
icon_high="notification-display-brightness-high.svg"
icon_full="notification-display-brightness-full.svg"
icon_off="notification-display-brightness-off.svg"
notify=`which notify-send.sh`
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
        exec $notify --print-id -u low -i $icon_path$icon $bar > $replace_file
    else
        exec $notify -r `cat $replace_file` -u low -i $icon_path$icon $bar
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
