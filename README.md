# Common.IpSec

Role for installing strongswan based ipsec
Needs access to 2 host in order to work (client and server)

# Changelog

## 3.0.1

- Fix critical bug

## 3.0.0

- BREAKING CHANGE: Move sysctl_config in upsec block
- BREAKING CHANGE: Move psk_secret_key from clients block to ipsec block + remove vk hardcode

## 2.1.0

- Add MASQUERADE configuration

## 2.0.2

- ????

## 2.0.0

- Stable

# Documentation for 3.0.1

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
      # Left means subnet the client connects to
      leftsubnet: 172.20.0.0/16
      # Right means subnets the server located in
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
    yandex:
      # Left means subnet the clients reside in
      leftsubnet: 10.103.1.0/24,10.103.2.0/24,10.103.3.0/24,10.103.4.0/24
      # Right means subnets the server located in
      rightsubnet: 172.20.0.0/16
```  

### Secret

```yaml
ipsec:
  psk_secret_key: SEE_SS
```
