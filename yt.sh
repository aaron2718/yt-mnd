#!/bin/dash

instance="https://inv.nadeko.net"

while true; do
	clear
	read -p 'Search: ' query
	echo "loading results ..."
	search_query=$(echo "$query" | sed 's/ /+/g')
	[ -z "$search_query" ] && break
	i=1

	while [ "$i" = 1 ]; do
		results=$(curl -s "$instance/search?q=$search_query" | \
		grep '<p dir="auto"' | \
		sed -n 's|.*watch?v=\([^"]*\).*<p dir="auto">\([^<]*\).*|https://www.youtube.com/watch?v=\1 \2|p')

		display=$(echo "$results" | awk '{$1=""; print}' | nl -n ln)

		selection=$(echo "back\n$display" | fzf --multi --reverse)

		if [ "$selection" = "back" ]; then
			i=0
			continue
		fi

		number=$(echo "$selection" | awk '{print $1}')

		all_url=$(echo "$results" | awk '{print $1}' | nl -n ln)

		url=$(echo "$all_url" | grep -e "^$number\s" | awk '{print $2}')

		echo "loading video ..."
		mpv -fs $url
	done
done

