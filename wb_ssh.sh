#!/bin/sh
#+------------+
#+ -- Vars -- +
#+------------+

SAIDA=''
#+--------------+
#+ -- checks -- +
#+--------------+

if [ "$1" == "man" ] && [ ! "$1" == "-u" ]; then
    clear 
    printf "This script was made for remote access on Linux machines,

Method 1: Passing the password, to use:
    bash wb_ssh.sh -u \$USER -p -h \$IP

Method 2: Without Passing the Password, to Use:
    bash wb_ssh.sh -u \$USER -h \$IP

NOTE: Passwordless access requires a public key for the user on the target machine.

"
    exit 1
fi

case $3 in
    '-p')
        case $5 in
            '-h')
                sshpass -p "$4" ssh $2@$6
            ;;
            *)
                printf "Illegal argument. Please use 'wb_ssh.sh man' to see examples how to use\n"
            ;;
        esac
    ;;
    '-h')
        ssh $2@$4
    ;;
    *)
        printf "Illegal argument. Please use 'wb_ssh.sh man' to see examples how to use\n"
    ;;
esac

