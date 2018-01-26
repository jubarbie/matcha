# MATCHA

Matcha is a dating webapp

## Docker
### Create machine with mysql server
```sh
docker-machine create --driver virtualbox default
eval "$(docker-machine env default)"
docker run --name matcha_db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_USER=root -e MYSQL_PASSWORD=root -d mysql/mysql-server:8.0
```
### Connecting to mysql server with command line
```sh
docker exec -it matcha_db mysql -u root -p
```

### To solve the ER_NOT_SUPPORTED_AUTH_MODE error
```sql
use mysql;
update user set authentication_string=password('root'), plugin='mysql_native_password' where user='root';
flush privileges;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
```

## Building app
### Build backend server (dev)
```sh
cd matcha-backend && sh install-backend.sh
```

### Launch client server (dev)
```sh
cd matcha-client && sh install-client.sh
```

## Code edition tools:

### ELM for vim:
```sh
call plug#begin('~/.vim/plugged')
Plug 'elmcast/elm-vim'
call plug#end()
```
