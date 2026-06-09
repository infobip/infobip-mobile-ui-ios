#!/bin/bash
set -e

# Jenkins checks out a detached SHA; re-attach to the named branch first
git checkout "${BRANCH_NAME_TO_BUILD}"

git tag -a "${CUSTOM_VERSION_NUMBER}" -m "Version ${CUSTOM_VERSION_NUMBER} - ${RELEASE_NOTES}"

git push origin1 "${BRANCH_NAME_TO_BUILD}"  # push the branch HEAD via the SSH remote Jenkins pre-configures
git push origin1 "${CUSTOM_VERSION_NUMBER}"  # push the tag (git does not push tags by default)

# Create GitHub Release — RELEASE_NOTES piped through Python to produce valid JSON
PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
    'tag_name':   '${CUSTOM_VERSION_NUMBER}',
    'name':       '${CUSTOM_VERSION_NUMBER}',
    'body':       sys.stdin.read(),
    'draft':      False,
    'prerelease': False
}))
" <<< "${RELEASE_NOTES}")

curl -sf \
  -X POST \
  -H "Authorization: token ${GITHUB_API_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  -d "${PAYLOAD}" \
  "https://api.github.com/repos/infobip/infobip-mobile-ui-ios/releases"
