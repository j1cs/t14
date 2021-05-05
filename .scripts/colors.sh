#!/bin/bash
keys=( $(xrdb -query | grep -P "color[0-9]*:"  | sed -E -e 's/\*|://g' | awk '{print $1}') )
values=( $(xrdb -query | grep -P "color[0-9]*:"  | sed 's/\*//g' | awk '{print $2}') )
# define array "color" (actually a hash table)
declare -A color

# need this to get the values from xrdb one by one
index=0

# loop over color names
for key in "${keys[@]}"; do
	# assign color value from array xrdb to hash "color"
	color[${key}]=${values[$index]}
	# increase "index" by one, so we get the next color value for the next iteration
	((index++))
done
echo -n "${color[$1]}"
