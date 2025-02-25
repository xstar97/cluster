# Description: Resets the git history
# Example: git_reset
function git_reset
    check_command "git"
    echo "Resetting repository to a new initial commit..."
    
    # Reset to a new initial commit and force push to the main branch
    git reset (git commit-tree HEAD^{tree} -m 'Initial commit') && git push --force origin main

    if test $status -eq 0
        echo "Repository has been successfully reset to a new initial commit and force-pushed to 'main'."
    else
        echo "Error: Failed to reset the repository."
        exit 1
    end
end
