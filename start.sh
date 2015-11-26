#! /bin/bash -x

# Check mandatory parameters
fail=0
[ -z "$SMTP_HOST" ] && fail=1
[ -z "$POSTGRES_URL" ] && fail=1
[ $fail -eq 1 ] && echo "Missing mandatory paramaters, SMPT_HOST and POSTGRES_URL must be set." && exit 1

# OPENSMTPD SETTINGS
smtp_port=25
clamd_port=3310

[ -z "$SMTP_HOST" ] || smtp_host="$SMTP_HOST"
[ -z "$SMTP_PORT" ] || smtp_port="$SMTP_PORT"
[ -z "$SMTP_USER" ] || smtp_user="$SMTP_USER"
[ -z "$SMTP_PASS" ] || smtp_password="$SMTP_PASS"
[ -z "$SMTP_USER" ] || smtp_auth_needed="true"
[ -z "$SMTP_PASS" ] || smtp_auth_needed="true"

# POSTGRESQL SETTINGS

[ -z "$POSTGRES_USER" ] || postgres_username="$POSTGRES_USER"
[ -z "$POSTGRES_PASS" ] || postgres_password="$POSTGRES_PASS"
[ -z "$POSTGRES_URL" ]  || postgres_url="$POSTGRES_URL"

# CLAMD SETTINGS

[ -z "$CLAMD_HOST" ] || clamd_host="$CLAMD_HOST"
[ -z "$CLAMD_PORT" ] || clamd_port="$CLAMD_PORT"

# LINSHARE OPTIONS (WARNING : modifying these settings is at your own risks)
dir_source=webapps/linshare/WEB-INF/classes
dir_target=/etc/linshare

# Allow to tweak JVM settings
[ -z "$JAVA_OPTS" ] || java_opts="$JAVA_OPTS"
export JAVA_OPTS="-Djava.awt.headless=true -Xms512m -Xmx1536m -XX:-UseSplitVerifier
                  -XX:+UseConcMarkSweepGC -XX:MaxPermSize=256m
                  -Dlinshare.config.path=file:${dir_target}/
                  -Dlog4j.configuration=file:${dir_target}/log4j.properties
                  ${java_opts}"

# Extracting .war's files
unzip -qq webapps/linshare.war -d webapps/linshare

# Making /etc/linshare if doesn't exists
[ -d /etc/linshare ] || mkdir /etc/linshare

custom_linshare=0
custom_log4j=0

# Copying configuration files for later customization
[ -f "$dir_target/linshare.properties" ] && custom_linshare=1
[ -f "$dir_target/log4j.properties" ] && custom_log4j=1
[ $custom_linshare -eq 0 ] && cp $dir_source/linshare.properties.sample $dir_target/linshare.properties
[ $custom_log4j -eq 0 ] && cp $dir_source/log4j.properties $dir_target/log4j.properties
[ $custom_log4j -eq 0 ] && sed -i "s/log4j.category.org.linagora.linshare.*/log4j.category.org.linagora.linshare=info/" $dir_target/log4j.properties

if [ $custom_linshare -eq 0 ]; then
    echo -e "Configuring Linshare settings"
    target="${dir_target}/linshare.properties"

    # Uncommenting clamav related configuration if needed
    [ -z "$smtp_host" ]         || sed -i "s@mail.smtp.host.*@mail.smtp.host=${smtp_host}@" $target
    [ -z "$smtp_port" ]         || sed -i "s@mail.smtp.port.*@mail.smtp.port=${smtp_port}@" $target
    [ -z "$smtp_user" ]         || sed -i "s@mail.smtp.user.*@mail.smtp.user=${smtp_user}@" $target
    [ -z "$smtp_password" ]     || sed -i "s@mail.smtp.password.*@mail.smtp.password=${smtp_password}@" $target
    [ -z "$smtp_auth_needed" ]  || sed -i "s@mail.smtp.auth.needed.*@mail.smtp.auth.needed=true@" $target
    [ -z "$postgres_username" ] || sed -i "s@linshare.db.username.*@linshare.db.username=${postgres_username}@" $target
    [ -z "$postgres_password" ] || sed -i "s@linshare.db.password.*@linshare.db.password=${postgres_password}@" $target
    [ -z "$postgres_url" ]      || sed -i "s@linshare.db.url.*@linshare.db.url=${postgres_url}@" $target
    [ -z "$clamd_host" ]        || sed -i "s@#virusscanner.clamav.host.*@virusscanner.clamav.host=${clamd_host}@" $target
    [ -z "$clamd_port" ]        || sed -i "s@#virusscanner.clamav.port.*@virusscanner.clamav.port=${clamd_port}@" $target

fi

/bin/bash /usr/local/tomcat/bin/catalina.sh run

