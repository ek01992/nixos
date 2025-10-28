#!/bin/bash
# Comprehensive networking verification script for NixOS
# Tests all networking layers: interfaces, routing, DNS, firewall, services
# Exit codes: 0 = pass, 1 = fail

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track overall status
OVERALL_STATUS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    OVERALL_STATUS=1
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# System Information
print_header "System Information"

if [ -f /etc/nixos/flake.nix ]; then
    HOSTNAME=$(hostname)
    KERNEL=$(uname -r)
    NIXOS_VERSION=$(nixos-version)

    print_success "Hostname: $HOSTNAME"
    print_success "Kernel: $KERNEL"
    print_success "NixOS: $NIXOS_VERSION"
else
    print_warning "Not running on NixOS or flake.nix not found"
fi

# Base Networking Configuration
print_header "Base Networking Configuration"

# Check systemd-networkd
if systemctl is-active --quiet systemd-networkd; then
    print_success "systemd-networkd is active"
else
    print_error "systemd-networkd is not active"
fi

# Check IPv6 privacy settings
if [ -f /proc/sys/net/ipv6/conf/all/use_tempaddr ]; then
    TEMPADDR=$(cat /proc/sys/net/ipv6/conf/all/use_tempaddr)
    if [ "$TEMPADDR" = "0" ]; then
        print_success "IPv6 privacy extensions disabled (expected)"
    else
        print_warning "IPv6 privacy extensions enabled (may cause issues with containers)"
    fi
fi

# Check nftables
if systemctl is-active --quiet nftables; then
    print_success "nftables firewall is active"
else
    print_warning "nftables firewall is not active"
fi

# Interface Details
print_header "Interface Details"

# List all interfaces
INTERFACES=$(ip link show | grep -E "^[0-9]+:" | awk -F': ' '{print $2}' | awk -F'@' '{print $1}')
for iface in $INTERFACES; do
    if [ "$iface" = "lo" ]; then
        continue
    fi

    STATE=$(ip link show "$iface" | grep -o "state [A-Z]*" | awk '{print $2}')
    MAC=$(ip link show "$iface" | grep -o "link/ether [a-f0-9:]*" | awk '{print $2}')

    if [ -n "$MAC" ]; then
        print_success "$iface: $STATE, MAC: $MAC"
    else
        print_success "$iface: $STATE"
    fi

    # Check for IP addresses
    IPS=$(ip addr show "$iface" | grep -o "inet [0-9.]*/[0-9]*" | awk '{print $2}' || true)
    if [ -n "$IPS" ]; then
        for ip in $IPS; do
            print_success "  IPv4: $ip"
        done
    fi

    IPS6=$(ip addr show "$iface" | grep -o "inet6 [a-f0-9:]*/[0-9]*" | awk '{print $2}' || true)
    if [ -n "$IPS6" ]; then
        for ip in $IPS6; do
            print_success "  IPv6: $ip"
        done
    fi

    # Check bridge membership
    if [ -d "/sys/class/net/$iface/brport" ]; then
        BRIDGE=$(basename "$(readlink "/sys/class/net/$iface/brport/bridge" 2>/dev/null)" 2>/dev/null || echo "unknown")
        print_success "  Bridge member: $BRIDGE"
    fi
done

# Bridge Networking (Incus-specific)
print_header "Bridge Networking"

# Check for Incus bridges
if check_command incus; then
    if systemctl is-active --quiet incus; then
        print_success "Incus is active"

        # List Incus networks
        INCUS_NETWORKS=$(incus network list --format csv | tail -n +2 | cut -d',' -f1 || true)
        if [ -n "$INCUS_NETWORKS" ]; then
            for net in $INCUS_NETWORKS; do
                print_success "Incus network: $net"
            done
        else
            print_warning "No Incus networks found"
        fi
    else
        print_warning "Incus is installed but not active"
    fi
else
    print_warning "Incus not installed"
fi

# Check for bridge interfaces
BRIDGES=$(ip link show type bridge | grep -E "^[0-9]+:" | awk -F': ' '{print $2}' | awk -F'@' '{print $1}' || true)
if [ -n "$BRIDGES" ]; then
    for bridge in $BRIDGES; do
        STATE=$(ip link show "$bridge" | grep -o "state [A-Z]*" | awk '{print $2}')
        print_success "Bridge $bridge: $STATE"

        # Check bridge members
        MEMBERS=$(bridge link show | grep "$bridge" | awk '{print $2}' || true)
        if [ -n "$MEMBERS" ]; then
            for member in $MEMBERS; do
                print_success "  Member: $member"
            done
        fi
    done
