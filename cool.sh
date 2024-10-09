#!/bin/sh
#If you wish to make this load on startup add it to /etc/rc.local
#Example addition to rc.local "sh /home/$USER/$NAMEOFTHISSCRIPT.sh"
#Make sure you update the location in rc.local if you move the script
#chmod +x to enable this script for startup in rc.local use

#############################################################################################################
#This is the system tuning part. Be very careful as you can cause locks,panics,and other things that require
#...rebooting to clear. Again not likely safe for battery usage.
#############################################################################################################

#############################################################################################################
#First is the timing settings for normal processes under the default scheduler
#############################################################################################################
#Given value was 1000000 default was 18000000
#Higher value increases higher priority normal process CPU time
#100000 is lowest value it accepts
#Period over which CFS tries to fairly schedule the tasks on the runqueue. 
#All of the tasks on the runqueue are guaranteed to be scheduled once within this period.
#Maybe increasing it works better than decreasing it?
#echo 100000 | sudo tee /proc/sys/kernel/sched_latency_ns

#Given value was 100000 and default was 2250000
#Default value should be 1/2 sched_latency_ns? but lowering this increases preemption occurance
#100000 is lowest value it accepts
#Tasks are guaranteed to run for this minimum time before they are preempted.
echo 100000 | sudo tee /proc/sys/kernel/sched_min_granularity_ns

#Given value was 25000 and default was 3000000
#Higher value helps compute but harms responsiveness
#If larger than 1/2 of sched_latency_ns then CPU hogs will block most tasks
#1000 seemed best so far; 0 is lowest setting it accepts and makes things very responsive
#Ability of tasks being woken to preempt the current task. The smaller the value, the easier it is for the task to force the preemption.
#The lower this is the better the latency and throughput of RT tasks.
echo 0 | sudo tee /proc/sys/kernel/sched_wakeup_granularity_ns

#############################################################################################################
#Second is the CFS scheduler settings
#############################################################################################################
#NEW
#Messing with the CFS scheduler settings
#default was 5000 and I think lower is better for RT?
#1000, 500, 250, 50, 10 works; 1 is lowest
#echo 1 | sudo tee /proc/sys/kernel/sched_cfs_bandwidth_slice_us

#NEW
#Not sure about this one but I think lower is better for RT?
#default was 1000; 500, 125, 50, 10 works; 1 is lowest
#echo 1 | sudo tee /proc/sys/kernel/sched_time_avg_ms

#############################################################################################################
#Third is RT scheduling settings
#############################################################################################################
#Given value and default was 1000000
#Period in microsecs in which bandwidth enforcement is measured 
echo 1000000 | sudo tee /proc/sys/kernel/sched_rt_period_us

#Given value and default was 950000
#At it's default of 950000 RTs can take 95% of CPU usage/sec
#Setting this to -1 disables RT bandwidth enforcement and isn't recommended unless you're sure you'll avoid blocks/locks
#999999 worked best so far
echo -1 | sudo tee /proc/sys/kernel/sched_rt_runtime_us

#How long the Round Robin timeslice is?
#lower better for latency/rt?
#default was 25
#echo 1 | sudo tee /proc/sys/kernel/sched_rr_timeslice_ms

#############################################################################################################
#Fourth is the migration settings (AKA moving processes)
#############################################################################################################
#How many tasks can be moved by the softirqs
#A higher #(32 is default) helps normal processes but hurts RTs?
#128,256 worked best so far
#Red Hat says 2 should be the highest setting.
#Maybe set this to the # of cores available?
#echo 4 | sudo tee /proc/sys/kernel/sched_nr_migrate

#How long can a process be idle before being considered movable to another core (cache change issue?)
#lower better for RT but worse for compute?
#50000 default; 25000 ok 10000 seems to harm max download speed but reduces latency
#lowest so far 100; can accept 1 but that might be too much harm on compute even if it helps RT/latency
#echo 1 | sudo tee /proc/sys/kernel/sched_migration_cost_ns

