#!/bin/bash

debug_log() {
  [[ "$WHISPER_VERSION_DEBUG_LOG" = true ]] && >&2 echo "WHISPER_VERSION_DEBUG: $1"
}

is_valid_tag_prefix() {
  local TAG_PREFIX="$1"

  if [[ -z $(get_latest_tag_matching_prefix "$TAG_PREFIX") ]]; then
    debug_log "Unknown tag prefix \"$TAG_PREFIX\""
    return 1
  fi

  return 0
}

get_tag_without_prefix() {
  local TAG_WITH_PREFIX="$1"
  local TAG_PREFIX="$2"

  echo "${TAG_WITH_PREFIX##${TAG_PREFIX}-}"
}

get_latest_tag_matching_prefix() {
  local TAG_PREFIX="$1"

  debug_log "Looking for tags with prefix \"$TAG_PREFIX\""
  echo "$(git describe --tags --abbrev=0 --match "$TAG_PREFIX*" 2> /dev/null)"
}

get_commits_since_tag() {
  local TAG="$1"

  debug_log "Getting commits since tag \"$TAG\""
  echo $(git rev-list $TAG.. --count)
}

get_commit_sha() {
  echo $(git rev-parse --short=8 HEAD)
}

get_branch_name() {
  echo $(git rev-parse --abbrev-ref HEAD) | sed 's@/@_@g'
}

get_dirty_flag() {
  if [[ -z $(git diff --stat --ignore-submodules) ]]; then
    echo ""
  else
    echo "DIRTY"
  fi
}

get_version_core_from_tag() {
  local TAG="$1"

  debug_log "Getting version core from tag \"$TAG\""

  if [[ "$TAG" =~ "-" ]]; then
    echo "${TAG%%-*}"
  else
    echo "$TAG"
  fi
}

get_pre_release_from_tag() {
  local TAG="$1"

  debug_log "Getting pre-release from tag \"$TAG\""

  if [[ "$TAG" =~ "-" ]]; then
    local VERSION_CORE=$(get_version_core_from_tag "$TAG")
    echo "${TAG##${VERSION_CORE}-}"
  else
    echo ""
  fi
}

is_valid_build() {
  local BUILD="$1"

  if [[ -z $(get_build_num_from_build "$BUILD") ]]; then
    debug_log "Unknown build \"$BUILD\""
    return 1
  fi

  return 0
}

get_build_num_from_build() {
  local BUILD="$1"
  local BUILD_NUM=""

  case "$BUILD" in
      "DEV" )      BUILD_NUM="0"
                   ;;
      "STG" )      BUILD_NUM="1"
                   ;;
      "PRD" )     BUILD_NUM="2"
                   ;;
      "FACTORY" )  BUILD_NUM="3"
                   ;;
      "TEST" )     BUILD_NUM="4"
                   ;;
  esac

  echo "$BUILD_NUM"
}

assemble_release_name() {
  local VERSION_CORE="$1"
  local PRE_RELEASE="$2"
  local COMMITS_SINCE_TAG="$3"
  local BRANCH_NAME="$4"
  local COMMIT_SHA="$5"
  local DIRTY_FLAG="$6"
  local BUILD="$7"

  local RELEASE_NAME="$VERSION_CORE"
  if [[ "$COMMITS_SINCE_TAG" = "0" ]] && [[ -z "$PRE_RELEASE" ]] && [[ "$BUILD" = "PRD" ]]; then
    # Omit the metadata if this commit is an external release
    echo "$RELEASE_NAME"
    return 0
  fi

  [[ -n "$PRE_RELEASE" ]] && RELEASE_NAME="$RELEASE_NAME-$PRE_RELEASE"
  RELEASE_NAME="$RELEASE_NAME+$COMMITS_SINCE_TAG-$BRANCH_NAME-$COMMIT_SHA"
  [[ -n "$DIRTY_FLAG" ]] && RELEASE_NAME="$RELEASE_NAME-${DIRTY_FLAG}"
  RELEASE_NAME="$RELEASE_NAME-$BUILD"

  echo "$RELEASE_NAME"
}

