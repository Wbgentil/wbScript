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
        userdel "${C_UNAME[$i]}" 
        SAIDA=$?
        if [ $SAIDA -eq 0 ]; then
            printf "User ${C_UNAME[$i]} has been removed \n"
        elif [ $SAIDA -eq 6 ]; then
            printf "User ${C_UNAME[$i]} not found \n"
        fi
    done
}

lock(){
    while IFS=, read -r fullname uname password groups; do
        C_UNAME+=($uname)
    done <"$1"

    for i in "${!C_UNAME[@]}"; do
        usermod -L "${C_UNAME[$i]}" 2>/dev/null
        SAIDA=$?
        if [ $SAIDA -eq 0 ]; then
            printf "User ${C_UNAME[$i]} locked \n"
        else
            printf "Generic Error \n"
        fi
    done
}

unlock(){
    while IFS=, read -r fullname uname password groups; do
        C_UNAME+=($uname)
    done <"$1"

    for i in "${!C_UNAME[@]}"; do
        usermod -U "${C_UNAME[$i]}"
        SAIDA=$?
        if [ $SAIDA -eq 0 ]; then
            printf "User ${C_UNAME[$i]} unlocked \n"
        else
            printf "Generic Error \n"
        fi
    done
}

update(){
   while IFS=, read -r fullname olduname newuname newpassword groups others; do
      C_OLDUNAME+=($olduname)
      C_NEWUNAME+=($newuname)
      C_NEWPASSWORD+=($newpassword)
      C_GROUP+=($groups)
   done <"$1"
   echo "$groups"
cat <<EOF
   Select a option:
   1. Change Password
   2. Add user a new Group
   3. Add user a SUDO/WHEEL group
   4. Change the username
EOF

   read OPTION
   case $OPTION in
      1)
         for i in "${!C_OLDUNAME[@]}"; do
            echo -e "${C_NEWPASSWORD[$i]}" | passwd --stdin "${C_OLDUNAME[$i]}"
         done
      ;;
      2)
         for i in "${!C_OLDUNAME[@]}"; do
            usermod -a -G "${C_GROUP[$i]}" "${C_OLDUNAME[$i]}"
            if [ $? -eq 0 ]; then
               printf "User ${C_OLDUNAME[$i]} has been add in ${C_GROUP[$i]}\n"
            else
               printf "Generic Error in add a user in group, please contact your admin"
               exit 1
            fi
         done
      ;;
      3)
         for i in "${!C_OLDUNAME[@]}"; do
            usermod -a -G wheel "${C_OLDUNAME[$i]}"
            if [ $? -eq 0 ]; then
               printf "User ${C_OLDUNAME[$i]} has been add in ${C_GROUP[$i]} \n"
            else
               printf "Generic Error in add a user in group, please contact your admin \n"
               exit 1
            fi
         done
      ;; 
      4)
         for i in "${!C_OLDUNAME[@]}"; do
            if [ ! "${C_NEWUNAME[$i]}" == "${C_OLDUNAME[$i]}" ]; then
               usermod -l "${C_NEWUNAME[$i]}" "${C_OLDUNAME[$i]}" 1>/dev/null 2>/dev/null
               SAIDA=$?
               if [ $SAIDA -eq 0 ]; then
                  printf "Username changed from ${C_OLDUNAME[$i]} to ${C_NEWUNAME[$i]} \n"
               elif [ $SAIDA -eq 8 ]; then
                  printf "User ${C_OLDUNAME[$i]} has open process, please kill processes with 'ps -ef | grep ${C_OLDUNAME[$i]}' and try again \n"
               fi
            fi
         done
      ;;
      *)
         printf "Invalid option, please try again"
         exit 1
      ;;
   esac
}
#+----------+
#+-- CHEK --+
#+----------+
if [[ $EUID -ne 0 ]]; then
   echo "Please, execute with root!" 1>&2
   exit 100
fi

if [ -z "$1" ]; then
   printf -e 'Args 1: Invalid please use:
   bash wb_user.sh /home/{USER}/path/list_user.csv [$2]
   '
   exit 1
fi

if [ "$1" == "man" ] || [ "$1" == "MAN" ]; then
   printf "To use this script use a follow example:
   wb_user.sh /home/user/docs/file.csv -opt
   
   Where: \$1 is .CSV file path
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
      update $1
   ;; -lock)
      lock $1
   ;; -unlock)
      unlock $1
   ;; *)
      printf "Invalid arg, please use wb_user.sh man to example\n"
   ;;
esac
