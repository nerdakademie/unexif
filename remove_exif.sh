#!/bin/bash
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

unexif(){
	tempfile=$1"/*"
	for f in $tempfile
	do
		if [ -d "$f" ] ; then
			unexif "$f"
		else
			tempdata=$f".tmp"
			mv "$f" "$tempdata"
			exiftool -AllDates="" -all="" -overwrite_original_in_place "$tempdata"
			type="$(file -b $tempdata)"
			if [ "${type%%,*}" == "PDF document" ]; then
				qpdf --linearize "$tempdata" "$f"
  				echo "$f is a PDF file. Deleting orphan stuff to prevend reversing changes"
			;else
				mv "$tempdata" "$f"
			fi
  			echo "Processing $f"
  			rm "$tempdata"
  		fi
	done
}

#Check if user is root
if [[ $EUID -ne 0 ]]; then
   echo -e "\e[1m\e[31mThis script must be run as root\e[39m\e[21m" 1>&2
   exit 1
fi

systemctl stop systemd-timesyncd
date +%Y%m%d -s "19700102" >/dev/null 2>&1


FILES=unexif/*

unexif $FILES

systemctl start systemd-timesyncd
IFS=$SAVEIFS
