#!/bin/dash

instance="https://inv.nadeko.net"

while true; do
	clear
	read -p 'Search: ' query
	[ -z "$query" ] && clear && break
	clear
	echo "loading results ..."

	if [ -z "$1" ]; then
		p=1
	else
		p=$1
	fi		
	search_query=$(echo "$query" | sed 's/ /+/g')
	pages=""

	for i in $(seq 1 "$p"); do
		page=$(curl -s "$instance/search?q=$search_query&page=$i")
		pages="$pages\n$page"
	done

	results=$(echo "$pages" | grep '<p dir="auto"' | \
	sed -n 's|.*watch?v=\([^"]*\).*<p dir="auto">\([^<]*\).*|https://www.youtube.com/watch?v=\1 \2|p')
	display=$(echo "$results" | awk '{$1=""; print}' | nl -n ln)

	while true; do
		selection=$(echo "back\n$display" | fzf --multi --reverse)

		[ "$selection" = "back" ] && break

		number=$(echo "$selection" | awk '{print $1}')
		all_url=$(echo "$results" | awk '{print $1}' | nl -n ln)
		url=$(echo "$all_url" | grep -e "^$number\s" | awk '{print $2}')

		clear
		echo "loading video ..."
		mpv -fs $url
	done
done

