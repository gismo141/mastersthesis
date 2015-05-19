set terminal x11
set datafile separator ";"
set grid
set isosample 40
set xdata time
#set ydata time
set timefmt "%s"
set format x "%H:%M"
#set format y "%H:%M"
set ticslevel 0

#splot "< cat icp_fitness_1.csv icp_fitness_10.csv  | sort -n" using 1:2:3
#splot "icp_fitness_1.csv" using 1:2:3
plot "icp_fitness_1.csv" using 1:3
pause -1