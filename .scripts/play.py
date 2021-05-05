#!/usr/bin/env python3

import gi
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib

PLAYING = ''
PAUSED = ''
STOPPED = ''

class Player:
    icons = {
        Playerctl.PlaybackStatus.PLAYING: PAUSED,
        Playerctl.PlaybackStatus.PAUSED: PLAYING,
        Playerctl.PlaybackStatus.STOPPED: STOPPED
    }

    def __init__(self, ):
        self.player = Playerctl.Player()
        self.show()

        self.player.connect('playback-status', self.on_playback_status)
        self.player.connect('metadata', self.on_metadata)

    def on_metadata(self, player, metadata):
        self.show()

    def on_playback_status(self, player, playback_status):
        self.show()

    def show(self):
        try:
            icon = Player.icons[self.player.props.playback_status]
            print('{}'.format(icon), flush=True)
        except:
            pass


class Manager:
    def __init__(self):
        self.player = None
        for player in Playerctl.list_players():
            self.on_name_appeared(None, player)
        self.player_manager = Playerctl.PlayerManager()
        self.player_manager.connect('name-appeared', self.on_name_appeared)
        self.player_manager.connect('name-vanished', self.on_name_vanished)
        print('{}'.format(STOPPED), flush=True)
        self.main = GLib.MainLoop()
        self.main.run()

    def on_name_appeared(self, player_manager, name):
        self.player = Player()

    def on_name_vanished(self, player_manager, name):
        icon = Player.icons[Playerctl.PlaybackStatus.STOPPED]
        print('{}'.format(icon), flush=True)

Manager()
