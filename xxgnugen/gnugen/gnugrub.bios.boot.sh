search -f /grub2/g2bootmgr/gnugrub.functions.cfg  --set=grub2address
set grub2part=($grub2address)
set prefix=$grub2part/grub2
set pager=1