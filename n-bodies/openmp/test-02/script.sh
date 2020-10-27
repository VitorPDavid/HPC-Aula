#!/bin/bash
#sudo cpufreq-set -r -g powersave
#sudo cpufreq-set -r -g performance
rm *.csv
for ((part = 1000; part <= 2000; part+=100))
do
	for ((s = 1; s <= 5; s+=1))
	do
		echo "$part  step: $s"
		./memory.exec 3145728 1024 > /dev/null
		./n-bodies-1.0.exec 100 $part 0 sequencial.csv > /dev/null
		./memory.exec 3145728 1024 > /dev/null
		./n-bodies-2.0.exec 100 $part 0 paralelo-struct.csv > /dev/null
		./memory.exec 3145728 1024 > /dev/null
		./n-bodies-2.1.exec 100 $part 0 paralelo-sem-struct.csv > /dev/null
	done
done
