#!/bin/bash
set -e

# Skip if on master branch
if [ "$BRANCH_NAME_TO_BUILD" = "master" ]; then
  echo "================================================"
  echo "Skipping Copyright Header Check (master branch)"
  echo "================================================"
  exit 0
fi

echo "================================================"
echo "Running Copyright Header Check"
echo "================================================"

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPTS_DIR/.."

# Define project configurations: "PROJECT_NAME ROOT_PATH"
declare -a PROJECTS=(
  "IBCallUI Sources/IBCallUI"
)

# Run the copyright header script for each project
for project_config in "${PROJECTS[@]}"; do
  # Split the configuration into project name and root path
  read -r project_name root_path <<< "$project_config"

  echo ""
  echo "Processing: $project_name (in $root_path)"
  echo "----------------------------------------"

  "$SCRIPTS_DIR/add-copyright-header.sh" "$project_name" "$root_path"
done

echo ""
echo "================================================"
echo "Copyright Header Check Complete"
echo "================================================"

# Check if any source files were modified by the copyright script
MODIFIED=$(git diff --name-only -- '*.swift' '*.h' '*.m' '*.mm' '*.c' '*.cpp' '*.hpp')

if [ -z "$MODIFIED" ]; then
  echo "✅ All files have proper copyright headers"
  exit 0
else
  echo "⚠️  Files with missing copyright headers were fixed"
  echo ""
  echo "Modified files:"
  echo "$MODIFIED"
  echo ""
  echo "❌ BUILD FAILED: Copyright headers were missing."
  echo "   Please review and commit the changes above."
  exit 1
fi
