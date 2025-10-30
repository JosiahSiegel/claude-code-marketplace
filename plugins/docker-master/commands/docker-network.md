---
description: Master Docker networking including bridge, host, overlay networks, DNS, and advanced network configurations
---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**
- ❌ WRONG: `D:/repos/project/file.tsx`
- ✅ CORRECT: `D:\repos\project\file.tsx`

This applies to:
- Edit tool file_path parameter
- Write tool file_path parameter
- All file operations on Windows systems


### Documentation Guidelines

**NEVER create new documentation files unless explicitly requested by the user.**

- **Priority**: Update existing README.md files rather than creating new documentation
- **Repository cleanliness**: Keep repository root clean - only README.md unless user requests otherwise
- **Style**: Documentation should be concise, direct, and professional - avoid AI-generated tone
- **User preference**: Only create additional .md files when user specifically asks for documentation


---

# Docker Network Deep Dive

## Purpose
Master Docker networking across all network types, understand container communication patterns, implement network security, and troubleshoot connectivity issues following 2025 best practices.

## Network Drivers Overview

### Bridge (Default)

**Use case:** Single-host container communication

```bash
# Create custom bridge network
docker network create my-bridge-network

# Run container in custom network
docker run -d --name app --network my-bridge-network nginx

# Connect existing container to network
docker network connect my-bridge-network existing-container

# Disconnect from network
docker network disconnect my-bridge-network existing-container
```

**Advantages:**
- Isolated from host network
- Automatic DNS resolution between containers
- Port mapping to host
- Most common for development

**Configuration options:**
```bash
# Create bridge with custom subnet
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  my-custom-bridge

# With custom DNS
docker network create \
  --driver bridge \
  --opt com.docker.network.bridge.name=my-bridge \
  --opt com.docker.network.bridge.enable_ip_masquerade=true \
  --opt com.docker.network.bridge.enable_icc=true \
  --opt com.docker.network.driver.mtu=1500 \
  my-bridge-network
```

### Host

**Use case:** Maximum network performance, no isolation

```bash
# Run with host network
docker run -d --name app --network host nginx

# No port mapping needed - container uses host ports directly
```

**Advantages:**
- No network translation overhead
- Direct access to host network interfaces
- Best performance

**Disadvantages:**
- No network isolation
- Port conflicts with host
- Security considerations

**When to use:**
- High-performance applications
- Network monitoring tools
- Legacy applications expecting host network

### Overlay

**Use case:** Multi-host container communication (Swarm/Kubernetes)

```bash
# Initialize Swarm (required for overlay)
docker swarm init

# Create overlay network
docker network create \
  --driver overlay \
  --attachable \
  my-overlay-network

# Deploy service on overlay network
docker service create \
  --name web \
  --network my-overlay-network \
  --replicas 3 \
  nginx
```

**Advantages:**
- Multi-host container communication
- Built-in load balancing
- Encrypted communication option

**Advanced overlay configuration:**
```bash
# Overlay with encryption
docker network create \
  --driver overlay \
  --opt encrypted \
  --attachable \
  secure-overlay

# Custom subnet
docker network create \
  --driver overlay \
  --subnet=10.0.9.0/24 \
  --gateway=10.0.9.1 \
  my-overlay
```

### Macvlan

**Use case:** Container needs MAC address (appears as physical device on network)

```bash
# Create macvlan network
docker network create \
  --driver macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan-network

# Run container with macvlan
docker run -d \
  --name app \
  --network my-macvlan-network \
  --ip=192.168.1.100 \
  nginx
```

**Use cases:**
- Legacy applications expecting physical network presence
- Network monitoring/packet capture
- Applications requiring MAC address binding

**Note:** Requires promiscuous mode on host interface.

### None

**Use case:** Complete network isolation

```bash
# Run with no network
docker run -d --name isolated --network none alpine sleep infinity

# Container has only loopback interface
docker exec isolated ip addr
```

**Use cases:**
- Maximum security isolation
- Testing without network dependencies
- Containers that only process local files

## Container DNS Resolution

### Automatic DNS (Custom Bridge Networks)

```bash
# Create network
docker network create my-app-network

# Run containers
docker run -d --name db --network my-app-network postgres
docker run -d --name api --network my-app-network \
  -e DB_HOST=db \
  myapi

# 'api' container can reach 'db' by name
# Docker's embedded DNS server resolves 'db' to container IP
```

### DNS Configuration

```bash
# Custom DNS servers
docker run -d \
  --name app \
  --dns 8.8.8.8 \
  --dns 8.8.4.4 \
  nginx

# Custom DNS search domains
docker run -d \
  --name app \
  --dns-search example.com \
  --dns-search internal.example.com \
  nginx

# Add hosts entries
docker run -d \
  --name app \
  --add-host db.example.com:192.168.1.100 \
  --add-host cache.example.com:192.168.1.101 \
  nginx
```

### System-Wide DNS Configuration

