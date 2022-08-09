#!/bin/bash

source $(dirname "$0")/whisper_version_lib.sh

ASSERTS_FAILED=0

assert_equal() {
  if [[ $# != 2 ]]; then
    >&2 echo "assert_equal requires exactly two arguments!"
    return 1
  fi

  local EXPECTED="$1"
  local ACTUAL="$2"

  if [[ "$EXPECTED" != "$ACTUAL" ]]; then
    >&2 echo "assert_equal failed: expected $EXPECTED but got $ACTUAL"
    (( ASSERTS_FAILED = $ASSERTS_FAILED + 1))
  fi
}

test_removing_prefix() {
  local TAG=
  local TAG_PREFIX=
  local EXPECTED_TAG=

  TAG_PREFIX="dummy"
  EXPECTED_TAG="1.0.0-alpha"
  TAG=$(get_tag_without_prefix "$TAG_PREFIX-$EXPECTED_TAG" "$TAG_PREFIX")
  assert_equal "$EXPECTED_TAG" "$TAG"

  TAG_PREFIX="firmware_gen2"
  EXPECTED_TAG="1.0.0-alpha"
  TAG=$(get_tag_without_prefix "$TAG_PREFIX-$EXPECTED_TAG" "$TAG_PREFIX")
  assert_equal "$EXPECTED_TAG" "$TAG"

  TAG_PREFIX="whisper-beaglebone"
  EXPECTED_TAG="1.0.0-alpha"
  TAG=$(get_tag_without_prefix "$TAG_PREFIX-$EXPECTED_TAG" "$TAG_PREFIX")
  assert_equal "$EXPECTED_TAG" "$TAG"
}

test_getting_from_tag() {
  local TAG=
  local VERSION_CORE=
  local PRE_RELEASE=

  TAG="1.2.3"
  VERSION_CORE=$(get_version_core_from_tag "$TAG")
  PRE_RELEASE=$(get_pre_release_from_tag "$TAG")
  assert_equal "" "$PRE_RELEASE"
  assert_equal "1.2.3" "$VERSION_CORE"

  TAG="1.2.3-alpha"
  VERSION_CORE=$(get_version_core_from_tag "$TAG")
  PRE_RELEASE=$(get_pre_release_from_tag "$TAG")
  assert_equal "alpha" "$PRE_RELEASE"
  assert_equal "1.2.3" "$VERSION_CORE"

  TAG="12.49.308-alpha"
  VERSION_CORE=$(get_version_core_from_tag "$TAG")
  PRE_RELEASE=$(get_pre_release_from_tag "$TAG")
  assert_equal "alpha" "$PRE_RELEASE"
  assert_equal "12.49.308" "$VERSION_CORE"

  TAG="12.49.308-beta-trial"
  VERSION_CORE=$(get_version_core_from_tag "$TAG")
  PRE_RELEASE=$(get_pre_release_from_tag "$TAG")
  assert_equal "beta-trial" "$PRE_RELEASE"
  assert_equal "12.49.308" "$VERSION_CORE"
}

test_getting_build_num() {
  local BUILD=
  local BUILD_NUM=

  BUILD="DEV"
  BUILD_NUM=$(get_build_num_from_build "$BUILD")
  assert_equal "0" "$BUILD_NUM"

  BUILD="STG"
  BUILD_NUM=$(get_build_num_from_build "$BUILD")
  assert_equal "1" "$BUILD_NUM"

  BUILD="PRD"
  BUILD_NUM=$(get_build_num_from_build "$BUILD")
  assert_equal "2" "$BUILD_NUM"

  BUILD="FACTORY"
  BUILD_NUM=$(get_build_num_from_build "$BUILD")
  assert_equal "3" "$BUILD_NUM"

  BUILD="TEST"
  BUILD_NUM=$(get_build_num_from_build "$BUILD")
  assert_equal "4" "$BUILD_NUM"
}

test_assembling_release_name() {
  local RELEASE_NAME=

  RELEASE_NAME=$(
    assemble_release_name \
    "1.2.3" \
    "" \
    "0" \
    "branchname" \
    "abcdefg" \
    "" \
    "DEV"
  )
  assert_equal "1.2.3+0-branchname-abcdefg-DEV" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "1.2.3" \
    "" \
    "0" \
    "branchname" \
    "abcdefg" \
    "" \
    "PRD"
  )
  assert_equal "1.2.3" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "1.2.3" \
    "" \
    "1" \
    "branchname" \
    "abcdefg" \
    "" \
    "DEV"
  )
  assert_equal "1.2.3+1-branchname-abcdefg-DEV" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "1.2.3" \
    "" \
    "109" \
    "branch-name123_test/version" \
    "abcdefgh" \
    "" \
    "DEV" \
  )
  assert_equal "1.2.3+109-branch-name123_test/version-abcdefgh-DEV" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "10.25.34" \
    "" \
    "9" \
    "branch_name" \
    "d91k59mn" \
    "" \
    "DEV" \
  )
  assert_equal "10.25.34+9-branch_name-d91k59mn-DEV" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "1.2.3" \
    "alpha" \
    "0" \
    "branch_name" \
    "abcdefgh" \
    "" \
    "PRD" \
  )
  assert_equal "1.2.3-alpha+0-branch_name-abcdefgh-PRD" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "1.2.3" \
    "pre-release" \
    "10" \
    "branch/feature/zxc" \
    "abcdefgh" \
    "" \
    "STG" \
  )
  assert_equal "1.2.3-pre-release+10-branch/feature/zxc-abcdefgh-STG" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "1.2.3" \
    "beta-plus" \
    "19" \
    "one+two" \
    "abcdefgh" \
    "DIRTY" \
    "DEV" \
  )
  assert_equal "1.2.3-beta-plus+19-one+two-abcdefgh-DIRTY-DEV" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "1.0.0" \
    "" \
    "0" \
    "one+two" \
    "abcdefgh" \
    "" \
    "DEV" \
  )
  assert_equal "1.0.0+0-one+two-abcdefgh-DEV" "$RELEASE_NAME"

  RELEASE_NAME=$(
    assemble_release_name \
    "1.0.0" \
    "" \
    "0" \
    "one+two" \
    "abcdefgh" \
    "" \
    "PRD" \
  )
  assert_equal "1.0.0" "$RELEASE_NAME"
}

