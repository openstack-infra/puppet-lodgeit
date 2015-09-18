require 'spec_helper_acceptance'

describe cron, :if => ['debian', 'ubuntu'].include?(os[:family]) do
  it { should have_entry('0 0 * * * /usr/bin/mysqldump --defaults-file=/root/.acceptance_db.cnf --opt --ignore-table mysql.event --all-databases | gzip -9 > /var/backups/mysql_backups/acceptance.sql.gz').with_user('root') }
end
