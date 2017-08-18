yum -y update
yum -y upgrade
yum -y install php php-gd
yum -y install httpd openssl mod_ssl

# disable some Apache options
cat pentos-web-options-conf.stub >> /etc/httpd/conf.d/options.conf

# configure PHP
tfile=$(mktemp)
cp /etc/php.ini ${tfile}
cat ${tfile} | sed 's/^expose_php =.*$/expose_php = Off/' > /etc/php.ini
rm ${tfile}

systemctl enable httpd
systemctl start httpd
systemctl status httpd

# clean
# rm -rf /usr/share/dokuwiki
# rm /var/www/html/wiki

# install dokuwiki
#cd ../downloads
#tar xvzf dokuwiki-stable.tgz
#mv dokuwiki-2017-02-19c dokuwiki
#mv dokuwiki /usr/share 

# install vector template
#tar xvzf 2014-02-09_vector.tar.gz
#mv vector /usr/share/dokuwiki/lib/tpl/

# install customizations
#cp ../deploy/pentos_logo.png /usr/share/dokuwiki/lib/tpl/dokuwiki/images/logo.png
#cp ../deploy/pentos_logo.png /usr/share/dokuwiki/lib/tpl/vector/user/logo.png
#cp ../deploy/acl.auth.php /usr/share/dokuwiki/conf
#cp ../deploy/local.php /usr/share/dokuwiki/conf
#cp ../deploy/plugins.local.php /usr/share/dokuwiki/conf
#cp ../deploy/users.auth.php /usr/share/dokuwiki/conf
#cp ../deploy/htaccess.dist /usr/share/dokuwiki

# remove initial setup
#rm /usr/share/dokuwiki/install.php

# secure setup in httpd.conf
cat pentos-wiki-httpd-conf.stub >> /etc/httpd/conf/httpd.conf
cat pentos-wiki-options-conf.stub >> /etc/httpd/conf.d/options.conf

chcon -Rv --type=httpd_sys_rw_content_t /usr/share/dokuwiki
chown -R apache:apache /usr/share/dokuwiki

pdir=$(pwd  | sed 's/build/wiki/')
ln -s "$(pdir)/wiki" /usr/share/dokuwiki
ln -s /usr/share/dokuwiki /var/www/html/wiki

find /usr/share/dokuwiki/data -type d -exec chmod 700 {} \;
find /usr/share/dokuwiki/conf -type d -exec chmod 700 {} \;
find /usr/share/dokuwiki/bin -type d -exec chmod 700 {} \;
find /usr/share/dokuwiki/inc -type d -exec chmod 700 {} \;

cd -

systemctl restart httpd
systemctl status httpd

