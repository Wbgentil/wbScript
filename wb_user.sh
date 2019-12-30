#!/bin/bash
#+----------+
#+-- VARS --+
#+----------+

declare -a C_FULLNAME
declare -a C_UNAME
declare -a C_PASSWORD
declare -a C_GROUP
SAIDA=''

#+----------+
#+-- FUNC --+
#+----------+

CSV_READ(){
   while IFS=, read -r fullname uname password groups others; do
      C_UNAME+=($uname)
      C_PASSWORD+=($password)
      C_GROUP+=($groups)
   done <"$1"

   echo "${!C_UNAME[@]}"

   for i in "${!C_UNAME[@]}"; do
      printf "Username: ${C_UNAME[$i]}\n"
      printf "Password: ${C_PASSWORD[$i]}\n"
      printf "Grupo: ${C_GROUP[$i]}\n\n"
   done
}
#+----------+
#+-- CHEK --+
#+----------+

if [ -z "$1" ]; then
   printf -e 'Args 1: Invalid please use:
   bash wb_user.sh /home/{USER}/path/list_user.csv [$2]
   '
   exit 1
fi

if [ "$1" == "man" ] || [ "$1" == "MAN" ]; then
   printf "To use this script use a follow example:
   wb_user.sh /home/user/docs/file.csv -opt
   
   Where: \$1 is .CSv file path
          \$2 is option\n"

   exit 1
fi

if [ ! -f $1 ] && [ ! $1 == *.csv ] ; then
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

case $2 in 
   -new)
      CSV_READ $1
   ;; -rm)
      echo "rm"
   ;; -update)
      echo "update"
   ;; -lock)
      echo "lock"
   ;; -unlock)
      echo "unlock"
   ;; *)
      echo "invalid"
   ;;
esac
