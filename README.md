# thin_to_thick
Converts a thin jail to a thick jail

A thin jail often uses a nullfs mount to supply the main jail directories.

This process based on https://github.com/iocage/iocage/issues/730

ezjail uses this approach. This is a typical ezjail basejail:

```
$ ls -l /usr/jails/newjail
total 203
-r--r--r--   1 root  wheel  6197 Apr  4  2015 COPYRIGHT
drwxr-xr-x   2 root  wheel     2 Jul 26  2013 basejail
lrwxr-xr-x   1 root  wheel    13 Jul 26  2013 bin -> /basejail/bin
lrwxr-xr-x   1 root  wheel    14 Jul 26  2013 boot -> /basejail/boot
dr-xr-xr-x   2 root  wheel     2 Dec  4  2012 dev
drwxr-xr-x  22 root  wheel   101 Dec 10  2016 etc
lrwxr-xr-x   1 root  wheel    13 Jul 26  2013 lib -> /basejail/lib
lrwxr-xr-x   1 root  wheel    17 Jul 26  2013 libexec -> /basejail/libexec
drwxr-xr-x   2 root  wheel     2 Dec  4  2012 media
drwxr-xr-x   2 root  wheel     2 Dec  4  2012 mnt
dr-xr-xr-x   2 root  wheel     2 Dec  4  2012 proc
lrwxr-xr-x   1 root  wheel    16 Jul 26  2013 rescue -> /basejail/rescue
drwxr-xr-x   2 root  wheel     6 Apr  4  2015 root
lrwxr-xr-x   1 root  wheel    14 Jul 26  2013 sbin -> /basejail/sbin
lrwxr-xr-x   1 root  wheel    11 Dec  4  2012 sys -> usr/src/sys
drwxrwxrwt   2 root  wheel     2 Dec  4  2012 tmp
drwxr-xr-x   5 root  wheel    14 Aug 23  2015 usr
drwxr-xr-x  24 root  wheel    24 Apr  4  2015 var
$ 
```

This tool is designed to allow you to copy an existing thin jail into a thick jail,
ignoring the bits provided by the basejail.

# Usage:

```
thin_to_thick /usr/jails/newjail /usr/jails/myjail /iocage/jails/myjail/root
```

where:

```
/usr/jails/newjail        = example base jail
/usr/jails/myjail         = the jail you want to convert
/iocage/jails/myjail/root = the destination of the new thick jail
                            must already be created
```

NOTE: neither the src jail nor the dest jail may be running

# My cheat sheet for the steps describe below

Please see [example1.txt](example1.txt) for example commands I run based on the steps outlined below.

# Steps for converting a thin jail to a thick jail

In this example, we will assume:

