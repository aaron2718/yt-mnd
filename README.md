# YouTube Player

A minimal, POSIX-compliant shell script that allows you to browse YouTube content and play videos directly using `mpv`.

## Requirements

Make sure the following tools are installed:

- `dash`
- `curl`
- `fzf`
- `mpv`
- `sed`, `awk`, `grep`, `nl`
- The latest version of `yt-dlp`

## Usage

1. When running the script, you can optionally provide a number as an argument (default: 1). This number specifies how many pages of results to load (one page contains approximately 20 results).
2. To exit the search interface, press the **Return** key while the search input is empty.
3. Search results are displayed using `fzf`. Select **back** to return to the search prompt.