#############################################################################################################
#Fifth is message/memory settings for processes
#The larger you make msgmax with fewer msgmni the greater the quality effect on media becomes
#Example; try a 2097152 (2MB) setting for msgmax compared to a 8192(8KB AKA default) setting.
###Another idea is seeing what happens when you match the msgmnb to CPU cache size and msgmax to per core cache?
#############################################################################################################
######msgmax#####
#How much data can flow through between processes in one message/transfer
#CANNOT be larger than the msgmnb (AKA total message que size which is default 16384)
#default is 8192 (bytes or 8KB) or half of the default msgmnb que
#Lower is better for RT/responsiveness but higher is better for media quality with low msgmni
#if you want to try MBs then it is desired #ofMB x1024^2
#####msgmnb#####
#maximum allowable total combined size of all messages queued in a single given System V IPC message queue at any one time, in bytes
#default is 16384 (bytes or 16KB) and should generally be no less than 2x msgmax
#Lower is better for RT/responsiveness but higher is better for media quality with low msgmni?
#####msgmni#####
#Maximum number of messages per queue
#Try matching msgmni with /sys/block/sd*/queue/nr_requests?
#default was 24026;IIRC Red Hat recommends 16 when msgmnb is 16384 thus it seems to suggest msgmnb/msgmax=msgmni;

#Try to balance RT needs with throughput by lowering message size and queue size while having about 4-8k #of messages?
echo 1024 | sudo tee /proc/sys/kernel/msgmax && echo 2048 | sudo tee /proc/sys/kernel/msgmnb && echo 8192 | sudo tee /proc/sys/kernel/msgmni

###Set it to 4MB with 16MB total queue size of 4####
#echo 4194304 | sudo tee /proc/sys/kernel/msgmax && echo 16777216 | sudo tee /proc/sys/kernel/msgmnb && echo 4096 | sudo tee /proc/sys/kernel/msgmni

#############################################################################################################
#Shared Memory Settings
#############################################################################################################
#For my 12GB I have 12599627776 bytes
#Recommended value is total RAM in bytes x .75 / shmmni
#For me that would be (12599627776 x .75)/4096
#This uses pages as its unit so that's why you divide by how large a page size (shmni default is 4096) is
#echo 2768473 | sudo tee /proc/sys/kernel/shmall
#echo 2307061 | sudo tee /proc/sys/kernel/shmall
echo 1153530 | sudo tee /proc/sys/kernel/shmall

#Now for the maximum size of a single shared memory segment in bytes
#default is 32MB or 33554432
#Supposedly setting this to 50% of RAM was good but I'll set it to 25% max and 128MB is what I'm finding works best
#So I have 12GB thus 12599627776 x .25
#echo 3149906944 | sudo tee /proc/sys/kernel/shmmax
echo 134217728 | sudo tee /proc/sys/kernel/shmmax

#The max number of shared memory segments
#default is 4096; maybe try to match msgmni, fifo_batch, and nr_requests?
#echo 4096 | sudo tee /proc/sys/kernel/shmni
echo 8192 | sudo tee /proc/sys/kernel/shmmni

#############################################################################################################
#Sixth is the vm (memory related) settings
#############################################################################################################
#VM sections
#Enables complete cache clearing set to 3
#Enables just pagecache clearing set to 1
#echo 1 | sudo tee /proc/sys/vm/drop_caches

#default was 5; given was 95 (good for battery systems)
#A higher value means a higher percentage of RAM or cache is held before a write?
#Higher values dangerous for systems without backup power?
#At 0 apt-get update/upgrade doesn't work
#echo 1 | sudo tee /proc/sys/vm/dirty_background_ratio
#USE A SPECIFIC AMOUNT INSTEAD OF %; ONLY ENABLE THIS IF THE dirty_background_ratio IS NOT TOUCHED
#Set it to the cache of the drive you have or maybe the 1second throughput of the drive?
#Set as desired #ofMB amount x1024^2 (or x1024 for KB)
#64MB = 67108864
#Perhaps set this to half of dirty_bytes?
echo 67108864 | sudo tee /proc/sys/vm/dirty_background_bytes

#default was 10, given was 95 (good for battery systems)
#A higher value means a higher percentage of RAM or cache is held before a write?
#Higher values dangerous for systems without backup power?
#At 0 apt-get update/upgrade doesn't work
#echo 1 | sudo tee /proc/sys/vm/dirty_ratio
#USE A SPECIFIC AMOUNT INSTEAD OF %; ONLY ENABLE THIS IF THE dirty_ratio IS NOT TOUCHED
#Set it to the cache of the drive you have or maybe the 1second throughput of the drive?
#Set as desired #ofMB amount x1024^2 (or x1024 for KB)
#128MB=134217728
echo 134217728 | sudo tee /proc/sys/vm/dirty_bytes

