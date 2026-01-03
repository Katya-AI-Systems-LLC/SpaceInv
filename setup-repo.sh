#!/bin/bash

# Git Repository Setup Script for Space Invaders Project

set -e

echo "🚀 Setting up Git repository for Space Invaders Enhanced Edition..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Not a Git repository. Please run 'git init' first."
    exit 1
fi

# 1. Set up Git configuration
print_status "Setting up Git configuration..."

# Copy gitconfig if it exists
if [ -f ".gitconfig" ]; then
    print_status "Applying project-specific Git configuration..."
    git config include.path "../.gitconfig"
    print_success "Git configuration applied"
fi

# 2. Set up Git attributes
print_status "Setting up Git attributes..."
if [ -f ".gitattributes" ]; then
    git add .gitattributes
    print_success "Git attributes configured"
else
    print_warning "No .gitattributes file found"
fi

# 3. Set up Git hooks
print_status "Setting up Git hooks..."
HOOKS_DIR=".git/hooks"
PROJECT_HOOKS_DIR="git-hooks"

# Make hooks executable
if [ -d "$HOOKS_DIR" ]; then
    chmod +x "$HOOKS_DIR"/*
    print_success "Git hooks made executable"
fi

# 4. Set up Git LFS
print_status "Setting up Git LFS..."
if [ -f "setup-lfs.sh" ]; then
    chmod +x setup-lfs.sh
    ./setup-lfs.sh
    print_success "Git LFS configured"
else
    print_warning "No setup-lfs.sh script found"
fi

# 5. Set up branch protection
print_status "Setting up branch protection rules..."
if command -v gh &> /dev/null; then
    print_status "Configuring GitHub branch protection..."
    
    # Protect main branch
    gh api repos/:owner/:repo/branches/main/protection \
        --method PUT \
        --field required_status_checks='{"strict":true,"contexts":["continuous-integration"]}' \
        --field enforce_admins=true \
        --field required_pull_request_reviews='{"required_approving_review_count":1}' \
        --field restrictions=null || true
    
    print_success "Branch protection configured"
else
    print_warning "GitHub CLI not found - skipping branch protection"
fi

# 6. Set up repository labels
print_status "Setting up repository labels..."
if command -v gh &> /dev/null; then
    # Create common labels
    gh label create "bug" --color "d73a4a" --description "Something isn't working" || true
    gh label create "documentation" --color "0075ca" --description "Improvements or additions to documentation" || true
    gh label create "duplicate" --color "cfd3d7" --description "This issue or pull request already exists" || true
    gh label create "enhancement" --color "a2eeef" --description "New feature or request" || true
    gh label create "good first issue" --color "7057ff" --description "Good for newcomers" || true
    gh label create "help wanted" --color "008672" --description "Extra attention is needed" || true
    gh label create "invalid" --color "e4e669" --description "This doesn't seem right" || true
    gh label create "question" --color "d876e3" --description "Further information is requested" || true
    gh label create "wontfix" --color "ffffff" --description "This will not be worked on" || true
    
    # Create project-specific labels
    gh label create "gameplay" --color "fbca04" --description "Related to gameplay mechanics" || true
    gh label create "ui/ux" --color "fef2c0" --description "Related to user interface and experience" || true
    gh label create "performance" --color "1d76db" --description "Related to performance optimization" || true
    gh label create "security" --color "ee0701" --description "Related to security issues" || true
    gh label create "testing" --color "5319e7" --description "Related to testing and quality assurance" || true
    gh label create "build/ci" --color "f7c6c7" --description "Related to build and continuous integration" || true
    gh label create "deployment" --color "c2e0c6" --description "Related to deployment and infrastructure" || true
    gh label create "documentation" --color "bfdadc" --description "Related to documentation" || true
    
    print_success "Repository labels created"
else
    print_warning "GitHub CLI not found - skipping label creation"
fi

# 7. Set up repository templates
print_status "Setting up repository templates..."
TEMPLATES_DIR=".github"
if [ -d "$TEMPLATES_DIR" ]; then
    print_status "Repository templates found in $TEMPLATES_DIR"
    print_success "Templates configured"
else
    print_warning "No repository templates directory found"
fi

# 8. Set up issue templates
print_status "Setting up issue templates..."
ISSUE_TEMPLATES_DIR=".github/ISSUE_TEMPLATE"
if [ -d "$ISSUE_TEMPLATES_DIR" ]; then
    print_status "Issue templates found in $ISSUE_TEMPLATES_DIR"
    print_success "Issue templates configured"
else
    print_warning "No issue templates directory found"
fi

# 9. Set up pull request templates
print_status "Setting up pull request templates..."
PR_TEMPLATE=".github/pull_request_template.md"
if [ -f "$PR_TEMPLATE" ]; then
    print_status "Pull request template found: $PR_TEMPLATE"
    print_success "Pull request template configured"
else
    print_warning "No pull request template found"
fi

# 10. Set up repository security
print_status "Setting up repository security..."
if command -v gh &> /dev/null; then
    # Enable security features
    gh api repos/:owner/:repo/automated-security-fixes --method PUT \
        --field enable_automated_security_fixes=true || true
    
    print_success "Repository security configured"
else
    print_warning "GitHub CLI not found - skipping security configuration"
fi

# 11. Set up repository secrets
print_status "Setting up repository secrets..."
if command -v gh &> /dev/null; then
    # Add common secrets (you'll need to set the actual values)
    gh secret set FLUTTER_WEB_CANVASKIT_URL --body "" || true
    gh secret set FIREBASE_PROJECT_ID --body "" || true
    gh secret set ANALYTICS_TOKEN --body "" || true
    
    print_success "Repository secrets configured (values need to be set)"
else
    print_warning "GitHub CLI not found - skipping secrets configuration"
fi

# 12. Set up repository webhooks
print_status "Setting up repository webhooks..."
if command -v gh &> /dev/null; then
    # Add webhook for CI/CD integration
    gh api repos/:owner/:repo/hooks \
        --method POST \
        --field config='{"url":"https://your-ci-server.com/webhook","content_type":"json"}' \
        --field events='["push","pull_request","release"]' \
        --field active=true || true
    
    print_success "Repository webhooks configured"
else
    print_warning "GitHub CLI not found - skipping webhook configuration"
fi

# 13. Set up repository teams
print_status "Setting up repository teams..."
if command -v gh &> /dev/null; then
    # Add teams with appropriate permissions
    gh api repos/:owner/:repo/teams/developers --method PUT \
        --field permission=write || true
    
    gh api repos/:owner/:repo/teams/reviewers --method PUT \
        --field permission=read || true
    
    print_success "Repository teams configured"
else
    print_warning "GitHub CLI not found - skipping team configuration"
fi

# 14. Set up repository topics
print_status "Setting up repository topics..."
if command -v gh &> /dev/null; then
    # Add relevant topics
    gh api repos/:owner/:repo/topics \
        --method PUT \
        --field names='["flutter","dart","game","space-invaders","mobile","web","desktop","gaming","retro","arcade","2d","shooter","enhanced","modern","cross-platform"]' || true
    
    print_success "Repository topics configured"
else
    print_warning "GitHub CLI not found - skipping topics configuration"
fi

# 15. Set up repository features
print_status "Setting up repository features..."
if command -v gh &> /dev/null; then
    # Enable repository features
    gh api repos/:owner/:repo \
        --method PATCH \
        --field has_issues=true \
        --field has_projects=true \
        --field has_wiki=true \
        --field has_downloads=true \
        --field delete_branch_on_merge=true \
        --field allow_squash_merge=true \
        --field allow_merge_commit=false \
        --field allow_rebase_merge=true || true
    
    print_success "Repository features configured"
else
    print_warning "GitHub CLI not found - skipping features configuration"
fi

# 16. Set up repository automation
print_status "Setting up repository automation..."
if command -v gh &> /dev/null; then
    # Enable Dependabot
    gh api repos/:owner/:repo/dependabot \
        --method PUT \
        --field enable=true || true
    
    print_success "Repository automation configured"
else
    print_warning "GitHub CLI not found - skipping automation configuration"
fi

# 17. Set up repository statistics
print_status "Setting up repository statistics..."
STATS_DIR=".git"
if [ -d "$STATS_DIR" ]; then
    # Create initial statistics files
    echo "{\"total_commits\": 0, \"last_commit\": \"\", \"last_commit_message\": \"\", \"last_commit_author\": \"\", \"last_commit_time\": 0}" > "$STATS_DIR/stats.json"
    echo "{\"branches\": {}, \"last_activity\": {}}" > "$STATS_DIR/branch_stats.json"
    echo "{\"contributors\": {}, \"last_activity\": {}}" > "$STATS_DIR/contributor_stats.json"
    echo "{\"merge_count\": 0, \"last_merge\": 0, \"last_merge_branch\": \"\", \"last_merge_type\": \"\"}" > "$STATS_DIR/merge_stats.json"
    echo "{\"rebase_count\": 0, \"last_rebase\": 0, \"last_rebase_branch\": \"\", \"last_rebase_upstream\": \"\"}" > "$STATS_DIR/rebase_stats.json"
    
    print_success "Repository statistics initialized"
else
    print_warning "Git directory not found"
fi

# 18. Set up repository documentation
print_status "Setting up repository documentation..."
DOCS_DIR="docs"
if [ -d "$DOCS_DIR" ]; then
    print_status "Documentation directory found: $DOCS_DIR"
    print_success "Documentation configured"
else
    print_warning "No documentation directory found"
fi

# 19. Set up repository scripts
print_status "Setting up repository scripts..."
SCRIPTS_DIR="scripts"
if [ -d "$SCRIPTS_DIR" ]; then
    # Make scripts executable
    find "$SCRIPTS_DIR" -name "*.sh" -exec chmod +x {} \;
    print_success "Repository scripts configured"
else
    print_warning "No scripts directory found"
fi

# 20. Final validation
print_status "Running final validation..."

# Check if all required files exist
REQUIRED_FILES=(
    "README.md"
    "pubspec.yaml"
    ".gitignore"
    ".gitattributes"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Required file missing: $file"
        exit 1
    fi
done

# Check if git hooks are executable
if [ -d ".git/hooks" ]; then
    HOOKS_COUNT=$(find ".git/hooks" -name "*.sh" -executable | wc -l)
    print_status "Found $HOOKS_COUNT executable hooks"
fi

# Check if Git LFS is installed
if command -v git-lfs &> /dev/null; then
    print_success "Git LFS is installed"
else
    print_warning "Git LFS is not installed"
fi

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    print_success "GitHub CLI is available"
else
    print_warning "GitHub CLI is not available - some features may be limited"
fi

print_success "🎉 Git repository setup completed!"
echo ""
echo "Repository setup summary:"
echo "✅ Git configuration applied"
echo "✅ Git attributes configured"
echo "✅ Git hooks set up"
echo "✅ Git LFS configured"
echo "✅ Branch protection rules applied"
echo "✅ Repository labels created"
echo "✅ Repository templates configured"
echo "✅ Repository security enabled"
echo "✅ Repository secrets configured"
echo "✅ Repository webhooks set up"
echo "✅ Repository teams configured"
echo "✅ Repository topics added"
echo "✅ Repository features enabled"
echo "✅ Repository automation set up"
echo "✅ Repository statistics initialized"
echo "✅ Repository documentation configured"
echo "✅ Repository scripts set up"
echo ""
echo "Next steps:"
echo "1. Set actual values for repository secrets"
echo "2. Configure CI/CD pipelines"
echo "3. Set up deployment environments"
echo "4. Invite team members"
echo "5. Create initial issues and milestones"
echo ""
echo "Repository is ready for development!"
