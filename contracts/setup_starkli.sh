#!/bin/bash
# Setup script to ensure starkli is available in PATH

# Add starkli to PATH
export PATH="$HOME/.starkli/bin:$PATH"

# Source starkli environment if it exists
if [ -f "$HOME/.starkli/env" ]; then
    source "$HOME/.starkli/env"
fi

# Check if starkli is available
if command -v starkli &> /dev/null; then
    echo "✅ Starkli is available: $(starkli --version)"
    return 0 2>/dev/null || exit 0
else
    echo "⚠️  Starkli not found in PATH"
    echo "Installing starkli..."
    
    # Install starkli if starkliup exists
    if [ -f "$HOME/.starkli/bin/starkliup" ]; then
        "$HOME/.starkli/bin/starkliup"
        export PATH="$HOME/.starkli/bin:$PATH"
    else
        echo "❌ Could not find starkliup. Please install starkli manually."
        return 1 2>/dev/null || exit 1
    fi
fi

