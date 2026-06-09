#!/bin/bash
set -e

git commit -m "Version ${CUSTOM_VERSION_NUMBER} - ${RELEASE_NOTES}"
git tag -a "${CUSTOM_VERSION_NUMBER}" -m "Version ${CUSTOM_VERSION_NUMBER} - ${RELEASE_NOTES}"

GITHUB_REMOTE="https://${GITHUB_USER}:${GITHUB_API_TOKEN}@github.com/infobip/infobip-mobile-ui-ios.git"
git push "${GITHUB_REMOTE}" "${BRANCH_NAME_TO_BUILD}"
git push "${GITHUB_REMOTE}" "${CUSTOM_VERSION_NUMBER}"

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
