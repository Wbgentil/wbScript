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

new(){
    while IFS=, read -r fullname uname password groups; do
      C_FULLNAME+=($fullname)
      C_UNAME+=($uname)
      C_PASSWORD+=($password)
      C_GROUP+=($groups)
    done <"$1"

    for i in "${!C_UNAME[@]}"; do
      useradd -g "${C_GROUP[$i]}" -s /bin/bash -p "$(echo "${C_PASSWORD[$i]}" | openssl passwd -1 -stdin)" "${C_UNAME[$i]}" 1>/dev/null 2>/dev/null
         SAIDA=$?
         if [ "$SAIDA" -eq 0 ]; then
            printf "User ${C_UNAME[$i]} has been create with success! \n"
         elif [ "$SAIDA" -eq 6 ]; then
            printf "Error to create user ${C_UNAME[$i]}, group ${C_GROUP[$i]} not found\n"
            exit 1
         elif [ "$SAIDA" -eq 9 ]; then
            printf "User ${C_UNAME[$i]} exist\n"
         else
            printf "An error occurred, please contact admin system \n"
            exit 1
         fi
   done
}

rm(){
    while IFS=, read -r fullname uname password groups; do
        C_UNAME+=($uname)
    done <"$1"

    for i in "${!C_UNAME[@]}"; do
        userdel "${C_UNAME[$i]}" 2>/dev/null
        SAIDA=$?
        if [ $SAIDA -eq 0 ]; then
            printf "User ${C_UNAME[$i]} has been removed \n"
        elif [ $SAIDA -eq 6 ]; then
            printf "User ${C_UNAME[$i]} not found \n"
        fi
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
      new $1
   ;; -rm)
      rm $1
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
