#!/bin/bash

# Read /proc/stat once
t1_stat=$(head -n 1 /proc/stat)

# T1
t1_total=$(echo "${t1_stat}" | awk '{
  sum=0;
  for (i=2; i<=NF; i++)
    sum+=$i;
  print sum 
}')

t1_idle=$(echo "${t1_stat}" | awk '{
  t_idle=$5+$6;
  print t_idle
}')

t1_busy=$((${t1_total} - ${t1_idle}))

# Wait one second to get T2
sleep 1
t2_stat=$(head -n 1 /proc/stat)

# T2
t2_total=$(echo "${t2_stat}" | awk '{
  sum=0;
  for (i=2; i<=NF; i++)
    sum+=$i;
  print sum 
}')

t2_idle=$(echo "${t2_stat}" | awk '{
  t_idle=$5+$6;
  print t_idle
}')

t2_busy=$((${t2_total} - ${t2_idle}))

# Difference in each value over one second
d_busy=$((${t2_busy} - ${t1_busy}))
d_idle=$((${t2_idle} - ${t1_idle}))
d_total=$((${t2_total} - ${t1_total}))

# Percentage of d_total that was busy
usage=$(echo "(${d_busy}/${d_total}) * 100" | bc -l)
echo "${usage}"