* The thin jail was created by [ezjail](http://erdgeist.org/arts/software/ezjail/)
* The thick jail will be created using [iocage](https://github.com/iocage/iocage)
* The thin jail is located at /usr/jails/myjail
* The thick jail will be located at /iocage/jails/myjail

## 1 - stop the thin jail

```
ezjail-admin stop myjail
```

## 2 - create the thick jail

```
iocage create --thickjail -r 12.0-RELEASE -n myjail
```

The newly created thick jail must be the same release version as the old thin jail.

The author was concerned only getting the release name correct and was not concerned by patch levels (e.g. `FreeBSD 12.0-RELEASE-p7`).

## 3 - optionally snapshot the new jail

```
zfs snapshot -r system/iocage/jails/myjail@clean
```

The actual filesystem name will most certainly not match the above. `zfs list` will show you the information you need.

## 4 - Populate the iocage config.json file

iocage uses a configuration file using JSON format.  This file is located in the main directory. In our example, that is

```
$ cat /iocage/jails/myjail/config.json 
{
    "host_hostname": "myjail",
    "host_hostuuid": "myjail",
    "jail_zfs_dataset": "iocage/jails/myjail/data",
    "release": "12.0-RELEASE"
}
```

The above represents the values immediately after the `iocage create` command.

There are two important parts to set in this file:

* release information
* IP address

### 4.1 - release information

The release info can be found in the old basejail files via the freebsd-update executable:

```
$ grep USERLAND_VERSION= /usr/jails/basejail/bin/freebsd-version
USERLAND_VERSION="12.0-RELEASE-p7"
```

In this case, the release information is already correct.  This edit must be done manually. After update, the new values are.

```
{
    "host_hostname": "myjail",
    "host_hostuuid": "myjail",
    "jail_zfs_dataset": "iocage/jails/myjail/data",
    "release": "12.0-RELEASE-p7"
}
```

### 4.2 - IP address

The IP addresses for our ezjail jail are in /usr/local/etc/ezjail/myjail

```
$ grep ip= /usr/local/etc/ezjail/myjail
export jail_myjail_ip="10.55.0.70"
```

The new value can be configured via:

```
$ sudo iocage set ip4_addr="10.55.0.70" myjail
Property: ip4_addr has been updated to 10.55.0.70
```

The change can be confirmed via this command:

```
$ grep ip4_addr /iocage/jails/myjail/config.json 
    "ip4_addr": "10.55.0.70",
```

The above is the minimum you need to set. There may be ip6_addr values to set as well. You can see them in the output of the grep command above.

### 4.3 - Other jail settings

There are many other jail settings you may need to configure.  Here are a couple:

* hostname
* /etc/fstab.myjail
* /usr/local/etc/ezjail/myjail
* devfs rules

#### 4.3.1 - hostname

If the hostname does not exactly name the jailname, you might want to set that.

Here is the old hostname:

```
$ grep hostname /usr/local/etc/ezjail/myjail 
export jail_myjail_hostname="myjail.int.unixathome.org"
```

We set that via iocage:

```
iocage set host_hostname=myjail.int.unixathome.org myjail
```

#### 4.3.2 - /etc/fstab.myjail

If ezjil was mounting more than the basejail for your old jail, these can be easily copied into iocage as well.

Given our example, you want to look in /etc/fstab.myjail on the jail host.

```
$ cat /etc/fstab.myjail
/usr/jails/basejail /usr/jails/myjail/basejail nullfs ro 0 0
```

The basejail line isn’t needed in for our situation, because we are using thick jails. If there are other entries, you will
need to copy them to `/iocage/jails/myjail/fstab`. Be sure to adjust the pathname accordingly, base on where your iocage jails are located.

#### 4.3.3 - /usr/local/etc/ezjail/myjail

ezjail stores most configuration items in /usr/local/etc/ezjail/JAILNAME and in our example, /usr/local/etc/ezjail/myjail will contain settings we might want to copy over.

In the author's example, he found this:

```
export jail_myjail_parameters="enforce_statfs=0 allow.mount=1 allow.mount.zfs=1"
```

This will need to be set in iocage, usually via `iocage set` but the details are outside the scope for this task.

#### 4.3.4 - devfs rules

If this value is something other then 4, the default, you might want to set it.

```
$ grep devfs_rule /usr/local/etc/ezjail/myjail 
export jail_myjail_devfs_ruleset="7"
```

In my case, it was 7

```
$ sudo iocage set devfs_ruleset=7 myjail
Property: devfs_ruleset has been updated to 7
```

## 5 - run the script

The trailing / on the second parameter is vital.

```
thin_to_thick.sh /usr/jails/newjail /usr/jails/myjail/ /iocage/jails/myjail/root
```

Without it, your jail data will be copied to /iocage/jails/myjail/root/myjail/

## 6 - start the jail

```
iocage start myjail
```



# Post conversion

You will probably want to the set the old ezjail jail to not run on boot:

```
ezjail-admin config -r norun myjail
```

Similarly, when ready, set the iocage jail to start on boot:

```
iocage set boot=on myjail
```

Consider your backup strategy, now that you have two copies, old and new. At some point, delete the old.

Priority: ezjail uses rcorder-type strategies to decide what needs to start
in what order. If you find no values for this query, you have nothing to do:

```
grep REQUIRE /usr/local/etc/ezjail/*
```

Otherwise, you should analyst the REQUIRE and PROVIDE statements you find
in this directory and use the `iocage set priority` command to determine the
start order.
