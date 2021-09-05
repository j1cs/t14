#!/bin/bash

[[ -z "${WAYLAND_DISPLAY}" ]] && display='xorg' || display='wayland'
content_file=/tmp/mic-$display
function color {
    $HOME/.scripts/colors.sh $1
}

function update_source {
    # always get the source (headphones, speakrs, etc)
    source=$(pactl list | grep -B 2 "Name: $(pactl get-default-source)" | head -n 1 | awk -F# '{ print $2 }')
}

function volume_up {
    update_source
    pactl set-source-volume $source +2%
    volume_print
}

function volume_down {
    update_source
    pactl set-source-volume $source -2%
    volume_print
}

function volume_mute {
    update_source
    pactl set-source-mute $source toggle
    volume_print
}

function get_volume {
    pactl list sources | grep -A 10 -w "Source #$source" | grep '^[[:space:]]Volume:' | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'
}

function volume_print {
    update_source

    mute=$(pactl list sources | grep -A 10 -w "Source #$source"  | grep Mute | tail -n 1 | awk '{ print $2 }')
    if [ "$mute" = "yes" ]; then
        echo "%{F$(color color07)}%{F-} muted" > $content_file
    else
        echo "%{F$(color color07)}%{F-} `get_volume`%" > $content_file
    fi
}
function listen {
    # print the first time you ran the script
    volume_print && echo "$(cat $content_file)"
    pactl subscribe | while read -r event; do
        # the button on polybar is client and i read the file to avoid execute volume_print wht is also a client
        # so you fall into a infinite loop
        if echo "$event" | grep -qv "Client" &>/dev/null; then
            echo "$(cat $content_file)"
        fi
        # when you use pavucontrol the event is 'change' on source #1
        if echo "$event" | grep -q "'change' on source #$source" &>/dev/null; then
            volume_print
        fi
    done
}
case "$1" in
    up)
        volume_up
        ;;
    down)
        volume_down
        ;;
    mute)
        volume_mute
        ;;
    *)
        listen
        ;;
esac