```json
// /etc/docker/daemon.json
{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "dns-search": ["example.com"],
  "dns-opts": ["ndots:2", "timeout:3"]
}
```

Restart Docker daemon after changes.

## Port Publishing

### Port Mapping Patterns

```bash
# Map container port 80 to host port 8080
docker run -d -p 8080:80 nginx

# Bind to specific host interface
docker run -d -p 127.0.0.1:8080:80 nginx  # Localhost only
docker run -d -p 192.168.1.10:8080:80 nginx  # Specific IP

# Map to random host port
docker run -d -p 80 nginx
docker port CONTAINER_NAME  # View assigned port

# Map UDP port
docker run -d -p 53:53/udp dns-server

# Map multiple ports
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -p 8080:8080 \
  nginx

# Publish all exposed ports
docker run -d -P nginx  # Maps all EXPOSE ports to random high ports
```

### Security Best Practices for Port Publishing

```bash
# ✅ GOOD: Bind to localhost for local services
docker run -d -p 127.0.0.1:5432:5432 postgres

# ✅ GOOD: Use specific IP for known interfaces
docker run -d -p 192.168.1.10:80:80 nginx

# ❌ BAD: Publishing to all interfaces (0.0.0.0) when unnecessary
docker run -d -p 5432:5432 postgres  # Exposes database to network

# ✅ GOOD: Use reverse proxy for external access
docker run -d --name db -p 127.0.0.1:5432:5432 postgres
docker run -d --name proxy -p 80:80 --link db nginx
```

## Network Isolation Strategies

### Multi-Tier Architecture

```yaml
# docker-compose.yml
services:
  frontend:
    image: nginx
    networks:
      - frontend-network
    ports:
      - "80:80"

  api:
    image: myapi
    networks:
      - frontend-network
      - backend-network

  database:
    image: postgres
    networks:
      - backend-network  # Not exposed to frontend

  cache:
    image: redis
    networks:
      - backend-network

networks:
  frontend-network:
    driver: bridge
  backend-network:
    driver: bridge
    internal: true  # No external access
```

### Internal Networks (No Internet Access)

```bash
# Create internal network
docker network create \
  --internal \
  --subnet 172.25.0.0/16 \
  isolated-backend

# Containers can communicate with each other but not internet
docker run -d --name db --network isolated-backend postgres
docker run -d --name cache --network isolated-backend redis
```

### Network Policies (with Swarm)

```yaml
# Stack file for Swarm
services:
  web:
    image: nginx
    networks:
      - frontend

  api:
    image: myapi
    networks:
      - frontend
      - backend
    deploy:
      placement:
        constraints:
          - node.role == worker

  db:
    image: postgres
    networks:
      - backend
    deploy:
      placement:
        constraints:
          - node.labels.type == database

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay
    driver_opts:
      encrypted: "true"  # Encrypt traffic between nodes
```

## Advanced Networking Features

### Container Links (Legacy, Avoid)

```bash
# DEPRECATED: Use custom networks instead
docker run -d --name db postgres
docker run -d --name app --link db:database myapp

# MODERN ALTERNATIVE:
docker network create my-network
docker run -d --name db --network my-network postgres
docker run -d --name app --network my-network myapp
```

### Network Aliases

```bash
# Container reachable by multiple DNS names
docker network create my-network

docker run -d \
  --name api1 \
  --network my-network \
  --network-alias api \
  --network-alias backend \
  myapi:v1

docker run -d \
  --name api2 \
  --network my-network \
  --network-alias api \
  --network-alias backend \
  myapi:v2

# Other containers can reach both via 'api' or 'backend'
# DNS round-robin load balancing between api1 and api2
```

### Static IP Assignment

```bash
# Create network with subnet
docker network create \
  --subnet=172.18.0.0/16 \
  my-static-network

# Assign static IP
docker run -d \
  --name web \
  --network my-static-network \
  --ip 172.18.0.10 \
  nginx
```

### Multiple Networks

```bash
# Connect container to multiple networks
docker network create frontend
docker network create backend

docker run -d --name api nginx

docker network connect frontend api
docker network connect backend api

# Container has interfaces on both networks
docker inspect api --format='{{json .NetworkSettings.Networks}}'
```

## Load Balancing

### DNS Round-Robin

```bash
docker network create my-network

# Multiple containers with same alias
docker run -d --name web1 --network my-network --network-alias web nginx
docker run -d --name web2 --network my-network --network-alias web nginx
docker run -d --name web3 --network my-network --network-alias web nginx

# Requests to 'web' are round-robin across all three
```

### Swarm Service Load Balancing

```bash
# Deploy replicated service
docker service create \
  --name web \
  --replicas 3 \
  --network my-overlay \
  --publish 80:80 \
  nginx

# Docker's ingress network provides automatic load balancing
# Requests to any Swarm node:80 are load balanced across all replicas
```

## Network Troubleshooting

### Inspect Networks

