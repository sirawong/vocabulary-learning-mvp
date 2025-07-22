# scripts/utils/file-helpers.sh - File manipulation helpers
#!/bin/bash

# Create file with content
create_file() {
    local file_path=$1
    local content=$2
    local overwrite=${3:-false}
    
    # Ensure directory exists
    local dir=$(dirname "$file_path")
    ensure_directory "$dir"
    
    # Check if file exists
    if [ -f "$file_path" ] && [ "$overwrite" != true ]; then
        log_warning "File already exists, skipping: $file_path"
        return 0
    fi
    
    # Create file
    echo "$content" > "$file_path"
    log_debug "Created file: $file_path"
}

# Copy file if source exists
copy_file_if_exists() {
    local source=$1
    local destination=$2
    local overwrite=${3:-false}
    
    if [ ! -f "$source" ]; then
        log_warning "Source file not found: $source"
        return 1
    fi
    
    if [ -f "$destination" ] && [ "$overwrite" != true ]; then
        log_warning "Destination exists, skipping: $destination"
        return 0
    fi
    
    cp "$source" "$destination"
    log_debug "Copied: $source -> $destination"
}

# Replace placeholder in file
replace_placeholder() {
    local file=$1
    local placeholder=$2
    local replacement=$3
    
    if [ ! -f "$file" ]; then
        log_error "File not found for placeholder replacement: $file"
        return 1
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/${placeholder}/${replacement}/g" "$file"
    else
        # Linux
        sed -i "s/${placeholder}/${replacement}/g" "$file"
    fi
    
    log_debug "Replaced placeholder in $file: $placeholder -> $replacement"
}

# Make file executable
make_executable() {
    local file=$1
    
    if [ -f "$file" ]; then
        chmod +x "$file"
        log_debug "Made executable: $file"
    else
        log_warning "Cannot make executable, file not found: $file"
        return 1
    fi
}
