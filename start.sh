#!/bin/bash

custom=false

# Check mandatory parameters
[[ ( -z "$SMTP_HOST" ) || ( -z "$POSTGRES_URL" ) ]] && \
echo "Missing mandatory paramaters, SMPT_HOST and POSTGRES_URL must be set." && \
exit 1

# OPENSMTPD SETTINGS
smtp_auth_needed=false

[ -z "$SMTP_HOST" ]	   || 	smtp_host="$SMTP_HOST"
[ -z "$SMTP_PORT" ]    ||	smtp_port="$SMTP_PORT"
[ -z "$SMTP_USER" ]    || 	smtp_user="$SMTP_USER"
[ -z "$SMTP_PASS" ]    || 	smtp_password="$SMTP_PASS"
[[ ( -z "$SMTP_USER" ) || ( -z "$SMTP_PASS" ) ]] || smtp_auth_needed=true

# POSTGRESQL SETTINGS

[ -z "$POSTGRES_USER" ] ||	postgres_username="$POSTGRES_USER"
[ -z "$POSTGRES_PASS" ] ||	postgres_password="$POSTGRES_PASS"
[ -z "$POSTGRES_URL" ]  ||	postgres_url="$POSTGRESURL_URL"

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

# Copying configuration files for later customization
[ -f "$dir_target/linshare.properties" ] 	&& custom=true || cp $dir_source/linshare.properties.sample $dir_target/linshare.properties
[ -f "$dir_target/log4j.properties" ] 		&& custom=true || cp $dir_source/log4j.properties $dir_target/log4j.properties

if [ $custom == true ]; then

	# Declaring the settings's matrix
	declare -A LINSHARE_SETTINGS

	LINSHARE_SETTINGS=(\
		[mail_smtp_host]=$smtp_host \
		[mail_smtp_port]=$smtp_port \
		[mail_smtp_user]=$smtp_user \
		[mail_smtp_password]=$smtp_password \
		[mail_smtp_auth_needed]=$smtp_auth_needed \
		[linshare_db_username]=$postgres_username \
		[linshare_db_password]=$postgres_password \
		[linshare_db_url]=$postgres_url \
		[virusscanner_clamav_host]=$clamd_host \
		[virusscanner_clamav_port]=$clamd_port)

	echo -e "Configuring Linshare settings"
	target="${dir_target}/linshare.properties"

	# Uncommenting clamav related configuration if needed
	[ -z "$CLAMD_HOST" ] || sed -i "/#virusscanner/virusscanner/" $target

	for k in "${!LINSHARE_SETTINGS[@]}"
	do
		# Substituing underscore to point
	    property="${k//_/\.}"

	    # Continue if variable is empty
	    [ -z "$k" ] && continue

	    # Replacing property's default value by our
	    sed -i "s@(${property}=).*\$@1${LINSHARE_SETTINGS[$k]}@g" $target
	done

fi

sh /usr/local/tomcat/bin/catalina.sh run
