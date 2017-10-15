# MATCHA

Matcha is a dating webapp

## Docker
### Create machine with mysql server
```sh
docker-machine create --driver virtualbox default
eval "$(docker-machine env default)"
docker run --name matcha_db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_USER=jubarbie -e MYSQL_PASSWORD=root -d mysql/mysql-server:8.0
```
### Connect to mysql server
```sh
docker exec -it matcha_db mysql -u root -p
```


## Build database
```sh
cd matcha-backend && node setup.js
```

## Launch backend server (dev)
```sh
cd matcha-backend && npm run watch
```

## Launch client server (dev)
```sh
cd matcha-client && npm run client
```

## Add superadmin user
```sh
curl -H "Content-Type: application/json" -X POST -d '{"username":"jubarbie","password":"jules123","email":"jubarbie@student.42.fr","lname":"Barbier","fname":"Jules","gender":"M","int_in":"M"}' http://localhost:3001/api/users/new/
```


# Code edition tools:

## ELM:
```sh
call plug#begin('~/.vim/plugged')
Plug 'elmcast/elm-vim'
call plug#end()
```
