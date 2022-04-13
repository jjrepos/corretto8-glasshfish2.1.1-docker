#!/bin/sh
#Start Domain
echo $JAVA_HOME
java -version

asadmin start-domain && asadmin set server.log-service.module-log-levels.corba=DEBUG;

if [ -f "$ADMIN_CMD_FILE" ]; then
  echo "INFO: Admin commands in file $ADMIN_CMD_FILE will be executed...";
  asadmin multimode --file $ADMIN_CMD_FILE;
  
  if [ $? -ne 0 ]; then
      echo "ERROR: One or more of the admin commands in file $ADMIN_CMD_FILE failed, exiting"
       asadmin stop-domain;
       exit 1;
  fi
else
    echo "INFO: No Admin commands to exectute, proceeding to deploy application...";
fi

#Check if application's war/ear file is available
if [ ! -f "$WAR_FILE" ]; then
    echo "ERROR: No application war/ear file $WAR_FILE found, stoppping domain and exiting... ";
    asadmin stop-domain;
    exit 1;
fi

#Deploy application
echo "INFO: Deploying file $WAR_FILE with context root $CONTEXT_ROOT";
asadmin deploy --contextroot $CONTEXT_ROOT --precompilejsp=$PRECOMPILE_JSP $WAR_FILE;

#Restart for changes to take efffect
echo "INFO: Stopping domain to make the above changes take effect...";
asadmin stop-domain;
asadmin start-domain --verbose;
