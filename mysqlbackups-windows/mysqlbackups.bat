@ECHO OFF
c:\xampp\mysql\bin\mysqldump -u %1 -p%2 %3 > c:\mysqlbackups\%3.sql
rar a -ep1 -m5 -df c:\mysqlbackups\%3_%date:~-7,2%-%date:~-10,2%-%date:~-4,4%.rar c:\mysqlbackups\%3.sql
