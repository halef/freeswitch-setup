# Freeswitch server setup for use with SDS

## Disclaimer
 - I only use this setup for local development. Use it at your own risk!
 - I do not recommend to run freeswitch as root on a publicly exposed 
   server. 
 - Check the TODO.md before running this as something other than a pure
   development system.

## Running locally
Setup Ubuntu 16.04 LTS Server inside a VM locally. If you are
using Virtualbox, make sure to choose Bridged Network adapter in the
settings. In other tools, choose an equivalent networking option.

## Installation
Copy or clone this repository onto the machine and run:
```bash
sudo bash install.sh
```

# Configuring
Delete the default configuration files and copy in the files under
the `config/` directory. If freeswitch was already running, connect
to the fs\_cli and run reloadxml. This is also necessary after changes
to user accounts, dialplans and other xml files.

Or run:
```bash
sudo bash update_conf.sh --aws
```

## PASSWORDS
Passwords are overwritten PASSWORDS.xml. Make sure to add it into the
configuration directory. Furthermore, make sure to not share it with
unauthorized users. Therefore, *DONT* add it to a public git repo.

Example:
```xml
<include>
	<X-PRE-PROCESS cmd="set" data="default_password=1234"/>
</include>
```

## Starting freeswitch
You can start freeswitch directly from your install directory.
```bash
cd /opt/freeswitch/bin
sudo ./freeswitch -ncwait
sudo ./fs_cli
```

