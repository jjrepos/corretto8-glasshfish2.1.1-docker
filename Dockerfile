FROM amazoncorretto:8-alpine-jdk

ENV LANG C.UTF-8
# Configure ENV variables for glassfish and ant
ENV GLASSFISH_HOME /usr/lib/glassfish
ENV ANT_VERSION 1.6.5
ENV ANT_HOME $GLASSFISH_HOME/lib/ant
ENV PATH=$PATH:$GLASSFISH_HOME/bin:$ANT_HOME/bin


ENV APP_HOME /app
ENV PATH $APP_HOME/bin:$PATH
ENV ADMIN_CMD_FILE $APP_HOME/conf/asadmin-commands.txt
ENV WAR_FILE $APP_HOME/app.war
ENV CONTEXT_ROOT /app
ENV PRECOMPILE_JSP false

RUN \
    cd /usr/lib && \
    wget -O glassfish.jar http://dlc-cdn.sun.com/javaee5/v2.1.1_branch/promoted/Linux/glassfish-installer-v2.1.1-b31g-linux.jar && \
    echo A | java -jar glassfish.jar && \
    # Remove jar to save space
    rm -f glassfish.jar && \
    cd /usr/lib/glassfish && \
    # Remove Windows .bat and .exe files to save space
    find . -name '*.bat' -delete && \
    find . -name '*.exe' -delete && \
    # Configure executables, modify setup.xml to support Java 7 then run setup
    chmod -R +x lib/ant/bin && \
    sed -i 's/1.6/1.8/g' setup.xml && \
    lib/ant/bin/ant -f setup.xml && \
    chmod a+x bin/asadmin && \
    # Remove glassfish's expired certs and add new GlobalSign Root CA R3 cert
    keytool -storepass changeit -delete -v -alias gtecybertrustglobalca -keystore $GLASSFISH_HOME/domains/domain1/config/cacerts.jks && \
    keytool -storepass changeit -delete -v -alias gtecybertrust5ca -keystore $GLASSFISH_HOME/domains/domain1/config/cacerts.jks && \
    keytool -storepass changeit -delete -v -alias verisignserverca -keystore $GLASSFISH_HOME/domains/domain1/config/cacerts.jks

ENV GLASSFISH_CLASSPATH $GLASSFISH_HOME/lib/*:$GLASSFISH_HOME/domains/domain1/lib/*:$GLASSFISH_HOME/lib/install/applications/admingui/adminGUI_war/WEB-INF/lib/*:$GLASSFISH_HOME/lib/SUNWjdmk/5.1/lib/*:$GLASSFISH_HOME/lib/ant/lib/*:$GLASSFISH_HOME/jbi/lib/*:$GLASSFISH_HOME/javadb/lib/*:$GLASSFISH_HOME/javadb/demo/programs/localcal/lib/*:$GLASSFISH_HOME/updatecenter/lib/*:$GLASSFISH_HOME/imq/lib/*

RUN mkdir -p $APP_HOME/conf

WORKDIR $APP_HOME
ADD bin/entrypoint.sh bin/entrypoint.sh
ADD default-web.xml /usr/lib/glassfish/domains/domain1/config/default-web.xml
RUN chmod +x bin/entrypoint.sh

# Expose ports for admin panel and websites
# localhost:4848 -> user:admin ; pwd:adminadmin
EXPOSE 8080 4848

ENTRYPOINT entrypoint.sh
