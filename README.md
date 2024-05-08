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

E2:

When uou try to ping some resource in target network you get folowwing output:
ping 10.8.0.29
PING 10.8.0.29 (10.8.0.29): 56 data bytes
92 bytes from 10.8.0.1: Redirect Host
92 bytes from 10.8.0.1: Redirect Host
92 bytes from 10.8.0.1: Redirect Host

S2:

It's likely problem with you VPN because it allocates subnet in 10.8 range for clients. Try to ping from vm in internal subnet and if the problem will not persist in that case, check your vpn (`route -4` command may help)

# Debug advices

1) Run `ping` to the resource you want to reach through tunnel (it sould be on the side where ipsec server is located)
2) Run `tcpdump icmp` in ipsec client

2.1) If you see:
08:45:16.491925 IP prod-openvpn.ru-central1.internal > 172.31.101.65: ICMP echo request, id 49827, seq 1, length 64
08:45:16.543008 IP 172.31.101.65 > prod-ipsec.ru-central1.internal: ICMP echo reply, id 49827, seq 1, length 64
08:45:16.543075 IP 172.31.101.65 > prod-openvpn.ru-central1.internal: ICMP echo reply, id 49827, seq 1, length 64  
That means everything is ok (ipsec client got packed, received response from destination, routed it back to the sender)

2.2) If you see:
08:45:31.186315 IP prod-openvpn.ru-central1.internal > 172.22.100.53: ICMP echo request, id 50134, seq 1, length 64
08:45:31.186366 IP prod-ipsec.ru-central1.internal > 172.22.100.53: ICMP echo request, id 50134, seq 1, length 64
08:45:31.186496 IP prod-ipsec.ru-central1.internal > 172.22.100.53: ICMP echo request, id 50134, seq 1, length 64
Means that ipsec server didn't give route (ipsec client got packed, sent it further (not to the next ipsec), received it back since you configured routing table to route this ip to ipsec)

2.3) If you see:
09:53:06.966674 IP prod-openvpn.ru-central1.internal > 172.22.100.53: ICMP echo request, id 31214, seq 54, length 64
Means that ipsec server didnt respond

2.4) If you see nothing => you did not configured routes on the client side

3) Run tcpdump icmp in ipsec server

3.1) If you see:
10:06:53.971559 IP ip-172-18-0-100.eu-central-1.compute.internal > ip-172-22-100-53.eu-central-1.compute.internal: ICMP echo request, id 3, seq 18, length 64
10:06:53.971622 IP ip-172-22-99-79.eu-central-1.compute.internal > ip-172-22-100-53.eu-central-1.compute.internal: ICMP echo request, id 3, seq 18, length 64
10:06:53.971964 IP ip-172-22-100-53.eu-central-1.compute.internal > ip-172-22-99-79.eu-central-1.compute.internal: ICMP echo reply, id 3, seq 18, length 64
Everything is ok (ipsec server got packet, retransmitted it from itself, received response from destination)

3.2) If you see:
10:07:51.697601 IP ip-172-20-0-100.eu-central-1.compute.internal > ip-172-22-100-53.eu-central-1.compute.internal: ICMP echo request, id 41466, seq 1, length 64
Server received your packet, but it did not recognize it as packet to be routed and ignored it (likely because 172-22-100-53 and 172-20-0-100 do not belong to configured subnets)

# Changelog

## 3.1.4

- Add configurable cleaning up POSTROUTING table by variable  clean_postrouting
- Add configurable enabling MASQUERADE for docker. Set CIDRs for MASQUERADING
- Add parametrization all variables in ipsec-client.conf and ipsec-server.conf

## 3.1.3

- Add support for ubuntu 22.04 and debian 11

## 3.0.5

- Add net.ipv6.conf.all.forwarding and net.ipv6.conf.all.accept_redirects to sysctl_config

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
      # Optionals.
      keyexchange=ikev2
      type=tunnel
      authby=secret
      rekey=yes
      keyingtries=3
      left=%any
      right=%any
      auto=route
      fragmentation=yes
      reauth=no
      dpdaction=clear
      esp=aes256-sha256-modp2048

  # Server side configuration (google is the server in this example)
  server:
    gcp:
      # Left means subnets the SERVER is located in (see, server configuration is opposite to the client's one!)
      leftsubnet: 172.22.84.0/23,172.22.86.0/23,172.22.88.0/23,172.22.90.0/23,172.22.92.0/23,172.22.94.0/23
      # Right means subnets the CLIENT is located in (see, server configuration is opposite to the client's one!)
      rightsubnet: 172.18.60.0/23,172.18.62.0/23,172.18.64.0/23,172.18.66.0/23,172.18.68.0/23,172.18.70.0/23
      # Optionals.
      keyexchange=ikev2
      type=tunnel
      authby=secret
      rekey=yes
      keyingtries=3
      left=%any
      right=%any
      auto=add
      fragmentation=yes
      reauth=no
      dpdaction=clear
      esp=aes256-sha256-modp2048
```  

### Secret

```yaml
ipsec:
  psk_secret_key: SEE_SS
```
