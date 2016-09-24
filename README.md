# Hoover

"A Hoovered table is as clean as it looks"

---
# Why would I need this?

Redshift doesn't reclaim space after deleting or or updating rows so over time the table becomes more and more unsorted, effecting cluster performance.  Plug in a Hoover and watch as it cleans deep down, getting your tables looking their best.

# Requirements Before Starting

If you haven't it's probably smart to [get familiar](http://docs.aws.amazon.com/redshift/latest/dg/t_Reclaiming_storage_space202.html) with Amazon's documentation to find out if vacuuming is right for you.

In order to vacuum a Redshift table the user performing the command has to either be the table owner or a superuser so take that into account when setting up the script.  

# Setup

The only configuration required is to substitute the Redshift connection information in the top of the script.

```
db_endpoint = "AMAZON_URL.redshift.amazonaws.com"
db_name = "TABLE_NAME"
db_user = "USER_NAME"
db_pwd  = "DB_PASS"
threshold = "75"
```

By default Hoover will vacuum any table that has > 75% unsorted rows.  You can raise or lower this by changing the threshold variable to suit your needs.
