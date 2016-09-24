# Vacuums Redshift ETL Tables to increase performance.
# Author: Darren Gordon <darren@spec907.net> 12-2-2015
# Updated by: Courtney Cotton <cotton@cottoncourtney.com> 12-5-2015

require 'aws-sdk'
require 'dogapi'
require 'json'
require 'pg'
require 'rubygems'

# API Connections
api_key='YERAPIKEYHERE'
app_key='YERAPIKEYHERE'

# Variables for PG + Redshift connections.
db_endpoint = "AMAZON_URL.redshift.amazonaws.com"
db_name = "TABLE_NAME"
db_user = "USER_NAME"
db_pwd  = "DB_PASS"
threshold = "75"

dog = Dogapi::Client.new(api_key, app_key)
redshift = Aws::Redshift::Client.new(region: 'us-west-2')

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
begin
  results = conn.exec("SELECT schema,\"table\",unsorted FROM SVV_TABLE_INFO where unsorted > #{threshold}")
  if results.values.empty?
    title = "Redshift Cluster: #{db_name} has 0 tables to update."
    text  = "The Redshift Cluster: #{db_name} is properly sorted. No action was needed."
    tags  = ["#{db_name}", "#{db_endpoint}"]
    dog.emit_event(Dogapi::Event.new(text, :msg_title => title, :priority => 'low', :tags => tags))
    abort
  end
  rescue PG::Error => err
    puts err
end

results.each do |row|
  table = row['schema'] + '.' + row['table']
  vacuum_table(conn,table)
end

title = "Redshift Cluster: #{db_name} sorted tables."
text  = "The Redshift Cluster: #{db_name} underwent sorting."
tags  = ["#{db_name}", "#{db_endpoint}"]
dog.emit_event(Dogapi::Event.new(text, :msg_title => title, :priority => 'normal', :tags => tags))
