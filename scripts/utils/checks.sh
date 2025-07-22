#!/bin/bash

# Check if command exists
check_command() {
    local cmd=$1
    local required=${2:-false}
    
    if command -v "$cmd" &> /dev/null; then
        log_success "$cmd is installed"
        return 0
    else
        if [ "$required" = true ]; then
            log_error "$cmd is required but not installed"
            return 1
        else
            log_warning "$cmd is not installed"
            return 1
        fi
    fi
}

# Check if port is available
check_port() {
    local port=$1
    
    if command -v lsof &> /dev/null; then
        if lsof -i:"$port" &> /dev/null; then
            log_warning "Port $port is in use"
            return 1
        else
            log_success "Port $port is available"
            return 0
        fi
    else
        log_debug "lsof not available, skipping port check for $port"
        return 0
    fi
}

# Check Docker daemon
check_docker_daemon() {
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        log_success "Docker daemon is running"
        return 0
    else
        log_error "Docker daemon is not running"
        return 1
    fi
}

# Ensure directory exists
ensure_directory() {
    local dir=$1
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_debug "Created directory: $dir"
    else
        log_debug "Directory exists: $dir"
    fi
}
