# To enhance the script with checks for Redis and Memcached operational issues, here are seven additional checks addressing common problems
# High Memory Usage
# Eviction Issues
# Latency/Slow Operations
# Connection Limits
# Replication Issues (Redis)
# Key Expiry Monitoring
# Service Port Availability

## please check detail instructions for usage


#!/bin/bash

# Function to monitor memory usage
check_memory_usage() {
    echo "Checking memory usage for Redis and Memcached..."
    if systemctl is-active redis-server &>/dev/null; then
        used_memory=$(redis-cli INFO memory | grep "used_memory_human" | awk -F: '{print $2}')
        echo "Redis memory usage: ${used_memory:-Not available}"
    else
        echo "Redis is not running"
    fi

    if systemctl is-active memcached &>/dev/null; then
        used_memory=$(echo stats | nc localhost 11211 | grep "bytes " | awk '{print $3}')
        echo "Memcached memory usage: ${used_memory:-Not available} bytes"
    else
        echo "Memcached is not running"
    fi
}

# Function to monitor eviction policies
check_evictions() {
    echo "Checking eviction policies for Redis and Memcached..."
    if systemctl is-active redis-server &>/dev/null; then
        evictions=$(redis-cli INFO stats | grep "evicted_keys" | awk -F: '{print $2}')
        echo "Redis evicted keys: ${evictions:-Not available}"
    else
        echo "Redis is not running"
    fi

    if systemctl is-active memcached &>/dev/null; then
        evictions=$(echo stats | nc localhost 11211 | grep "evictions " | awk '{print $3}')
        echo "Memcached evicted keys: ${evictions:-Not available}"
    else
        echo "Memcached is not running"
    fi
}

# Function to monitor latency
check_latency() {
    echo "Checking latency for Redis..."
    if systemctl is-active redis-server &>/dev/null; then
        latency=$(redis-cli --latency | awk 'NR==2 {print $2}')
        echo "Redis average latency: ${latency:-Not available} ms"
    else
        echo "Redis is not running"
    fi
}

# Function to check client connections
check_connections() {
    echo "Checking client connections for Redis and Memcached..."
    if systemctl is-active redis-server &>/dev/null; then
        connections=$(redis-cli INFO clients | grep "connected_clients" | awk -F: '{print $2}')
        echo "Redis connected clients: ${connections:-Not available}"
    else
        echo "Redis is not running"
    fi

    if systemctl is-active memcached &>/dev/null; then
        connections=$(echo stats | nc localhost 11211 | grep "curr_connections" | awk '{print $3}')
        echo "Memcached connected clients: ${connections:-Not available}"
    else
        echo "Memcached is not running"
    fi
}

# Function to check Redis replication status
check_replication() {
    echo "Checking Redis replication status..."
    if systemctl is-active redis-server &>/dev/null; then
        role=$(redis-cli INFO replication | grep "role" | awk -F: '{print $2}')
        echo "Redis role: ${role:-Not available}"
    else
        echo "Redis is not running"
    fi
}

# Function to monitor expired keys
check_expired_keys() {
    echo "Monitoring expired keys for Redis..."
    if systemctl is-active redis-server &>/dev/null; then
        expired_keys=$(redis-cli INFO stats | grep "expired_keys" | awk -F: '{print $2}')
        echo "Redis expired keys: ${expired_keys:-Not available}"
    else
        echo "Redis is not running"
    fi
}

# Function to check service port availability
check_service_ports() {
    echo "Checking service ports for Redis and Memcached..."
    redis_port=$(ss -tunlp | grep redis | awk '{print $5}' | grep -o '[0-9]*$')
    memcached_port=$(ss -tunlp | grep memcached | awk '{print $5}' | grep -o '[0-9]*$')
    echo "Redis service port: ${redis_port:-Not available}"
    echo "Memcached service port: ${memcached_port:-Not available}"
}

# Main script execution
echo "Redis and Memcached Monitoring Script"
echo "-------------------------------------"

while true; do
    echo
    check_memory_usage
    check_evictions
    check_latency
    check_connections
    check_replication
    check_expired_keys
    check_service_ports
    echo
    echo "Press [Ctrl+C] to stop monitoring..."
    sleep 10
done
