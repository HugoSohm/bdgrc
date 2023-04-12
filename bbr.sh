# Checkout branch
bbr() {
    if [ -z "$1" ]; then
        echo "Error: Issue reference is required (ex: PFM-42 or pfm-421-issue-name)"
        return 1
    fi

    teamKey=$(echo $1 | cut -d '-' -f1 | tr '[:lower:]' '[:upper:]')
    issueNumber=$(echo $1 | cut -d '-' -f2)
    branchName=$(curl --silent -X POST -H "Content-Type: application/json" -H "Authorization: $LINEAR_API_KEY" --data '{ "query": "{ issues(filter: { team: { key: { eq: \"'$teamKey'\" }}, number: { eq: '$issueNumber' }}) { nodes { branchName } } }" }' https://api.linear.app/graphql | jq -r '.data | .issues | .nodes | .[] | .branchName')

    if git show-ref --verify --quiet refs/heads/$branchName; then
        git checkout $branchName;
    else
        git checkout -b $branchName;
    fi
}