create user '{SUPER_USER}'@'%' identified with 'mysql_native_password' by '{SUPER_PASSWORD}';
grant all privileges on *.* to '{SUPER_USER}'@'%' with grant option;
flush privileges;