#How old data has to be before writeback daemons write to disk
#Given and default was 500; 250,125 and even 1 worked
#lower better for RT? but stresses disks (SSD worry?) and battery
#echo 50 | sudo tee /proc/sys/vm/dirty_writeback_centisecs

#How old dirty data has to be before written to disk
#Given was 750 but default was 3000; 500,250, and even 1 worked
#lower better for RT? but stresses disks (SSD worry?) and battery
#echo 75 | sudo tee /proc/sys/vm/dirty_expire_centisecs

#Default is 100 and that will force the system to clean cache of dentries and inodes
#<100 and the system holds them longer; >100 and it cleans them faster
#echo 50 | sudo tee /proc/sys/vm/vfs_cache_pressure

#############################################################################################################
#Schedule Domain settings
#These seem to be balancing focused. Affects both SMP and NUMA systems but probably more important for NUMA
#############################################################################################################
#No CPU balancing until over watermark
#Default was 125 and units are in %
#Seems lower values help latency/responsiveness which is counter to what has been claimed
echo 0 | sudo tee /proc/sys/kernel/sched_domain/cpu*/domain*/imbalance_pct

#Maximum balance interval ms
#Default is 4 and I'd assume that smaller values would be better for latency
echo 1 | sudo tee /proc/sys/kernel/sched_domain/cpu*/domain*/max_interval

#Minimum balance interval ms
#Default is 1 and that's the lowest it will accept
#echo 1 | sudo tee /proc/sys/kernel/sched_domain/cpu*/domain*/min_interval

#Leave cache hot tasks for # tries
#Default is 1 and 0 is the lowest setting but higher might benefit latency
echo 0 | sudo tee /proc/sys/kernel/sched_domain/cpu*/domain*/cache_nice_tries

#############################################################################################################
#This is the semaphore or synchronization settings
#See their settings using the ipcs -l command
#############################################################################################################
#defaults 250     32000   32      128
#Lower is better for latency and audio quality but higher seems better for video/games and compute
#Or 4096     16384000   4096      4000
#Or 8192     65536000   8192      8000
#Or 1024     1024000   1024      1000
#Or 128     16000   128      125
#The first and last numbers must multiply to equal the second number
#It's been recommended that the first and third numbers be equal while maintaining the other relationships
echo 128     16000   128      125 | sudo tee /proc/sys/kernel/sem

#############################################################################################################
#Block/disk settings
#############################################################################################################
#Supposedly a negative effect on latency for higher numbers but I've found the opposite is true
#default was 128; 4096 is recommended for throughput;
#using sd* edits all attached disks IO scheduling to this value
#setting this to 1 should automatically set it to the lowest value allowable which was 4 for me
#Perhaps the minimum is the number of cores you have?
echo 8192 | sudo tee /sys/block/sd*/queue/nr_requests

#Readahead settings
#sudo blockdev --setra 32768 /dev/sda
#sudo blockdev --getra /dev/sda
#sudo blockdev --setra 32768 /dev/sdb
#sudo blockdev --getra /dev/sdb
#sudo blockdev --setra 32768 /dev/sdc
#sudo blockdev --getra /dev/sdc

#############################################################################################################
#USE THESE ONLY ON DEVICES/SYSTEMS USING DEADLINE I/O SCHEDULING
#Best to use lower values for latency and higher for throughput
#############################################################################################################
#The number of read or write operations to issue in a single batch
#A higher value can increase throughput, but will also increase latency
#default is 16; 8,4,1  was last good value
#setting this to 0 supposedly disables OS IO schedulers and uses the device's NCQ instead
#perhaps this should match /sys/block/sd*/queue/nr_requests ?
echo 8192 | sudo tee /sys/block/sd*/queue/iosched/fifo_batch

#The number of milliseconds in which a read request should be scheduled for service
#default is 500 or .5 seconds; 250,125 was last good value
#Perhaps a higher value is fine when fifo_batch and nr_requests are small?
#echo 1000 | sudo tee /sys/block/sd*/queue/iosched/read_expire

#The number of milliseconds in which a write request should be scheduled for service
#default is 5000 or 5 seconds; 2500,1250,500 was last good value
#Perhaps a higher value is fine when fifo_batch and nr_requests are small?
#echo 2000 | sudo tee /sys/block/sd*/queue/iosched/write_expire

#The number of read batches that can be processed before processing a write batch
#The higher this value is set, the greater the preference given to read batches.
#default is 2 or 2read batches:1write batch
#echo 1 | sudo tee /sys/block/sd*/queue/iosched/writes_starved