#!/usr/bin/env bash
file=`ls $1*Shutdown*.wav | sort -R | tail -n 1`
paplay $file