# unexif

Dies ist ein Bash Script, welches [Exif-Daten](https://de.wikipedia.org/wiki/Exchangeable_Image_File_Format) aus allein Dateien im Verzeichnis "unexif" entfernt.
Das Datum wird dabei auf 1970 gesetzt. Hierzu wird der systemd Dienst zum synchronisieren der Zeit mit dem Internet kurzzeitig abegeschaltet. 

**Also ist das Script vorerst nur auf systemd basierten Linux Distributionen lauffähig.**