test_assembling_release_name_bl() {
  local RELEASE_NAME_BL=

  RELEASE_NAME_BL=$(
    assemble_release_name_bl \
    "1.2.3" \
    "alpha" \
    "0" \
    "0" \
  )
  assert_equal "1.2.3+0" "$RELEASE_NAME_BL"

  RELEASE_NAME_BL=$(
    assemble_release_name_bl \
    "18.97.3034" \
    "alpha" \
    "1" \
    "4" \
  )
  assert_equal "18.97.3034+4" "$RELEASE_NAME_BL"

  RELEASE_NAME_BL=$(
    assemble_release_name_bl \
    "18.97.3034" \
    "" \
    "0" \
    "4" \
  )
  assert_equal "18.97.3034+4" "$RELEASE_NAME_BL"

  RELEASE_NAME_BL=$(
    assemble_release_name_bl \
    "18.97.3034" \
    "" \
    "0" \
    "2" \
  )
  assert_equal "18.97.3034" "$RELEASE_NAME_BL"
}

test_removing_prefix
test_getting_from_tag
test_getting_build_num
test_assembling_release_name
test_assembling_release_name_bl

if [[ "$ASSERTS_FAILED" != 0 ]]; then
  echo "$0: $ASSERTS_FAILED assertion failures!"
  exit $ASSERTS_FAILED
else
  echo "$0: All tests passed!"
fi
