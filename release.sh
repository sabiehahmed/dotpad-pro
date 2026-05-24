#!/usr/bin/env bash
#
# release.sh — bump version, tag, and push to trigger the GitHub release build.
#
# Usage:
#   ./release.sh desktop major|minor|patch [-y]
#
# Pushing the tag fires .github/workflows/release.yml, which builds the
# unsigned DMG and attaches it to a GitHub Release.

set -euo pipefail

# --- args ---------------------------------------------------------------
COMPONENT="${1:-}"
BUMP="${2:-}"
ASSUME_YES="${3:-}"

die() { echo "error: $*" >&2; exit 1; }

usage() {
  echo "usage: ./release.sh <component> <major|minor|patch> [-y]" >&2
  echo "  component: desktop" >&2
  exit 1
}

[ -n "$COMPONENT" ] && [ -n "$BUMP" ] || usage

case "$COMPONENT" in
  desktop) ;;
  *) die "unknown component '$COMPONENT' (supported: desktop)" ;;
esac

case "$BUMP" in
  major|minor|patch) ;;
  *) die "bump must be major|minor|patch (got '$BUMP')" ;;
esac

# --- preflight ----------------------------------------------------------
command -v git >/dev/null || die "git not found"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repo"

[ -z "$(git status --porcelain)" ] || die "working tree dirty — commit or stash first"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
TAG_PREFIX="${COMPONENT}-v"

# --- current version ----------------------------------------------------
LATEST="$(git tag --list "${TAG_PREFIX}*" --sort=-v:refname | head -1 || true)"
if [ -n "$LATEST" ]; then
  CURRENT="${LATEST#"$TAG_PREFIX"}"
else
  CURRENT="0.0.0"
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"
MAJOR="${MAJOR:-0}"; MINOR="${MINOR:-0}"; PATCH="${PATCH:-0}"

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEW="${MAJOR}.${MINOR}.${PATCH}"
NEW_TAG="${TAG_PREFIX}${NEW}"

git rev-parse "$NEW_TAG" >/dev/null 2>&1 && die "tag $NEW_TAG already exists"

echo "component : $COMPONENT"
echo "branch    : $BRANCH"
echo "current   : ${CURRENT}  (${LATEST:-no prior tag})"
echo "new tag   : $NEW_TAG"

if [ "$ASSUME_YES" != "-y" ]; then
  printf "Proceed with tag + push? [y/N] "
  read -r ans
  case "$ans" in y|Y|yes) ;; *) die "aborted" ;; esac
fi

# --- bump project.yml version (desktop) ---------------------------------
PROJECT_YML="desktop/project.yml"
if [ "$COMPONENT" = "desktop" ] && [ -f "$PROJECT_YML" ]; then
  # Update MARKETING_VERSION so the built app reports the new version.
  /usr/bin/sed -i '' -E "s/(MARKETING_VERSION: )\"[^\"]*\"/\1\"${NEW}\"/" "$PROJECT_YML"
  if ! git diff --quiet -- "$PROJECT_YML"; then
    git add "$PROJECT_YML"
    git commit -m "release(${COMPONENT}): v${NEW}"
  fi
fi

# --- tag + push ---------------------------------------------------------
git tag -a "$NEW_TAG" -m "${COMPONENT} v${NEW}"
git push origin "$BRANCH"
git push origin "$NEW_TAG"

echo "pushed $NEW_TAG"

# --- watch the release workflow (optional) ------------------------------
if command -v gh >/dev/null 2>&1; then
  echo "watching release workflow…"
  sleep 5
  RUN_ID="$(gh run list --workflow release.yml --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)"
  if [ -n "$RUN_ID" ]; then
    gh run watch "$RUN_ID" --exit-status || die "release workflow failed (run $RUN_ID)"
    echo "release published:"
    gh release view "$NEW_TAG" --web 2>/dev/null || true
  else
    echo "could not find workflow run; check GitHub Actions."
  fi
else
  echo "gh CLI not installed — track build at: GitHub → Actions → Release"
fi
