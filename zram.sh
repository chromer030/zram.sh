#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# https://github.com/chromer030/zram.sh
# Reza Moghadam - 2023

VERSION=1.0
export LANG=C

if [[ `uname -o` != 'GNU/Linux' ]] ; then echo 'This script is adapted for Linux OS ! Your OS is' `uname -o` ; exit 1 ; fi

if ! [ -x "$(command -v zramctl)" ]; then
	echo -e "zramctl tool are essential for managing zram, please make sure util-linux package is installed on your system, and it has executable permission"
	exit 1
fi

if [[ $# -eq 0 ]]
  then
    echo "No arguments supplied, pass -h or --help"
    exit 0
fi

function print_help() {
    cat <<HELP
Usage: $(basename $0) [OPTION]...

To calculate and apply half of your RAM as a zram swap, you can also set your desirable size but half of your ram is recommended.

  -on            turning on zram on /dev/zram0 block path
  -off	         turning off (if existed) zram on /dev/zram0 block path
  -stat          current status of zram and swaps
  -s nGiB        custom zram block size in GiB or GB or MB or even KB ! (e.g -s 4GiB)
  -c		 custom compression alghorithm (default : zstd)
                 possible alghorithms : zstd  lzo  lzo-rle  lz4  lz4hc  842
  -p             custom priority (default : 100)
  -h             print this help message
  -v             print version number

Note: Some procedures require superuser rights
HELP
} 

## Turn on zram :
function On() {
		if [ -b "/dev/zram0" ]
			then
					echo "There is already an active zram on /dev/zram0 path, check for it..."
					exit 0
		elif [ -b "/dev/zram1" ]
			then
					echo "There is already an active zram on /dev/zram1 path ! btw we will activate zram0"
		else
				if (( EUID != 0 ))
					then
						echo -e 'This functionality requires superuser rights, please run as root or with sudo / doas'
						exit 1
				fi
			sh -c "echo 0 > /sys/module/zswap/parameters/enabled"
			modprobe zram
			zramctl /dev/zram0 --algorithm $Compression --size $Size
			mkswap -U clear /dev/zram0
			swapon --priority $Priority /dev/zram0
			echo -e "\033[32mzram Enabled :\033[0m"
			free -h | grep Swap:
			echo -e "\033[32m-----------------------------------------------\033[0m"
			zramctl
		fi }

Size=`awk '$1=="MemTotal:"{t=$2}END{printf("%.0f.GiB\n", t/2/1024/1024)}' /proc/meminfo`
if [ "$Size" = 0GiB ] ; then unset Size ; Size='1GiB' ; echo -e "Your System has a low RAM size, zram size set to $Size"; fi
Priority=100
Compression=zstd

function Off() {
		if [ -b "/dev/zram0" ]
			then
				if (( EUID != 0 ))
					then
						echo -e 'This functionality requires superuser rights, please run as root or with sudo / doas'
						exit 1
				fi
				swapoff /dev/zram0
				modprobe -r zram
				su -c "echo 1 > /sys/module/zswap/parameters/enabled"
				echo "zram Disabled :"
				free -h | grep Swap:
			else
				echo "There is no any active zram0 on /dev/zram0 path to turn off, Exiting"
				exit 0
		fi
	}

function Status() {
				if [ -b "/dev/zram0" ]
				then
					echo -e "\033[32m-----------------------------------------------\nStatus : zram is enabled under /dev/zram0 path\n-----------------------------------------------\033[0m"
					echo -e "\033[36mIs zswap enabled :\033[0m" `cat /sys/module/zswap/parameters/enabled` "\n\033[32m-----------------------------------------------\033[0m"
					zramctl
					echo -e "\033[32m-----------------------------------------------\033[0m"
					cat /proc/swaps
					echo -e "\033[32m-----------------------------------------------\033[0m"
				else
					echo -e "\033[31m-----------------------------------------------\nStatus : zram is not enabled under /dev/zram0 path\n-----------------------------------------------\033[0m"
					echo -e "\033[36mIs zswap enabled :\033[0m" `cat /sys/module/zswap/parameters/enabled` "\n\033[36m-----------------------------------------------\033[0m"
				fi
			free -h | grep Swap:
}

for arg in "$@"; do
  shift
  case "$arg" in
		'-help')   set -- "$@" '-h'   ;;
		'-on')      set -- "$@" '-x'   ;;
		'-off')     set -- "$@" '-f'   ;;
		'-stat')   set -- "$@" '-w'   ;;
		*)            set -- "$@" "$arg" ;;
  esac
done

OPTIND=1
run=false

while getopts "hxfvwc:p:s:" opt ; do
    case $opt in
		x) 
			run=true ;;
        h)
			print_help
			exit 0 ;;
		f) unset -f On ; Off ;;
		c)
			unset Compression
			Compression=$OPTARG ;;
		p)
			unset Priority
			Priority=$OPTARG ;;
		s) unset Size
			Size=$OPTARG ;;
		w) Status ;;
        v)
			echo -e "Version :\n $(basename -- "$0") $VERSION"
            exit 0 ;;
        *)
	esac
done
shift "$((OPTIND-1))"

if $run ; then On ; fi
