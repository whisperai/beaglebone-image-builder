# Whisper Version Library

## Version Format
In most cases, a release name looks like
```
[version-core]-[pre-release-tag]+[build-meta-tag]
```
for example
```
1.0.0-D1+63-master-7fcfb6f4-DEV
```

A special case is made for external releases, which have empty pre-release-tag, build variant `PRD`, and are directly associated with a git tag. In this case only the version core will be present
```
1.0.0
```

See [the spec](https://docs.google.com/document/d/1yZ_DGeWO0tp7mm_wt24WeB0Nfp8F91dVnJvhT0vKM04) for more details

## Integration Guide
Each build system (e.g. Make, Cmake) should have a file that exports `whisper_version` variables to the rest of the build (e.g. `whisper_version.mk`, `whisper_version.cmake`).

### CI
The version script will fail in shallow checkouts which are used in CI. To get around this, the CI environment determines the versions once during configuration, then defines them as environment variables in subsequent steps.
```
WHISPER_VERSION_ENV_VARS=$(make whisper_version_env_vars)
WHISPER_VERSION_RELEASE_NAME=$(make releasename)
WHISPER_VERSION_RELEASE_NAME_BL=$(make releasename_bl)
```
The build system should use these variables as a fallback when the script returns nothing.
