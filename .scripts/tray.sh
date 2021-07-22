export XDG_CURRENT_DESKTOP=Unity
# Start applets if they're not running
for arg in "parcellite" "nm-applet" "blueman-applet" "solaar -w hide"
do
    if ! ps ax | grep -v grep | grep -io "$arg"
    then
        echo "Launching $arg"
        exec $arg &
    fi
done
exit 0
