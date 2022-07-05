# In production you would almost certainly limit the replication user must be on the follower (slave) machine,
# to prevent other clients accessing the log from other machines. For example, 'replicator'@'follower.acme.com'.
#
# However, this grant is equivalent to specifying *any* hosts, which makes this easier since the docker host
# is not easily known to the Docker container. But don't do this in production.
#
# CREATE USER 'replicator' IDENTIFIED BY 'replpass';
# CREATE USER 'debezium' IDENTIFIED BY 'dbz';
# GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replicator';
# GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'debezium';

# Create the database that we'll use to populate data and watch the effect in the binlog
# CREATE DATABASE inventory;
# GRANT ALL PRIVILEGES ON inventory.* TO 'mysqluser'@'%';

# Switch to this database
# USE inventory;

DROP USER mysqluser;
