#Adapted from: https://github.com/aashreys/docker-mongo-auth, MIT License, Copyright (c) 2017 Aashrey Sharma
#Acquired 5/16/2018

#!/bin/bash

# Admin User
MONGO_ADMIN_USERNAME=${MONGO_ADMIN_USERNAME:-default_admin}
MONGO_ADMIN_PASSWORD=${MONGO_ADMIN_PASSWORD:-default_password}

# Application Database User
MONGO_DATABASE=${MONGO_DATABASE:-user_auth_database}
MONGO_DBUSER=${MONGO_DBUSER:-database_user}
MONGO_DBUSER_PASSWORD=${MONGO_DBUSER_PASSWORD:-database_user_password}

# Wait for MongoDB to boot
RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MongoDB service startup..."
    sleep 5
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
done

# Create the admin user
echo "=> Creating admin user with a password in MongoDB"
mongo admin --eval "db.createUser({user: '$MONGO_ADMIN_USERNAME', pwd: '$MONGO_ADMIN_PASSWORD', roles:[{role:'userAdminAnyDatabase',db:'admin'}]});"

sleep 3

# If we've defined the MONGO_DATABASE environment variable and it's a different database
# than admin, then create the user for that database.
# First it authenticates to Mongo using the admin user it created above.
# Then it switches to the new database and runs the createUser command 
# to actually create the user and assign it to the database.
if [ "$MONGO_DATABASE" != "admin" ]; then
    echo "=> Creating a $MONGO_DATABASE database user with a password in MongoDB"
    mongo -u "$MONGO_ADMIN_USERNAME" -p "$MONGO_ADMIN_PASSWORD" --authenticationDatabase "admin" << EOF
echo "Using $MONGO_DATABASE database"
use $MONGO_DATABASE
db.createUser({user: '$MONGO_DBUSER', pwd: '$MONGO_DBUSER_PASSWORD', roles:[{role:'dbOwner', db:'$MONGO_DATABASE'},{role:'readWrite', db:'$MONGO_DATABASE'}]})
EOF
fi

sleep 1

# Add a file as a flag so in the future to not re-create the
# users if container is being re-created (provided we're using some persistent storage)
touch /data/db/.mongodb_password_set

echo "MongoDB configured successfully."