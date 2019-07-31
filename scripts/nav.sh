#/bin/sh -e
# Set up NAV

date > /etc/nav_box_build_time

# Customize the message of the day
cat > /etc/motd <<EOF

Welcome to the Network Administration Visualized virtual appliance.

The 'packer' user, used to provision this VM, may still be on this system, but
the account has been locked and can be safely deleted.

For more information about NAV, please see https://nav.uninett.no/

EOF

apt-get install -y apt-transport-https makepasswd lsb-release software-properties-common
curl -fsSL https://nav.uninett.no/debian/gpg | apt-key add -  # UNINETT NAV APT repository

CODENAME=$(lsb_release -s -c)
add-apt-repository "deb https://nav.uninett.no/debian/ ${CODENAME} nav test"
if [ "$CODENAME" = "stretch" ]; then
    add-apt-repository "deb http://deb.debian.org/debian stretch-backports main"
fi

export DEBIAN_FRONTEND=noninteractive

random_pass=$(makepasswd --chars=12)

debconf-set-selections <<EOF
nav	nav/dbpass	password	$random_pass
nav	nav/db_purge	boolean	false
nav	nav/db_generation	boolean	true
nav	nav/apache2_restart	boolean	true
nav	nav/db_auto_update	boolean	true
EOF

apt-get -y update
if [ "$CODENAME" = "stretch" ]; then
    apt-get --force-yes -y install ca-certificates dirmngr
    apt-get --force-yes -y install python-psycopg2 graphite-carbon \
      python-whisper/stretch-backports graphite-web/stretch-backports
fi
apt-get --force-yes -y install nav

a2dissite 000-default
a2dissite default-ssl
a2ensite nav-default

# Ensure Carbon's UDP listener is enabled, and that Carbon doesn't initially
# limit the amount of new whisper files that can be created per minute.
CARBONCONF="/etc/carbon/carbon.conf"
sed -e 's/^MAX_CREATES_PER_MINUTE\b.*$/MAX_CREATES_PER_MINUTE = inf/g' -i "$CARBONCONF"
sed -e 's/^ENABLE_UDP_LISTENER\b.*$/ENABLE_UDP_LISTENER = True/g' -i "$CARBONCONF"

# enable carbon-cache start at boot time
sed -e 's/^CARBON_CACHE_ENABLED\b.*$/CARBON_CACHE_ENABLED=true/g' -i /etc/default/graphite-carbon

# Initialize graphite-web database
sudo -u _graphite graphite-manage migrate auth --noinput
sudo -u _graphite graphite-manage migrate --run-syncdb --noinput

# Configure graphite-web to use the same timezone as NAV's default
echo "TIME_ZONE='Europe/Oslo'" >> /etc/graphite/local_settings.py

# Configure graphite-web to run openly on port 8000
# WARNING: May be a security risk if port 8000 is exposed outside the virtual
# machine without authorization measures.
cat > /etc/apache2/sites-available/graphite-web.conf <<-EOF
Listen 8000
<VirtualHost *:8000>

	WSGIDaemonProcess _graphite processes=1 threads=1 display-name='%{GROUP}' inactivity-timeout=120 user=_graphite group=_graphite
	WSGIProcessGroup _graphite
	WSGIImportScript /usr/share/graphite-web/graphite.wsgi process-group=_graphite application-group=%{GLOBAL}
	WSGIScriptAlias / /usr/share/graphite-web/graphite.wsgi

	Alias /content/ /usr/share/graphite-web/static/
	<Location "/content/">
		SetHandler None
	</Location>

	ErrorLog \${APACHE_LOG_DIR}/graphite-web_error.log

	# Possible values include: debug, info, notice, warn, error, crit,
	# alert, emerg.
	LogLevel warn

	CustomLog \${APACHE_LOG_DIR}/graphite-web_access.log combined

</VirtualHost>

EOF
a2ensite graphite-web

# Configure carbon according to NAV's wishes
cp /etc/nav/graphite/*.conf /etc/carbon/

apache2ctl restart

# Enable NAV at start up
echo "Enable NAV to run at start up"
systemctl unmask nav

systemctl restart nav
systemctl stop nav
