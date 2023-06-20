#!/bin/bash

echo "Usage: $0 mode(1:acct_table | 2:qos_table | 3:task_table | 4:user_table | 5:all | 6:acct_table+qos_table+user_table)"

if [ "$#" -ne 1 ]; then
  echo "Parameter error: please input mode num!"
  exit 1
fi

mode=$1

# 读取配置文件中的账号密码以及unqlite文件路径
confFile=/etc/crane/config.yaml
username=$(grep 'DbUser' "$confFile" | awk '{print $2}')
password=$(grep 'DbPassword' "$confFile" | awk '{print $2}')
password=${password//\"/}
unqpath=$(grep 'CraneCtldDbPath' "$confFile" | awk '{print $2}')

# MongoDB服务器的地址和端口
host="localhost"
port="27017"

# 使用mongo shell连接到MongoDB服务器并清空指定的集合

function wipe_collection() {
  mongosh --username "$username" --password "$password" --host "$host" --port "$port" <<EOF
    use crane_db
    db.$1.deleteMany({})
    exit
EOF
}

if [ "$mode" -eq 1 ] || [ "$mode" -eq 5 ] || [ "$mode" -eq 6 ]; then
  wipe_collection acct_table
fi
if [ "$mode" -eq 2 ] || [ "$mode" -eq 5 ] || [ "$mode" -eq 6 ]; then
  wipe_collection qos_table
fi
if [ "$mode" -eq 3 ] || [ "$mode" -eq 5 ]; then
  wipe_collection task_table

  if [ -e "$unqpath" ]; then
    echo "Removing file $unqpath ..."
    rm "$unqpath"
  fi
fi
if [ "$mode" -eq 4 ] || [ "$mode" -eq 5 ] || [ "$mode" -eq 6 ]; then
  wipe_collection user_table
fi
