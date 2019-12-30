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

[ $# -ne 8 ] && printf "Please use:\n -uname \$USERNAME -query '\$QUERY' -database \$DATABASE -host \$IP_OR_LOCALHOST\n" && exit 1

if [ ! $1 == '-uname' ] || [ ! $3 == '-query' && ! $3 == '-revoke' && ! $3 == '-grant' ] || [ ! $5 == '-database' ] || [ ! $7 == '-host' ]; then
    printf "\nllegal arguments, see 'wb_db.sh man' for usage examples\n\n"
    exit 1
fi