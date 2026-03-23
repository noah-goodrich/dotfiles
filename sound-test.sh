#!/usr/bin/env bash
# Test Glass at different volume levels

vol=$(osascript -e 'output volume of (get volume settings)')

for level in 50 60 70 75 80 90 100; do
    echo "▶ ${level}%"
    osascript -e "set volume output volume $level"
    afplay /System/Library/Sounds/Glass.aiff
    sleep 1.2
done

osascript -e "set volume output volume $vol"
