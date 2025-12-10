#!/bin/bash
# Create documentation repository structure

REPO_NAME="infrastructure-docs"
REPO_DIR="$HOME/$REPO_NAME"

echo "Creating documentation repository: $REPO_NAME"

# Create repo structure
mkdir -p "$REPO_DIR"/{vps-management,workflows,guides,scripts}

echo "✅ Repository structure created at: $REPO_DIR"

# Copy VPS management docs
echo "Copying VPS management documentation..."
cp vps-management/*.md "$REPO_DIR/vps-management/" 2>/dev/null
cp vps-management/*.sh "$REPO_DIR/scripts/" 2>/dev/null

echo "✅ Files copied"
echo ""
echo "Repository ready at: $REPO_DIR"
echo ""
echo "Next steps:"
echo "1. cd $REPO_DIR"
echo "2. git init"
echo "3. gh repo create $REPO_NAME --public --source=. --remote=origin"
echo "4. git add ."
echo "5. git commit -m 'Initial documentation'"
echo "6. git push -u origin main"
