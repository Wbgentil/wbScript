#!/bin/sh
#+------------+
#+ -- Vars -- +
#+------------+

SAIDA=''
TABLE=''
ROOTPASS=''
#+--------------+
#+ -- checks -- +
#+--------------+
if [[ $EUID -ne 0 ]]; then
   echo "Please, execute with root!" 1>&2
   exit 100
fi

[ "$1" == "man" ] && clear && printf "
    Use to manipulate permissions on MySQL database

    To use execute at the command line as follows:

    wb_db.sh -uname joao -opt \"GRANT ALL PRIVILEGES\" -database autoseg_production -host localhost

    \$1 -uname -> User who will be accessed at the bank (password will be required if required)
        example: -uname joao

    \$3 -opt: Change to
        -query  : To usage query on database;
        example: -query \"SELECT * FROM TABLE\"

        -grant  : To grant permissions to a user;
        example: -grant \"GRANT ALL PRIVILEGES\" 

        -revoke : To revoke permissions for a user;
        example: -revoke \"REVOKE ALL\"

    \$5 database -> Database where \$3 option will be executed
        example: -database autoseg_production
        NOTE: The database must have been previously created and the user must have permission on it.

    \$7 host -> Database ip host or localhost
        example: -host 192.168.0.43 or localhost (to local)
        NOTE: The user (\$2) must have permissions within the database for remote access, to know if the user has remote access permissions at the database use the following command within the given server database:

                SELECT host FROM mysql.user WHERE User = 'root';
    " && exit 1

[ $# -ne 8 ] && printf "Please use:\n -uname \$USERNAME -opt '\$QUERY' -database \$DATABASE -host \$IP_OR_LOCALHOST\n" && exit 1

if [ ! $1 == '-uname' ] || [ ! $3 == '-query' ] && [ ! $3 == '-revoke' ] && [ ! $3 == '-grant' ] || [ ! $5 == '-database' ] || [ ! $7 == '-host' ]; then
    printf "\nllegal arguments, see 'wb_db.sh man' for usage examples\n\n"
    exit 1
fi
#+--------------+
#+ -- header -- +
#+--------------+
#
#cat <<EOF
#
#
#+--------------------------------------------------+
#    --Author:           Wallace Bruno Gentil
#    --Mail:             w.brunoge@gmail.com
#    --License:          MIT
#+--------------------------------------------------+
#
#
#EOF
case $3 in
#
#   QUERY
#
    '-query')
        printf "Informe a senha do usuário $2 para executar a QUERY:"
        read -sp '' ROOTPASS
        sleep 2

        if [ "$(echo $4 | awk '{print $1}')" == "DELETE" ]; then
            printf "\n\nHey, your query is a delete are you sure you want to execute? Once deleted you will not be able to retrieve this data from the table! Unless you have a backup made! [y / n]"
            read -r $OPTION
            if [ "$OPTION" == "n" ]; then
                printf "\n\nPhew good, bye :)"
            fi
        fi 

        printf "\n\n%-120s" "Executando query de '$(echo $4 | awk '{print $1}')'"
        sleep 3

        QUERY=$(MYSQL_PWD=$ROOTPASS mysql -u $2 -h $8 -D $6 -e "$4")

        SAIDA=$?
        if [ $SAIDA -eq "0" ]; then echo -e "[    OK    ]"; else exit; fi
        sleep 2
printf "
${QUERY}
"
    ;;
    '-grant')
        printf "Informe a tabela [use * caso as GRANTS sejam para o banco todo]: "
        read -r TABLE
        sleep 1

        echo "Aguarde..."
        sleep 1

        printf 'Informe a senha do usuário ROOT para conceder os GRANTS: '
        read -r ROOTPASS

        printf "%-120s" "Concedendo GRANT para o usuário $2 "
        sleep 1

        QUERY=$(MYSQL_PWD=$ROOTPASS mysql -uroot -h $8 -e "$4 ON $6.$TABLE TO '$2'@'$8';
        FLUSH PRIVILEGES;")
        SAIDA=$?
        if [ $SAIDA -eq "0" ]; then echo -e "[    OK    ]"; else exit; fi
printf "
${QUERY}
"   
    ;;
    '-revoke')
        printf "Informe a tabela [use * caso o REVOKE seja para o banco todo]: "
        read -r TABLE
        sleep 1

        echo "Aguarde..."
        sleep 1

        printf 'Informe a senha do usuário ROOT para usar o REVOKE: '
        read -r ROOTPASS

        printf "%-120s" "Revogando permissões para o usuário $2 "
        sleep 1

        QUERY=$(MYSQL_PWD=$ROOTPASS mysql -uroot -h $8 -e "$4 ON $6.$TABLE FROM '$2'@'$8';
        FLUSH PRIVILEGES;")
        SAIDA=$?
        if [ $SAIDA -eq "0" ]; then echo -e "[    OK    ]"; else exit; fi
printf "
${QUERY}
"
esac
