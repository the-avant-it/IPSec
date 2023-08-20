# Common.IpSec

Role for installing strongswan based ipsec
Needs access to 2 host in order to work (client and server)

# Known issues

- On VK Cloud you have to make additional configurations!
- On AWS you habe to disable source/dest check on ipsec's network interface (it's already disabled if you are using our modules =)
- Sometimes you have to manually run `ipsec restart` on the server and `ipsec restart` followed by `ipsec up` on the client in order for changes to take effect

# Possible errors

E1:

received TS_UNACCEPTABLE notify, no CHILD_SA built
failed to establish CHILD_SA, keeping IKE_SA

S1: 

You are likely misplaced right and left sides

# Changelog

## 3.0.4

- Always run up clients

## 3.0.3

- Fix

## 3.0.2

- Add ipsec restart and up

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

# Documentation for 3.0.3

## Requirements

## Hosts

```yaml
ipsec:
  hosts:
    ipsec-client:
      ansible_ssh_private_key_file: ./ssh/dev-ipsec-eu-central-1a-ssh.pem
      ansible_user: ubuntu
      ansible_host: dev-ipsec-pub.hostname
    ipsec-server:
      ansible_ssh_private_key_file: ./ssh/dev-gcp-ipsec-us-central1-a-ssh.pem
      ansible_user: ubuntu
      ansible_host: dev-gcp-ipsec-pub.hostname
  vars:
    hide_secrtets_from_log: yes 
```  

## Variables

### Non-secret

```yaml
ipsec:  
  # Client side configuration (aws is the client in this example)
  client:
    # You may have any other number of clients and their names
    aws:
      # Left means subnets the CLIENT is located in
      leftsubnet: 172.18.60.0/23,172.18.62.0/23,172.18.64.0/23,172.18.66.0/23,172.18.68.0/23,172.18.70.0/23
      # Right means subnets the SERVER is located in
      rightsubnet: 172.22.84.0/23,172.22.86.0/23,172.22.88.0/23,172.22.90.0/23,172.22.92.0/23,172.22.94.0/23
      right: dev-gcp-ipsec-pub.hostname

  # Server side configuration (google is the server in this example)
  server:
    gcp:
      # Left means subnets the SERVER is located in (see, server configuration is opposite to the client's one!)
      leftsubnet: 172.22.84.0/23,172.22.86.0/23,172.22.88.0/23,172.22.90.0/23,172.22.92.0/23,172.22.94.0/23
      # Right means subnets the CLIENT is located in (see, server configuration is opposite to the client's one!)
      rightsubnet: 172.18.60.0/23,172.18.62.0/23,172.18.64.0/23,172.18.66.0/23,172.18.68.0/23,172.18.70.0/23
```  

### Secret

```yaml
ipsec:
  psk_secret_key: SEE_SS
```
