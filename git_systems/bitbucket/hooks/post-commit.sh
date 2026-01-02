#!/bin/bash
# Bitbucket post-commit hook for Space Invaders

# Log the commit
echo "Commit completed at $(date)" >> commit.log

# Notify team (example - would need to be configured with actual notification service)
# curl -X POST -H "Content-Type: application/json" -d '{"text":"New commit pushed to Space Invaders"}' WEBHOOK_URL

echo "Post-commit hook executed"