#!/usr/bin/env python3
import gi
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib
from subprocess import Popen

player = Playerctl.Player()
icon = '/usr/share/icons/ePapirus/48x48/categories/{image}.svg'

def on_track_change(player, e):
    name = player.props.player_name
    if name == 'mpv':
        artist = player.get_artist() or ''
        title = player.get_title() or ''
        track_info = '{artist} - {title}'.format(artist=artist, title=player.get_title())
        Popen(['notify-send', '-i', icon.format(image=name), track_info])
    if name == 'chromium':        
        if player.get_artist() and player.get_title():
            print(player.print_metadata_prop())
            artist = player.get_artist() or ''
            title = player.get_title() or ''
            track_info = '{artist} - {title}'.format(artist=artist, title=player.get_title())
            Popen(['notify-send', '-i', icon.format(image=name), track_info])

player.connect('metadata', on_track_change)

GLib.MainLoop().run()
