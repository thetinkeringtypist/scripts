#!/bin/bash
#
# This is AMD's system configuration settings for AMD EPYC 7003
# processors when deploying java applications.
#
# Reference: https://www.amd.com/content/dam/amd/en/documents/epyc-technical-docs/tuning-guides/java-tuning-guide-amd-epyc7003-series-processors.pdf
#


#
# Set kernel and memory runtime configs
#
system_configuration() {
	# CPU power settings
	cpupower -c all frequency-set -g performance
	tuned-adm profile throughput-performance

	# Kernel runtime configs
	echo 10000    > /proc/sys/kernel/sched_cfs_bandwidth_slice_us
	echo 0        > /proc/sys/kernel/sched_child_run_first
	echo 16000000 > /proc/sys/kernel/sched_latency_ns
	echo 1000     > /proc/sys/kernel/sched_migration_cost_ns
	echo 28000000 > /proc/sys/kernel/sched_min_granularity_ns
	echo 9        > /proc/sys/kernel/sched_nr_migrate
	echo 100      > /proc/sys/kernel/sched_rr_timeslice_ms
	echo 1000000  > /proc/sys/kernel/sched_rt_period_us
	echo 990000   > /proc/sys/kernel/sched_rt_runtime_us
	echo 0        > /proc/sys/kernel/sched_schedstats
	echo 1        > /proc/sys/kernel/sched_tunable_scaling
	echo 50000000 > /proc/sys/kernel/sched_wakeup_granularity_ns

	# Virtual memory runtime configs
	echo 3000     > /proc/sys/vm/dirty_expire_centicecs
	echo 500      > /proc/sys/vm/dirty_writeback_centisecs
	echo 40       > /proc/sys/vm/dirty_ratio
	echo 10       > /proc/sys/vm/dirty_background_ratio
	echo 10       > /proc/sys/vm/swappiness

	# Memory runtime configs
	echo 0        > /proc/sys/kernel/numa_balancing
	echo always   > /sys/kernel/mm/transparent_hugepages/defrag
	echo always   > /sys/kernel/mm/transparent_hugepages/enabled

	# Shell resource limits: max number of open file descriptors
	ulimit -n 1024000


	# I'm using cgroups, so the rest of this file does not apply. However,
	# this is recommended by AMD if cgroups are not going to be used.

	# Add this line to GRUB_CMDLINE_LINUX_DEFAULT # in /etc/default/grub
	# cgroup_disable=memory,cpu,cpuacct,blkio,hugetlb,pids,cpuset,perf_event,freezer,devices,net_cls,net_prio

	# And generate new grub using: (this requires a reboot to take effect)
	# grub2-mkconfig -o /boot/grub2/grub.cfg
}


#
# This function sets up cgroups for each CCD in a system with dual AMD 75F3 processors
# AFTER they have been configured to have four (4) NUMA nodes per socket. These are used
# for pinning a single JVM process to a CCD to keep L3 caches warm and memory allocated
# to the channels directly available to the NUMA node associated with the CCD.
#
# The ranges listed here are subject to change based on processor, number of sockets, and
# number of NUMA nodes configured in the system.
#
# Reference: https://www.amd.com/content/dam/amd/en/documents/epyc-technical-docs/tuning-guides/java-tuning-guide-amd-epyc7003-series-processors.pdf
# Reference: https://sthbrx.github.io/blog/2016/07/27/get-off-my-lawn-separating-docker-workloads-using-cgroups/
#
cgroup_configuration() 
	if [[ ! command -v cgcreate &> /dev/null ]]; then
    		echo "cgcreate not available. Cannot create cgroups."
    		return
	fi

	# Define CPU ranges and NUMA node IDs
	cpu_ranges=()
	numa_nodes=()

	cpu_ranges+=("0-7")
	numa_nodes+=(0)

	cpu_ranges+=("8-15")
	numa_nodes+=(1)

	cpu_ranges+=("16-23")
	numa_nodes+=(2)

	cpu_ranges+=("24-31")
	numa_nodes+=(3)

	cpu_ranges+=("32-39")
	numa_nodes+=(4)

	cpu_ranges+=("40-47")
	numa_nodes+=(5)

	cpu_ranges+=("48-55")
	numa_nodes+=(6)

	cpu_ranges+=("56-63")
	numa_nodes+=(7)

	cpu_ranges+=("64-71")
	numa_nodes+=(0)

	cpu_ranges+=("72-79")
	numa_nodes+=(1)

	cpu_ranges+=("80-87")
	numa_nodes+=(2)

	cpu_ranges+=("88-95")
	numa_nodes+=(3)

	cpu_ranges+=("96-103")
	numa_nodes+=(4)

	cpu_ranges+=("104-111")
	numa_nodes+=(5)

	cpu_ranges+=("112-119")
	numa_nodes+=(6)

	cpu_ranges+=("120-127")
	numa_nodes+=(7)

	# Create one cgroup per CCD
	for (( i=0; i<16; i++)); do
		group_name="ccd$i"

		cgcreate -g cpuset:$group_name
		echo "${cpu_ranges[i]}" > /sys/fs/cgroup/cpuset/$group_name/cpuset.cpus
		echo "${numa_nodes[i]}" > /sys/fs/cgroup/cpuset/$group_name/cpuset.mems
		echo 1 > /sys/fs/cgroup/cpuset/$group_name/cpuset.mem_hardwall
	done
}


#
# Main entrance point for this script
#
main() {
	# Check to see if running as root
	userid=$(id -u)
	if (($id != 0)); then
		echo "Script not executed as root. Exiting."
		return
	fi

	system_configuration
	cgroup_configuration
}



# Program entrance point
main
