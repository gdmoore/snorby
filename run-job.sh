#!/bin/sh

# Starts the background worker
# Add to cron as
# @reboot   /.../run-job.sh

# Force a specific version of Ruby -- Snorby only works with Ruby 1.9
RUBY=/usr/local/ruby19/bin/ruby

# Force production environment
RAILS_ENV=production
export RAILS_ENV

# Run
cd /usr/local/snorby/
$RUBY script/delayed_job start 
