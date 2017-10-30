# Сentos Vagrant VM

Vagrant VM based on [CentOS 7.4](https://app.vagrantup.com/centos/boxes/7/versions/1708.01)

### Features

* Nginx, PHP 7.0.\*, MariaDB 10.1.\*
* Presetting Nginx and PHP-FPM site configs
* Disable SELinux.

## Prerequisites

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads), as provider for Vagrant
    * [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plug-in to keep VirtualBox tools up-to-date.
    * [vagrant-hostmanager
](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin that manages the hosts file on guest machines.

### Instruction
1. Create a **vagrant/config/vagrant-local.yml** and configure it
2. Install a plugins for Vagrant, if you don't have it.
    ```bash
    $ vagrant plugin install vagrant-hostmanager
    $ vagrant plugin install vagrant-vbguest
    ```
3. Boot-up a Vagrant VM.
   ```bash
   vagrant up
   ```
   > Don't be scary, if you have a trouble with connect via ssh, wait about 2 mins. It happens because in the first run box doesn't have VirtualBox Guest Additions
   
4. If you don't want check version for VirtualBox Guest Additions every next run uncomment this line in **VagrantFile**
   > **Reminder** In the first boot-up you need to install VirtualBox Guest Additions
      ```bash
      32 line: #config.vbguest.auto_update = false
      ```