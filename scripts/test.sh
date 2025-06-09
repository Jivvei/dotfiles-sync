#!/bin/bash

# Test script for dotfiles configurations
# Validates configuration files and dependencies

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TEST_COUNT++))
    echo -n "Testing $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAIL_COUNT++))
        return 1
    fi
}

echo "🧪 Dotfiles Configuration Tests"
echo "==============================="

# Test configuration file syntax
log_info "Testing configuration file syntax..."

# Test tmux configuration
if [ -f "config/tmux/.tmux.conf" ]; then
    run_test "tmux config syntax" "tmux -f config/tmux/.tmux.conf list-sessions"
else
    log_warning "tmux configuration not found"
fi

# Test fish configuration
if [ -f "config/fish/config.fish" ]; then
    run_test "fish config syntax" "fish -n config/fish/config.fish"
else
    log_warning "fish configuration not found"
fi

# Test starship configuration
if [ -f "config/starship/starship.toml" ]; then
    if command -v starship >/dev/null 2>&1; then
        run_test "starship config" "starship config config/starship/starship.toml"
    else
        log_warning "starship not installed, skipping test"
    fi
else
    log_warning "starship configuration not found"
fi

# Test required tools
log_info "Testing required tools availability..."

tools=("git" "curl" "wget" "sed")
for tool in "${tools[@]}"; do
    run_test "$tool availability" "command -v $tool"
done

# Test shell paths
log_info "Testing shell paths..."

shells=("bash" "zsh")
for shell in "${shells[@]}"; do
    run_test "$shell path detection" "command -v $shell"
done

# Test clipboard tools (platform specific)
log_info "Testing clipboard tools..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    run_test "pbcopy (macOS)" "command -v pbcopy"
    run_test "pbpaste (macOS)" "command -v pbpaste"
else
    run_test "xclip or xsel (Linux)" "command -v xclip || command -v xsel"
fi

# Test script permissions
log_info "Testing script permissions..."

for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        run_test "$(basename "$script") executable" "[ -x \"$script\" ]"
    fi
done

# Results
echo ""
echo "📊 Test Results:"
echo "================"
echo "Total tests: $TEST_COUNT"
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
    log_success "All tests passed! 🎉"
    exit 0
else
    log_error "Some tests failed. Please check the configuration."
    exit 1
fi 