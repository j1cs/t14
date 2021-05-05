#!/usr/bin/env bash

# A rofi-like System/Exit menu for wofi

# wofi crashes w/ no cache file, so let's use a custom one and delete it every time, to avoid reordering entries
rm ~/.local/share/wofi/exit.cache

A=$(wofi --show dmenu --width=100 --height=170 --cache-file=~/.local/share/wofi/exit.cache --prompt=System cat <<EOF
 Lock
 Logout
 Reboot
 Shutdown
EOF
)

case "$A" in

    *Lock) swaylock -f -c 000000 ;;

    *Logout) swaynagmode -R -t 'error' -m ' You are about to exit Sway. Proceed?' \
      -b '  Logout ' 'swaymsg exit' \
      -b '  Reload ' 'swaymsg reload' ;;

    *Reboot) swaynagmode -R -t 'error' -m ' You are about to restart the machine? Proceed?' \
      -b '  Reboot ' 'loginctl reboot' ;;

    *Shutdown) swaynagmode -R -t 'error' -m ' You are about to turn the machine off. Proceed?' \
      -b '  Shutdown ' 'loginctl poweroff' ;;

esac

exit 0
