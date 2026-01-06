#!/bin/bash
PROPOSAL_DIR="_agent-proposals"
latest_proposal=$(ls -t "$PROPOSAL_DIR"/*.md 2>/dev/null | head -1)
if [ -z "$latest_proposal" ]; then echo "No proposals to review"; exit 0; fi
cat "$latest_proposal"
read -p "Approve these changes? (y/n): " approval
if [ "$approval" = "y" ]; then
    mv "$latest_proposal" "$PROPOSAL_DIR/approved/"
    echo "✅ Approved"
else
    mv "$latest_proposal" "$PROPOSAL_DIR/rejected/"
    echo "❌ Rejected"
fi
