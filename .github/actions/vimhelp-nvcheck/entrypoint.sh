#!/bin/sh

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}" || exit 1
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

reviewdog_exit_val="0"
# shellcheck disable=SC2086
find doc -name \*.jax -print0 | xargs -0 nvcheck        \
      | reviewdog -efm="%f:%l: %m"                      \
        -name="${INPUT_TOOL_NAME}"                      \
        -reporter="${INPUT_REPORTER:-github-pr-review}" \
        -filter-mode="${INPUT_FILTER_MODE}"             \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}"         \
        -level="${INPUT_LEVEL}"                         \
        ${INPUT_REVIEWDOG_FLAGS} || reviewdog_exit_val="$?"

# github-pr-review only diff adding
if [ "${INPUT_REPORTER}" = "github-pr-review" ]; then
  # fix
  find doc -name \*.jax -print0 | xargs -0 nvcheck -i

  TMPFILE=$(mktemp)
  git diff >"${TMPFILE}"

  # shellcheck disable=SC2086
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

# Throw error if an error occurred and fail_on_error is true
if [ "${INPUT_FAIL_ON_ERROR}" = "true" ] && [ "${reviewdog_exit_val}" != "0" ]; then
  exit 1
fi

# EOF
