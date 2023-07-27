# Common.IpSec

Role for installing strongswan based ipsec
Needs access to 2 host in order to work (client and server)

# Changelog

## 2.0.2

- ????

## 2.0.0

- Stable

# Documentation for 2.0.8

## Requirements

## Hosts

```yaml
ipsec:
    hosts:
        ipsec-server:
            ansible_ssh_private_key_file: ./ssh/prod-ipsec-G43b8hsq.pem
            ansible_user: ubuntu
            ansible_host: ipsec-server-vk.hostname
        ipsec-client:
            ansible_ssh_private_key_file: ./ssh/prod-ipsec-ru-central1-a-ssh.secret.pem
            ansible_user: ubuntu
            ansible_host: ipsec-pub.hostname
    vars:
        hide_secrtets_from_log: yes 
```  

## Variables

### Non-secret

```yaml
ipsec:  
  # Client side configuration
  client:
    # You may have any other number of clients and their names
    vk:
      leftsubnet: 172.20.0.0/16
      rightsubnet: 10.103.1.0/24,10.103.2.0/24,10.103.3.0/24,10.103.4.0/24
      # ipsec server
      right: ipsec-server-vk.hostname 
    office:
      leftsubnet: 172.20.0.0/16,172.18.0.0/16
      rightsubnet: 10.255.0.0/16
      # ipsec server
      right: 95.214.119.30 
    ldap:
      leftsubnet: 172.20.0.0/16,172.18.0.0/16
      rightsubnet: 10.0.1.0/24,10.101.0.10/32
      # ipsec server
      right: 109.120.183.119 
  # Server side configuration
  server:
    vk:
      leftsubnet: 10.103.1.0/24,10.103.2.0/24,10.103.3.0/24,10.103.4.0/24
      rightsubnet: 172.20.0.0/16
```  

### Secret

```yaml
ipsec:
  client:
    # You may have any other number of clients and their names
    vk:
      psk_secret_key: SEESMARTSHELL
    office:
      psk_secret_key: SEESMARTSHELL
    ldap:
      psk_secret_key: SEESMARTSHELL 
```
