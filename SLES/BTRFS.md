# BTRFS / H020031 LAB: SUSE Linux Enterprise Server 12 Snapshots and Rollback Using BTRFS

## Preparation

Ensure that the VM is running
Log in to the VM as root

### Task 1: Investigate the default BTRFS configuration
1. Inspect the default subvolume layout:
```
    mount
```
Notice that /dev/sda2 appears to be mounted many times, but with different mount points!

2. Ask btrfs to list the subvolumes of the root filesystem:
```
    btrfs subvolume list /
```
Note that any snapshots are also listed as subvolumes.

3. BTRFS mounts are slightly unusual. Investigate how they are mounted:
a) See how the btrfs volumes are mounted
```
    cat /etc/fstab
```
Look for the subvol in the options column.
b) To find the UUID of a filesystem use:
```
        blkid
```
Note that the UUID for all parts of the BTRFS volume have the same UUID!
c) SLE 12 uses systemd units to mount filesystems:
```
    systemctl list-units --type mount
```

4. Check for free disk space:
a) Use the normal system tools:
```
    df -h
```
Note how each subvolume shows the same space usage. This can confuse scripts!
b) Interrogate BTRFS:
```
    btrfs filesystem df /
    btrfs filesystem usage /
```
Note that free space is only estimated. This happens because chunks have not yet been
allocated to data or metadata yet.

### Task 2: Create a new subvolume using YaST
1. Open YaST → System → Partitioner

2. Say yes on the warning dialog that appears

3. In the left pane, move down to BTRFS
a) Select /dev/sda2
b) Click Edit
c) Click subvolume Handling
d) Enter @/data1 into the New Subvolume box
e) Click Add New
f) Click OK
g) Click Finish
h) At the main screen, click Next
i) Confirm creation of the new subvolume by clicking Finish
j) Exit yast

4. Create the mountpoint
```
    mkdir /data1
```

5. Find the UUID of the new subvolume using the blkid command
```
    blkid /dev/sda2
```

6. Add the new subvolume to fstab and mount it:
Add a new line using the UUID from above
UUID=XXXX-XXXX-XXXX /data1 btrfs subvol=@/data1 0 0

7. Mount the new volume
```
    mount -a
```

8. Ensure that it mounts ok using
```
    mount
    systemctl list-units --type mount
```

### Task 3: Investigate Snapper

1. List the current snapshots
```
    snapper list
```

2. Locate the snapshots in the filesystem
```
    mount | grep snapshot
    ls /.snapshots
```

3. Change to a snapshot directory
a) Inspect the snapshot description file (info.xml)
b) Navigate around the snapshot

4. Take a snapshot using snapper
a)
```
    snapper create -d "mysnapshot"
    snapper list
```
b) Navigate around the newly created snapshot directory under /.snapshots

#### Modify a system file and compare it to the version in a snapshot

5. Add a line to the hosts file
```
    192.168.0.123 ahost.suse.com
```

6. Look at the differences between the snapshot and the current filesystem in YaST
```
    yast2 snapper
```
Move to the antepenultimate enry, your snapshot, move ENter
In the left pane, open the etc folder and click on the hosts entry, the diffs are shown in the
right pane

7. Do the same using the snapper tool:
```
    snapper status 0..x (where x is the number of the snapshot you took above)
    snapper diff 0..x /etc/hosts
```

#### Investigate software management snapshots:

8. Install sysstat using zypper
```
    zypper in nmon 
```
    (If DVD drive is not available, use the sysstat rpm on root's
desktop)

9. Check list of snapshots:
```
    snapper list
```
Note that there are two snapshots that are linked as a pre/post. Use the snapper status
command to show differences between the pre and post snapshots
Investigate system administration snapshots:

10. Reconfigure NTP using YaST
a) Command: yast ntp-client
b) Set the NTP daemon to start “Now and on Boot”
c) Click Add
d) Select Server, and click Next
e) Enter: 0.pool.ntp.org
f) Click OK
g) At the main screen, click OK

11. Review the changes
a) Command: yast2 snapper
b) Select the Pre&Post pair of snapshots with the description “yast ntp-client”
c) Click Show Changes
d) Navigate through the tree at the left to see which files have changed and look at the diffs.Snapper has configuration profiles per subvolume

12. Show all snapper configurations
```
    snapper list-configs
```

13. View the default snapper configuration for the root subvolume
```
    snapper get-config
```
Note that timeline snapshots are disabled for the root subvolume

14. Create a new configuration profile for a subvolume
a) 
```
    snapper -c data1cfg create-config /data1
```
b) View the default settings for the new config
```
    snapper -c data1cfg get-config
```
c) Use the snapper command to reduce the number of hourly timeline snapshots that are
kept
```
    snapper -c data1cfg set-config TIMELINE_LIMIT_DAILY=8
```

15. Take a snapshot of a subvolume
```
    snapper -c data1cfg create -d "data1snap"
```

16. List the snapshots for the data1 subvolume
```
    snapper -c data1cfg list
```


#### Task 4: Perform a system rollback
In this task you will take a snapshot, then break the system by deleting files, and then recover it from a snapshot.

1. Take a snapshot that we'll roll back to
```
    snapper create -d "knowngood"
```

2. Find the number of the above snapshot
```
    snapper list
```
Record the snapshot number for the above snapshot
Break the system!

3. Delete the kernel from the boot directory
```
    rm /boot/vmlinu*
```

4. Reboot the VM
```
    systemctl reboot
```
The VM fails to boot

Recover the system.

5. Reboot the VM

6. At the boot prompt, scroll down to “Start bootloader from a readonly snapshot” and press enter

7. Highlight the snapshot taken above
Note that the snapshot times are in UTC

8. Press enter to select the snapshot

9. Press enter again to boot the system from the snapshot
The system boots to a read-only state. There may be errors as some services cannot start
with a read-only root filesystem

10. Roll back permanently to the snapshot number created above
```
    snapper rollback
```

11. List the snapshots to see what the rollback has created
```
    snapper list
```

12. Reboot the VM once more
```
    systemctl reboot
```
Verify that the system reboots correctly

