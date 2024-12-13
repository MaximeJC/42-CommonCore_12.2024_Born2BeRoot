#!/bin/bash

echo "#####################################################"
echo "#                                                   #"
echo "#                 Server Monitoring                 #"
echo "#                                                   #"
echo "#####################################################"
echo
echo -n "    #Architecture: " 
uname -a 

echo -n "    #CPU physical:"
grep -m1 "cpu cores" /proc/cpuinfo | cut -d ":" -f2

echo -n "    #vCPU: "
grep "processor" /proc/cpuinfo | wc -l

MEM_TOT=$(free --mega | awk '$1=="Mem:" {print $2}')
MEM_USE=$(free --mega | awk '$1=="Mem:" {print $3}')
MEM_PER=$(echo "(${MEM_USE}/${MEM_TOT})*100" | bc -l)
printf "    #Memory Usage: %d/%dMB (%.2f%%)\n" $MEM_USE $MEM_TOT $MEM_PER

DISK_USE=$(df --total --human-readable | grep "total" | awk '{print $3}')
DISK_TOT=$(df --total --human-readable | grep "total" | awk '{print $2}')
DISK_PER=$(echo "(${DISK_USE%?}/${DISK_TOT%?})*100" | bc -l)
printf "    #Disk Usage: %.1f/%.0fGB (%.2f%%)\n" ${DISK_USE%?} ${DISK_TOT%?} $DISK_PER

echo -n "    #CPU load: "
mpstat | grep "all" | awk {'printf("%.2f%%\n"), 100-$12'}

echo -n "    #Last boot: "
who -b | awk '$1=="system" {print $3 " " $4}'

echo -n "    #LVM use: "
if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo "yes"; else echo "no"; fi

echo -n "    #Connexions TCP: "
ss -ta | grep "ESTAB" | wc -l

echo -n "    #User log: "
printf "%d (%d unique)\n" $(users | wc -w) $(users | tr " " "\n" | uniq | wc -w)

echo -n "    #Network: "
echo -n $(ip address show enp0s3 | grep "inet " | awk {'print $2'} | cut -d '/' -f1) "("
echo $(ip address show enp0s3 | grep "link/ether" | awk {'print $2'})")"

echo -n "    #Sudo: "
echo $(journalctl -q _COMM=sudo | grep "COMMAND" | wc -l)" commands"

echo
date
echo "------------------- End of report -------------------"
