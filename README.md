# Debezium + ProxySQL Failover Demo

This demo aims to reproduce Debezium's failure to failover when working with proxy sql.
it is heavily influenced by the debezium + HA proxy example, which can be seen [here](https://github.com/debezium/debezium-examples/tree/main/failover).

![alt text](https://github.com/AviMualem/debezium-proxysql-failover/blob/main/demo.jpeg?raw=true)

## Topology
The deployment consists of the following components

* Database
  * MySQL Master instance with GTID enabled
  * MySQL 1 (salve to MySQL Master) instance with GTID enabled
  * MySQL 2 (salve to MySQL Master) instance with GTID enabled
* Proxy
	* proxy sql (https://proxysql.com/)
* Streaming system
  * Apache ZooKeeper
  * Apache Kafka broker
  * Apache Kafka Connect with Debezium MySQL Connector - the connector will connect to proxy sql

## Env Set Up
1. Build images and start the containers 
```
lima nerdctl compose up --build
```

2. After all container are up and running, execute the following commands to set up proxySql with mysql slave 1 and mysql slave 2:
```
lima nerdctl exec -it debezium-proxysql-failover_proxysql_1 bash -c 'mysql -u admin -padmin -h 127.0.0.1 -P 6032'

INSERT INTO mysql_servers(hostgroup_id,hostname,port,weight) VALUES (0,'mysql1',3306,10000000);
INSERT INTO mysql_servers(hostgroup_id,hostname,port,weight) VALUES (0,'mysql2',3306,1);
UPDATE global_variables SET variable_value='proxysql' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='$3Kr$t' WHERE variable_name='mysql-monitor_password';
INSERT INTO mysql_users (username,password,fast_forward) VALUES ('debezium','dbz',1);
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
update global_variables set variable_value='false' where variable_name='admin-hash_passwords';
load admin variables to runtime; 
save admin variables to disk;
load mysql users to runtime;
save mysql users to disk;
LOAD MYSQL SERVERS TO RUNTIME;
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;   
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
```

3. Start a binlog Debezium connector by the following. Note that the connector is set to work with the proxy sql address - for failover capabilities.
```
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-mysql.json
```

## How To Reproduce Connector failover failure
The idea here is to cause a discrepancy in mysql1 and mysql2 binlogs, we're using `flush logs` for that.

1. Create the env as specified [above](#env-set-up)
2. Insert rows into MySQL Master - DMLs can be taken from [insert-data.txt](./insert-data.txt)
3. `flush logs;` on mysql 1
4. Insert rows into MySQL Master
5. `flush logs;` on mysql 2
6. Insert rows into MySQL Master
7. `flush logs;` on mysql 2
9. kill mysql 1 container

At this point Debezium connector will fail.
Even in case the connector's task is restarted (`curl -X POST http://localhost:8083/connectors/inventory-connector/tasks/0/restart`) the connector will not recover.<br>

### Where can I see my messages 
messages can be seen at http://localhost:8000 in the customer topic

### Stop the demo
```
lima nerdctl compose down
```