```bash
# List all networks
docker network ls

# Detailed network information
docker network inspect my-network

# See which containers are connected
docker network inspect my-network --format='{{range .Containers}}{{.Name}} {{end}}'

# View container network settings
docker inspect CONTAINER --format='{{json .NetworkSettings.Networks}}'
```

### Test Connectivity

```bash
# Test connectivity between containers
docker run --rm --network my-network nicolaka/netshoot curl http://api:8080

# DNS resolution test
docker run --rm --network my-network nicolaka/netshoot nslookup api

# Port scan
docker run --rm --network my-network nicolaka/netshoot nmap -p 1-1000 api

# Trace route
docker run --rm --network my-network nicolaka/netshoot traceroute api

# Packet capture
docker run --rm --network my-network --cap-add NET_RAW nicolaka/netshoot tcpdump -i eth0
```

### Debug Container Networking

```bash
# Enter container network namespace
docker exec -it CONTAINER sh

# Inside container:
# Check interfaces
ip addr

# Check routing
ip route

# Check DNS
cat /etc/resolv.conf

# Test DNS resolution
nslookup google.com

# Test connectivity
ping -c 3 api

# Check listening ports
netstat -tulpn

# View iptables rules
iptables -L -n -v
```

### Common Issues and Solutions

**Issue: Container can't resolve service names**
```bash
# Solution: Use custom bridge network, not default bridge
docker network create my-network
docker run --network my-network --name db postgres
docker run --network my-network --name app myapp
```

**Issue: Port already in use**
```bash
# Find what's using the port
sudo lsof -i :80
# or
sudo netstat -tulpn | grep :80

# Use different host port
docker run -d -p 8080:80 nginx
```

**Issue: Can't access published port**
```bash
# Check firewall
sudo ufw status
sudo iptables -L -n | grep 8080

# Check Docker port mapping
docker port CONTAINER

# Verify container is listening
docker exec CONTAINER netstat -tulpn
```

**Issue: Containers can't reach internet**
```bash
# Check IP forwarding
sysctl net.ipv4.ip_forward

# Enable if disabled
sudo sysctl -w net.ipv4.ip_forward=1

# Check Docker daemon configuration
docker network inspect bridge | grep gateway

# Test DNS from container
docker run --rm alpine nslookup google.com
```

## Network Performance Optimization

### MTU Configuration

```bash
# Create network with custom MTU
docker network create \
  --driver bridge \
  --opt com.docker.network.driver.mtu=1400 \
  my-network
```

### Network Throughput Testing

```bash
# Start iperf server
docker run -d --name iperf-server --network my-network networkstatic/iperf3 -s

# Run iperf client
docker run --rm --network my-network networkstatic/iperf3 -c iperf-server
```

## Security Best Practices

### Network Segmentation

```yaml
# Implement zero-trust networking
services:
  frontend:
    networks: [dmz]
  api:
    networks: [dmz, internal]
  database:
    networks: [internal]
  cache:
    networks: [internal]

networks:
  dmz:
    driver: bridge
  internal:
    driver: bridge
    internal: true  # No internet access
```

### Encrypted Overlay Networks

```bash
# Create encrypted overlay for sensitive data
docker network create \
  --driver overlay \
  --opt encrypted \
  --attachable \
  secure-network

# All traffic between nodes is encrypted via IPsec
```

### Network Policies

```bash
# Limit inter-container communication
# Use external network policy tools:
# - Calico
# - Weave Net
# - Cilium

# Example with iptables
docker exec CONTAINER iptables -A INPUT -s 172.18.0.5 -j ACCEPT
docker exec CONTAINER iptables -A INPUT -j DROP
```

## Platform-Specific Networking

### Windows

- Docker Desktop uses HNS (Host Network Service)
- NAT network driver instead of bridge on Windows containers
- Use `nat` driver for Windows containers
- `host` mode not supported on Windows

```powershell
# List Windows container networks
docker network ls

# Windows containers use different network drivers
docker network create --driver nat my-windows-network
```

### macOS (Docker Desktop)

- Docker runs in Linux VM
- `host` network doesn't work as expected
- Use `host.docker.internal` to access host
- Performance considerations with bridged networking

```bash
# Access host from container on macOS
docker run --rm alpine ping host.docker.internal

# Access container from host (use published ports)
docker run -d -p 8080:80 nginx
curl http://localhost:8080
```

### Linux

- Native Docker networking
- Full support for all network drivers
- Direct access to host network with `--network host`
- SELinux/AppArmor considerations

```bash
# Use host network (Linux only)
docker run -d --network host nginx

# Container uses host's network stack directly
```

## Output

Provide:
1. Network architecture diagram (describe topology)
2. Network creation commands with justification
3. Container connectivity configuration
4. DNS resolution setup
5. Port publishing strategy with security considerations
6. Troubleshooting commands for connectivity issues
7. Performance optimization recommendations
8. Platform-specific configuration adjustments
