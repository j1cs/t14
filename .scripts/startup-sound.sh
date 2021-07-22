#!/usr/bin/env bash
file=`ls $1*Startup*.wav | sort -R | tail -n 1`
paplay $file