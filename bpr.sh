export GITHUB_TOKEN=
export LINEAR_API_KEY=

# Create Github Pull Request from current branch and return URL
bpr() {
    branchName=$(git branch --show)
    teamKey=$(echo $branchName | cut -d '-' -f1 | tr '[:lower:]' '[:upper:]')
    issueNumber=$(echo $branchName | cut -d '-' -f2)
    issueTitle=$(curl --silent -X POST -H "Content-Type: application/json" -H "Authorization: $LINEAR_API_KEY" --data '{ "query": "{ issues(filter: { team: { key: { eq: \"'$teamKey'\" }}, number: { eq: '$issueNumber' }}) { nodes { title } } }" }' https://api.linear.app/graphql | jq -r '.data | .issues | .nodes | .[] | .title')
    prTitle="[$teamKey-$issueNumber] ${issueTitle}"
    userName=$(git config --global user.name)
    repositoryName=$(git config --get remote.origin.url | sed 's/^.*:\(.*\)\.git$/\1/')
    githubRequest=$(curl --silent -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/${repositoryName}/pulls -d '{"title":"'$prTitle'","head":"bodyguard-ai:'$branchName'","base":"main"}')
    error=$(echo ${githubRequest} | jq -r '.message')

    if [[ "$error" != null ]]; then
        errorMessage=$(echo ${githubRequest} | jq -r '.errors | .[] | .message')

        if [[ "$errorMessage" != null ]]; then
            echo $errorMessage;
        else
            echo $error;
        fi
    else
        prLink=$(echo ${githubRequest} | jq -r '.html_url')
        echo $prLink;
    fi
}