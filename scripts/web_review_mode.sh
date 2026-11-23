#!/usr/bin/env bash
# Shared, testable deployment selection. Only the isolated review branch opts in.
configure_web_review_mode() {
    if [[ ( "${VERCEL_ENV:-}" == preview || "${VERCEL_ENV:-}" == staging ) && "${VERCEL_GIT_COMMIT_REF:-}" == review/neon-cool-kid-articulated-preview ]]; then
        COOL_KID_RIG_REVIEW=1
    fi
    if [[ "${VERCEL_ENV:-}" == production && "${COOL_KID_RIG_REVIEW:-0}" == 1 ]]; then
        echo 'ERROR: Cool Kid candidate review cannot be published as production.' >&2
        return 2
    fi
}
