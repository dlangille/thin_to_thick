#!/bin/sh

CAT="/bin/cat"
ECHO="/bin/echo"
FIND="/usr/bin/find"
RSYNC="/usr/local/bin/rsync"
SED="/usr/bin/sed"

# This is not the new jail you are creating.
# This is the newjail directory used to create new jails in your old system
# For ezjail, this is usually /usr/jails/newjail
NEW_JAIL=$1

# the source of the old jail, e.g. /usr/jails/snapshots/
SRC_JAIL=$2

# the destination of the new jail, e.g. /iocage/jails/snapshots2/root/
DST_JAIL=$3

if [ ! -d "${NEW_JAIL}"  ]
then
   echo "The base newjail ('${NEW_JAIL}') must exist and must be a directory"
   exit 1
fi

if [ ! -d "${SRC_JAIL}" ]
then
   echo "The source jail ('${SRC_JAIL}') must exist and must be a directory"
   exit 1
fi

if [ ! -d "${DST_JAIL}" ]
then
   echo "The destination jail ('${DST_JAIL}') must exist and must be a directory"
   exit 1
fi

if [ -e "/basejail" ]
then
  echo "/basejail exists, and this will interfere with the rsync process"
  exit
fi

# create a temp file, usually something like /tmp/conversion.TNXmkd832
TMPFILE1=`mktemp -t conversion1`

#
# find all symlinks in the basejail (this must not be the jail you are 
# converting). It must be the newjail, the one used to create new jails.
# e.g. /usr/jails/newjail when using ezjail
#
echo finding symlinks in new jail: ${NEW_JAIL}
${FIND} ${NEW_JAIL} -type l -exec ls -d {} \; | sort > ${TMPFILE1}

${ECHO} 'original NEW JAIL symlinks, full paths'
for link in `${CAT} ${TMPFILE1}`
do
  ${ECHO} ${link}
done

# I tried s:^${NEW_JAIL}... but this changes only the first value, because this is a single line
#NO_RSYNC_RELATIVE_PATHS=`${ECHO} ${NO_RSYNC_FULL_PATHS} | ${SED} -re "s:${NEW_JAIL}::g"`

TMPFILE2=`mktemp -t conversion2`
${SED} -re "s:${NEW_JAIL}::g" ${TMPFILE1} > ${TMPFILE2}
${ECHO} 'modified NEW JAIL symlinks, relative paths'
for link in `${CAT} ${TMPFILE2}`
do
  ${ECHO} ${link}
done

${RSYNC} --progress -a --links --exclude-from=${TMPFILE2} ${SRC_JAIL} ${DST_JAIL}

# cleaning time
rm ${TMPFILE1} ${TMPFILE2}
