# thin_to_thick
Converts a thin jail to a thick jail

A thin jail often uses a nullfs mount to supply the main jail directories.

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

#Usage:

```
thin_to_thick /usr/jails/newjail /usr/jails/snapshots /iocage/jails/snapshots3/root
```

where:

```
/usr/jails/newjail            = example base jail
/usr/jails/snapshots          = the jail you want to convert
/iocage/jails/snapshots3/root = the destination of the new thick jail
                                must already be created
```

NOTE: neither the src jail nor the dest jail may be running
