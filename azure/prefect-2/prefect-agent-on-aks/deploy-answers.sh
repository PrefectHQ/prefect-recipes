#!/usr/bin/expect -f 

set san [lindex $argv 0]
set conn_string [lindex $argv 1]
set timeout -1
spawn ./post-deploy.sh
match_max 100000
expect -exact "Found the following storage types:\r
0) Azure Blob Storage\r
    Store data in an Azure blob storage container.\r
1) File Storage\r
    Store data as a file on local or remote file systems.\r
2) Google Cloud Storage\r
    Store data in a GCS bucket.\r
3) Local Storage\r
    Store data in a run's local file system.\r
4) S3 Storage\r
    Store data in an AWS S3 bucket.\r
5) Temporary Local Storage\r
    Store data in a temporary directory in a run's local file system.\r
Select a storage type to create: "
send -- "0\r"
expect -exact "0\r
You've selected Azure Blob Storage. It has 2 option(s). \r
CONTAINER: "
send -- "$san\r"
expect -exact "$san\r
CONNECTION STRING: "
send -- "$conn_string\r"
expect -exact "$conn_string\r
Choose a name for this storage configuration: "
send -- "Azure\r"
expect "Would you like to set this as your default storage? \\\[Y/n\\\]: "
send -- "Y\r"
expect eof
