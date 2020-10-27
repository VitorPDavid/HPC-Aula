#!/bin/bash
#sudo cpufreq-set -r -g powersave
#sudo cpufreq-set -r -g performance
rm *.csv
for ((part = 1000; part <= 10000; part+=500))
do
	for ((s = 1; s <= 10; s+=1))
	do
		echo "$part  step: $s"
		./memory.exec 3145728 1024 > /dev/null
		./n-bodies-2.2.exec 100 $part 0 paralelo-2T.csv 2 > /dev/null
		./memory.exec 3145728 1024 > /dev/null
		./n-bodies-2.2.exec 100 $part 0 paralelo-4T.csv 4 > /dev/null
		./memory.exec 3145728 1024 > /dev/null
		./n-bodies-2.2.exec 100 $part 0 paralelo-6T.csv 6 > /dev/null
		./memory.exec 3145728 1024 > /dev/null
		./n-bodies-2.2.exec 100 $part 0 paralelo-8T.csv 8 > /dev/null
	done
done
