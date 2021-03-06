name             'soupstraw'
maintainer       'Soupstraw, Inc.'
maintainer_email 'someone@soupstraw.com'
license          'All rights reserved'
description      'Installs/Configures soupstraw'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          '0.2.50'
depends          'motd'
depends          'rbenv'
depends          'postgresql'
depends          'unicorn-ng'
depends          'git'
depends          'users'
depends          'route53'
depends          'nginx'
depends          'datadog'
depends          'logrotate'
depends          'newrelic'
