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
  * MySQL 1 (salve) instance (configured as a slave to SQL Master) with GTID enabled
  * MySQL 2 (salve) instance (configured as a slave to SQL Master) with GTID enabled
* Proxy
	* proxy sql (https://proxysql.com/)
* Streaming system
  * Apache ZooKeeper
  * Apache Kafka broker
  * Apache Kafka Connect with Debezium MySQL Connector - the connector will connect to proxy sql

## Demonstration

1. Load the environment
```
lima nerdctl compose up --build
```

2. After all container are up and running, execute the command in [setup.txt](./setup.txt) file - this will set up
  - Mysql slaves replication
  - Create DB tables and insert data 
  - Set up proxySql between mysql server 1 and mysql server 2

### Creating a binlog only connector
Start the components and register Debezium to stream changes from the database
```
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-mysql.json
```

### Where can i see my messages 
messages can be seen at http://localhost:8000 in the customer topic

### Stop the demo
```
lima nerdctl compose down