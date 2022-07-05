# Debezium + ProxySQL Failover Demo

This demo aims to show Debezium failover behaviour when working with proxy sql.
it is heavily influenced by the debezium + HA proxy demo which can be seen here:

https://github.com/debezium/debezium-examples/tree/main/failover 

Its important to mention that the connector which will be created via the request file
will be set to work with the proxy sql address.

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

3. After all container are up and running, execute the commands in [setup.txt](./setup.txt) file - this will:
    - Set Mysql slaves replication (`MASTER_AUTO_POSITION`)
    - Create DB tables and insert data in Mysql master 
    - Set up proxySql between mysql 1 and mysql 2 - Debezium connector will connect via proxySql
    - Create a binlog consumer
    
## How To Reproduce Connector failover failure
The idea here is to cause a discrepancy in mysql1 and mysql2 binlogs, we're using `flush logs` for that.

1. Create the env as specified [above](#env-set-up)
2. Insert rows into MySQL Master - DML can be taken from [insert-data.txt](./insert-data.txt)
3. `flush logs;` on mysql 1
4. Insert rows into MySQL Master
5. `flush logs;` on mysql 2
6. Insert rows into MySQL Master
7. `flush logs;` on mysql 2
8. kill msql 1 container

At this point Debezium connector will fail.<br>
After that it's possible to restart mysql 1 container and restart Debezium connector failed task - 
this will result in a task recovery and Debezium connector will continue to stream data as expected.


### Where can i see my messages 
messages can be seen at http://localhost:8000 in the customer topic

### Stop the demo
```
lima nerdctl compose down