#!/bin/bash

display='wayland'; bar='_'
[[ -z "${WAYLAND_DISPLAY}" ]] && display='xorg'; bar='─'
sink_nr=$(pactl list short sinks | grep RUNNING | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1)
icon_low="notification-audio-volume-low"
icon_med="notification-audio-volume-medium"
icon_high="notification-audio-volume-high"
icon_over="notification-audio-volume-high"
icon_mute="notification-audio-volume-muted"
notify=`which dunstify`
replace_file=/tmp/volume-notification-$display


function get_volume {
    pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $sink_nr + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'
}

function get_volume_icon {
    if [ "$1" -lt 34 ]
    then
        echo -n $icon_low
    elif [ "$1" -lt 67 ]
    then
        echo -n $icon_med
    elif [ "$1" -le 100 ]
    then
        echo -n $icon_high
    else
        echo -n $icon_over
    fi
}

function get_bar {
    volume=`get_volume`
    seq -s $bar $(($volume / 5)) | sed 's/[0-9]//g'
}

function get_mute_bar {
    volume=`get_volume`
    seq -s "." $(($volume / 5)) | sed 's/[0-9]//g'
}

function volume_notification {
    volume=`get_volume`
    vol_icon=`get_volume_icon $volume`
    bar=`get_bar`
    if [ ! -s $replace_file ]
    then
        exec $notify --printid -u normal -i $vol_icon $bar > $replace_file
    else
        exec $notify -r $(cat $replace_file) -u normal -i $vol_icon $bar
    fi
}

function mute_notification {
    muted=$(pacmd list-sinks | awk '/muted/ { print $2 }' | head -n1)
    if [ $muted == 'yes' ]
    then
        exec $notify -r $(cat $replace_file) -u normal -i $icon_mute `get_mute_bar`
    else
        exec $notify -r $(cat $replace_file) -u normal -i ${icon_path}`get_volume_icon $(get_volume)` `get_bar`
    fi
}

case $1 in
    up)
        pactl set-sink-volume $sink_nr +2%
        volume_notification
        ;;
    down)
        pactl set-sink-volume $sink_nr -2%
        volume_notification
	    ;;
    mute)
        pactl set-sink-mute $sink_nr toggle
        mute_notification
        ;;
    *)
        echo "Usage: $0 up | down | mute"
        ;;
esac
