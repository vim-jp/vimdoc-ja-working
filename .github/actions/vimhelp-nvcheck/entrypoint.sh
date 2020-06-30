#!/bin/sh

cd "$GITHUB_WORKSPACE" || true

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# find doc -name \*.jax -print0 | xargs -0 nvcheck        \
#       | reviewdog -f=checkstyle                         \
#         -name="${INPUT_TOOL_NAME}"                      \
#         -reporter="${INPUT_REPORTER:-github-pr-review}" \
#         -filter-mode="${INPUT_FILTER_MODE}"             \
#         -fail-on-error="${INPUT_FAIL_ON_ERROR}"         \
#         -level="${INPUT_LEVEL}"                         \
#         ${INPUT_REVIEWDOG_FLAGS}

# github-pr-review only diff adding
if [ "${INPUT_REPORTER}" = "github-pr-review" ]; then
  # fix
  find doc -name \*.jax -print0 | xargs -0 nvcheck -i

  TMPFILE=$(mktemp)
  git diff >"${TMPFILE}"

  reviewdog                        \
    -name="nvcheck-fix"            \
    -f=diff                        \
    -f.diff.strip=1                \
    -name="${INPUT_TOOL_NAME}-fix" \
    -reporter="github-pr-review"   \
    -filter-mode="diff_context"    \
    -level="${INPUT_LEVEL}"        \
    ${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}"

  git restore . || true
  rm -f "${TMPFILE}"
fi

# EOF
