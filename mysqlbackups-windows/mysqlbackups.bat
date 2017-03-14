@ECHO OFF
c:\xampp\mysql\bin\mysqldump -u %1 -p%2 %3 > c:\mysqlbackups\%3.sql
rar a -ep1 -m5 -df c:\mysqlbackups\%3.rar c:\mysqlbackups\%3.sql