get_release_name() {
  local TAG_PREFIX="$1"
  local BUILD="$2"

  debug_log "Creating release_name with tag prefix \"$TAG_PREFIX\" and build \"$BUILD\""

  local TAG_WITH_PREFIX=$(get_latest_tag_matching_prefix "$TAG_PREFIX")
  local TAG="$(get_tag_without_prefix "$TAG_WITH_PREFIX" "$TAG_PREFIX")"
  local VERSION_CORE=$(get_version_core_from_tag "$TAG")
  local PRE_RELEASE=$(get_pre_release_from_tag "$TAG")
  local COMMITS_SINCE_TAG=$(get_commits_since_tag "$TAG_WITH_PREFIX")
  local BRANCH_NAME=$(get_branch_name)
  local COMMIT_SHA=$(get_commit_sha)
  local DIRTY_FLAG=$(get_dirty_flag)

  echo $(
    assemble_release_name \
      "$VERSION_CORE" \
      "$PRE_RELEASE" \
      "$COMMITS_SINCE_TAG" \
      "$BRANCH_NAME" \
      "$COMMIT_SHA" \
      "$DIRTY_FLAG" \
      "$BUILD" \
  )
}

assemble_release_name_bl() {
  local VERSION_CORE="$1"
  local PRE_RELEASE="$2"
  local COMMITS_SINCE_TAG="$3"
  local BUILD_NUM="$4"

  local RELEASE_NAME_BL="$VERSION_CORE"
  local PRD_BUILD_NUM=$(get_build_num_from_build "PRD")

  if [[ "$COMMITS_SINCE_TAG" = "0" ]] && [[ -z "$PRE_RELEASE" ]] && [[ "$BUILD_NUM" = "$PRD_BUILD_NUM" ]]; then
    # Omit the metadata if this commit is an external release
    echo "$RELEASE_NAME_BL"
    return 0
  fi

  RELEASE_NAME_BL="$RELEASE_NAME_BL+$BUILD_NUM"

  echo "$RELEASE_NAME_BL"
}

get_release_name_bl() {
  local TAG_PREFIX="$1"
  local BUILD="$2"

  debug_log "Creating release_name_bl with tag prefix \"$TAG_PREFIX\" and build \"$BUILD\""

  local TAG_WITH_PREFIX=$(get_latest_tag_matching_prefix "$TAG_PREFIX")
  local TAG="$(get_tag_without_prefix "$TAG_WITH_PREFIX" "$TAG_PREFIX")"
  local VERSION_CORE=$(get_version_core_from_tag "$TAG")
  local PRE_RELEASE=$(get_pre_release_from_tag "$TAG")
  local COMMITS_SINCE_TAG=$(get_commits_since_tag "$TAG_WITH_PREFIX")
  local BUILD_NUM=$(get_build_num_from_build "$BUILD")

  echo $(
    assemble_release_name_bl \
      "$VERSION_CORE" \
      "$PRE_RELEASE" \
      "$COMMITS_SINCE_TAG" \
      "$BUILD_NUM" \
  )
}

get_export_args() {
  TAG_PREFIX="$1"
  BUILD="$2"

  local RELEASE_NAME=$(get_release_name "$TAG_PREFIX" "$BUILD")
  local RELEASE_NAME_BL=$(get_release_name_bl "$TAG_PREFIX" "$BUILD")

  local TAG_WITH_PREFIX=$(get_latest_tag_matching_prefix "$TAG_PREFIX")
  local TAG="$(get_tag_without_prefix "$TAG_WITH_PREFIX" "$TAG_PREFIX")"
  local VERSION_CORE=$(get_version_core_from_tag "$TAG")
  local MAJOR_MINOR_PATCH=(${VERSION_CORE//./ })
  local MAJOR=${MAJOR_MINOR_PATCH[0]}
  local MINOR=${MAJOR_MINOR_PATCH[1]}
  local PATCH=${MAJOR_MINOR_PATCH[2]}

  local COMMITS_SINCE_TAG=$(get_commits_since_tag "$TAG_WITH_PREFIX")
  local BRANCH_NAME=$(get_branch_name)
  local COMMIT_SHA=$(get_commit_sha)
  local DIRTY=$(get_dirty_flag)
  [[ -n "$DIRTY" ]] && COMMIT_SHA=$COMMIT_SHA-$DIRTY

  EXPORTS=(
    WHISPER_VERSION_RELEASE_NAME="$RELEASE_NAME"
    WHISPER_VERSION_RELEASE_NAME_BL="$RELEASE_NAME_BL"
    WHISPER_VERSION_VERSION_CORE="$VERSION_CORE"
    WHISPER_VERSION_COMMITS_SINCE_TAG="$COMMITS_SINCE_TAG"
    WHISPER_VERSION_BRANCH_NAME="$BRANCH_NAME"
    WHISPER_VERSION_COMMIT_SHA="$COMMIT_SHA"
    WHISPER_VERSION_BUILD="$BUILD"
  )

  echo "${EXPORTS[@]}"
}
