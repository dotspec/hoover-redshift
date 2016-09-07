# Vacuums Redshift ETL Tables to increase performance.
# Author: Darren Gordon <darren@spec907.net> 12-2-2015

require 'aws-sdk'
require 'json'
require 'pg'
require 'rubygems'

# Function to execute vacuum on table.
def vacuum_table(conn,table)
  conn.exec("vacuum full #{table}")
end

# Function to generate timestamps in specified format and return
# formatted value.
def create_timestamp()
    t = Time.now.strftime("%Y-%m-%d-%Y-%H-%M")
    return t
end

# Variables for PG + Redshift connections.
db_endpoint = "AMAZON_URL.redshift.amazonaws.com"
db_name = "TABLE_NAME"
db_user = "USER_NAME"
db_pwd  = "DB_PASS"

# Create Postgres connection
conn = PG::Connection.new("#{db_endpoint}",
                          '5439',
                          '',
                          '',
                          "#{db_name}",
                          "#{db_user}",
                          "#{db_pwd}"
                          )

# Needs to take a snapshot, redshift cluster
resp = redshift.create_cluster_snapshot({
  snapshot_identifier: "#{db_name}" + "-" + create_timestamp(),
  cluster_identifier: "#{db_name}",
})

# Once our connection is open, exec the following and give us the error if one occurs
# What needs to be vacuumed
results = conn.exec("SELECT schema,\"table\",unsorted FROM SVV_TABLE_INFO where unsorted > 90")

results.each do |row|
  table = row['schema'] + '.' + row['table']
  vacuum_table(conn,table)
end
