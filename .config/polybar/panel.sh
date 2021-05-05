#!/usr/bin/env bash
function color {
    $HOME/.scripts/colors.sh $1
}

export BACKLIGHT_COLOR0="%{F$(color color10)}%{F-}"
export BACKLIGHT_COLOR1="%{F$(color color11)}%{F-}"
export BACKLIGHT_COLOR2="%{F$(color color12)}%{F-}"
export MUTE_COLOR="%{F$(color color07)}%{F-} muted"
export TEMPERATURE_COLOR0="%{F$(color color4)}%{F-}"
export TEMPERATURE_COLOR1="%{F$(color color3)}%{F-}"
export TEMPERATURE_COLOR2="%{F$(color color1)}%{F-}"
# Terminate already running bar instances
pkill polybar

# Wait until polybar have been completely shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 2; done

echo 'Launching polybar...'
polybar main &

# Start applets if they're not running
for arg in "parcellite" "nm-applet" "blueman-applet" "caffeine" "solaar -w hide"
do
    if ! ps ax | grep -v grep | grep -io "$arg"
    then
        echo "Launching $arg"
        exec $arg &
    fi
done

echo 'Polybar launched'
exit 0
