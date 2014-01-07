hdiutil mount floppy.img
cp -f ./STAGE2.SYS /Volumes/UNTITLED
cp -f ./KRNL.SYS /Volumes/UNTITLED
hdiutil unmount /Volumes/UNTITLED
