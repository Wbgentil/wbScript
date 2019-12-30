#!/bin/bash
#+----------+
#+-- VARS --+
#+----------+

declare -a C_FULLNAME
declare -a C_UNAME
declare -a C_PASSWORD
declare -a C_GROUP
SAIDA=''

#+--------------+
#+ -- checks -- +
#+--------------+

if [ -z "$1" ]; then
   printf -e 'Args 1: Invalid please use:
   bash wb_user.sh /home/{USER}/path/list_user.csv [$2]
   '
   exit 1
fi

if [ ! -f $1 ] && [ ! $1 == *.csv ]; then
   printf 'Please use a .CSV file \n'
   exit 1
fi

if [ -z "$2" ]; then
cat <<EOF
   Args 2: Invalid please use:
   -new           : To create user;
   -rm            : To remove user;
   -lock          : To block accont user;
   -unlock        : To unlock accont user;
   -update        : To update a value to user:
EOF
fi