else
    print_warning "No bridge interfaces found"
fi

# Routing
print_header "Routing"

# Default gateway
DEFAULT_GW=$(ip route | grep default | head -1 | awk '{print $3}' || true)
if [ -n "$DEFAULT_GW" ]; then
    print_success "Default gateway: $DEFAULT_GW"

    # Test gateway reachability
    if ping -c 1 -W 2 "$DEFAULT_GW" >/dev/null 2>&1; then
        print_success "Gateway reachable"
    else
        print_error "Gateway not reachable"
    fi
else
    print_error "No default gateway found"
fi

# Check routing table
ROUTES=$(ip route | wc -l)
print_success "Routing table entries: $ROUTES"

# DNS Resolution
print_header "DNS Resolution"

# Check nameservers
if [ -f /etc/resolv.conf ]; then
    NAMESERVERS=$(grep "^nameserver" /etc/resolv.conf | awk '{print $2}' || true)
    if [ -n "$NAMESERVERS" ]; then
        for ns in $NAMESERVERS; do
            print_success "Nameserver: $ns"
        done
    else
        print_warning "No nameservers configured"
    fi
fi

# Test DNS resolution
if nslookup google.com >/dev/null 2>&1; then
    print_success "DNS resolution working"
else
    print_error "DNS resolution failed"
fi

# Firewall Rules
print_header "Firewall Rules"

if systemctl is-active --quiet nftables; then
    # Check nftables rules
    NFT_RULES=$(nft list ruleset | wc -l)
    print_success "nftables rules: $NFT_RULES"

    # Check for trusted interfaces
    TRUSTED_IFS=$(nft list ruleset | grep -o "iifname.*accept" | awk '{print $2}' | tr -d '"' || true)
    if [ -n "$TRUSTED_IFS" ]; then
        for iface in $TRUSTED_IFS; do
            print_success "Trusted interface: $iface"
        done
    else
        print_warning "No trusted interfaces found in firewall"
    fi

    # Check allowed ports
    ALLOWED_PORTS=$(nft list ruleset | grep -o "tcp dport.*accept" | awk '{print $3}' || true)
    if [ -n "$ALLOWED_PORTS" ]; then
        for port in $ALLOWED_PORTS; do
            print_success "Allowed port: $port"
        done
    else
        print_warning "No allowed ports found in firewall"
    fi
else
    print_warning "nftables not active - cannot check firewall rules"
fi

# Tailscale Status (Optional)
print_header "Tailscale Status"

if check_command tailscale; then
    if systemctl is-active --quiet tailscaled; then
        print_success "Tailscale daemon is active"

        # Check Tailscale status
        if tailscale status >/dev/null 2>&1; then
            TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
            print_success "Tailscale IP: $TAILSCALE_IP"

            # Check if connected
            if tailscale status | grep -q "Logged in"; then
                print_success "Tailscale connected"
            else
                print_warning "Tailscale not connected"
            fi
        else
            print_warning "Tailscale status check failed"
        fi
    else
        print_warning "Tailscale daemon not active"
    fi
else
    print_warning "Tailscale not installed"
fi

# External Connectivity
print_header "External Connectivity"

# Test internet connectivity
if ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
    print_success "Internet connectivity (8.8.8.8)"
else
    print_error "No internet connectivity"
fi

# Test HTTPS connectivity
if curl -s --connect-timeout 5 https://google.com >/dev/null 2>&1; then
    print_success "HTTPS connectivity working"
else
    print_error "HTTPS connectivity failed"
fi

# Configuration Validation
print_header "Configuration Validation"

# Check if we're in a NixOS flake
if [ -f /etc/nixos/flake.nix ]; then
    # Try to validate the flake
    if nix flake check --no-build >/dev/null 2>&1; then
        print_success "Flake configuration valid"
    else
        print_error "Flake configuration has errors"
    fi

    # Check if we can dry-build
    if nixos-rebuild dry-build --flake /etc/nixos >/dev/null 2>&1; then
        print_success "System configuration builds successfully"
    else
        print_error "System configuration build failed"
    fi
else
    print_warning "Not in a NixOS flake environment"
fi

# Summary
print_header "Summary"

if [ $OVERALL_STATUS -eq 0 ]; then
    print_success "All networking checks passed"
    exit 0
else
    print_error "Some networking checks failed"
    exit 1
fi
