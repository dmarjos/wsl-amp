sed -i '/AcceptFilter http/d' /etc/apache2/apache2.conf
echo "AcceptFilter http none" >> /etc/apache2/apache2.conf
echo "AcceptFilter https none" >> /etc/apache2/apache2.conf
