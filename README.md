# matcha

To launch app:

# DOCKER
docker-machine create --driver virtualbox default
eval "$(docker-machine env default)"
docker run --name matcha_db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_USER=jubarbie -e MYSQL_PASSWORD=root -d mysql/mysql-server:8.0

# BUILD DATABASE
cd matcha-backend && node setup.js

# LAUNCH CLIENT SERVER (DEV)
cd matcha-client && npm run client

# LAUNCH BACKEND SERVER (DEV)
cd matcha-backend && npm run watch

# ADD SUPERADMIN USER
curl -H "Content-Type: application/json" -X POST -d '{"username":"jubarbie","password":"jules123","email":"jubarbie@student.42.fr","lname":"Barbier","fname":"Jules","gender":"M","int_in":"M"}' http://localhost:3001/api/users/new/


# Code edition tools:

ELM:
call plug#begin('~/.vim/plugged')
Plug 'elmcast/elm-vim'
call plug#end()
