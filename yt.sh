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

	length=$(echo "$pages" | grep "length" | grep ":" | sed -n 's|.*class="length">\([^<]*\).*|\1|p')
	echo "$length" > /tmp/length

	pub=$(echo "$pages" | grep "video-data" | grep -v " views" | \
	sed -n 's|.*dir="auto">Shared \([^<]*\).*|\1|p' | sed "s/ ago//")
	echo "$pub" > /tmp/pub

	title=$(echo "$pages" | grep '<p dir="auto"' | grep 'href="/watch' | \
	sed -n 's|.*<p dir="auto">\([^<]*\).*|\1|p')
	echo "$title" > /tmp/title

	channel=$(echo "$pages" | grep "channel-name")
	line=$(echo "$channel" | nl -n ln | grep "@" | awk '{print $1}')
	line_pre=$(expr $line - 1)
	channel=$(echo "$channel" | sed "${line_pre},${line}d" | sed "s/.*>//" | grep -v '^[[:space:]]*$')
	echo "$channel" > /tmp/channel
	
	views=$(echo "$pages" | grep " views" | sed -n 's|.*dir="auto">\([^<]*\).*|\1|p')
	echo "$views" > /tmp/views

	url=$(echo "$pages" | grep '<p dir="auto"' | grep 'href="/watch' | \
	sed -n 's|.*watch?v=\([^"]*\).*|https://www.youtube.com/watch?v=\1|p' | nl -n ln)
	echo "$url" > /tmp/url

	display=$(paste /tmp/length /tmp/pub /tmp/views /tmp/channel /tmp/title | \
	nl -n ln | sed "s/\t/\^/g" | sed "s/    //" | column -t -s "^" -o "  ")

	while true; do
		selection=$(echo "back\n$display" | fzf --multi --reverse)

		[ "$selection" = "back" ] && break
		[ "$selection" = "" ] && break

		number=$(echo "$selection" | awk '{print $1}')
		url_sel=$(echo "$url" | grep -e "^$number\s" | awk '{print $2}')

		clear
		echo "loading video ..."
		mpv -fs $url_sel
	done
done

