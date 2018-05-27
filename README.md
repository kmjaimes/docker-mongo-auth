# docker-mongo-auth

This will create a Dockerized MongoDB with
- authentication enabled
- root user & password
- admin user & password
- default database
- default database user (dbUser) & password

This is built from the official MongoDB image. When the variables
- MONGO_INITDB_ROOT_USERNAME
- MONGO_INITDB_ROOT_PASSWORD

are used, authorization and root user/password are created automatically. The additional users and database are created from a custom startup_script that is added to docker-entrypoint-initdb.d and run after the default docker-entrypoint. 

This build utilizes a .env file. ** Please change username and passwords to your own values. **

# Build

From the command line:
```
docker-compose build 
docker-compose up
```
If you are deploying this multiple times locally for development purposes, you'll need to clear volumes and images between deployments. 

# Access container and MongoDB

Exec into container:
```
docker exec -it <container name> bash
```
If using Git for Windows, use this:
```
winpty docker exec -it <container name> bash
```

Access MongoDB:
```
mongo -u <username> -p <password> --authenticationDatabase <authentication database name> 
```

For example:
```
mongo -u dbUser -p dbUser_pw --authenticationDatabase useful_database
```

