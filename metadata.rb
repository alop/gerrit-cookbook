maintainer        "Abel Lopez"
maintainer_email  "al592b@att.com"
description       "Installs gerrit"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"

%w{ ubuntu debian }.each do |os|
  supports os
end

depends "java"
depends "mysql"
