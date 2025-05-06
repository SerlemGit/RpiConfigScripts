#!/bin/sh

# Check if a branch name is provided
if [ -z "$1" ]; then
    echo "Usage: checkoutSub <branch-name>"
    exit 1
fi

BRANCH_NAME=$1

# Checkout the branch
git checkout "$BRANCH_NAME"
if [ $? -ne 0 ]; then
    echo "Failed to checkout branch: $BRANCH_NAME"
    exit 1
fi

# Update submodules to the recorded commit
git submodule update --recursive --checkout

echo "Successfully checked out to $BRANCH_NAME and updated submodules."