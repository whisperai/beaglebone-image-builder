cmake_minimum_required(VERSION 3.20.0)

# Called as a script by whisper_version.cmake

execute_process(
  COMMAND ./whisper_version.sh -f=export
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  OUTPUT_VARIABLE WHISPER_VERSION_ENV_VARS
)

string(STRIP "${WHISPER_VERSION_ENV_VARS}" WHISPER_VERSION_ENV_VARS)
if ("${WHISPER_VERSION_ENV_VARS}" STREQUAL "")
  # In CI this variable is set in the environment during configuration
  set(WHISPER_VERSION_ENV_VARS $ENV{WHISPER_VERSION_ENV_VARS})
endif()

string(REPLACE " " ";" WHISPER_VERSION_ENV_VARS "${WHISPER_VERSION_ENV_VARS}")
foreach(ENV_VAR ${WHISPER_VERSION_ENV_VARS})
  string(REPLACE "=" ";" ENV_VAR_LIST "${ENV_VAR}")
  list(GET ENV_VAR_LIST 0 ENV_VAR_NAME)
  list(GET ENV_VAR_LIST 1 ENV_VAR_VALUE)
  string(STRIP "${ENV_VAR_VALUE}" ENV_VAR_VALUE)
  set(ENV{${ENV_VAR_NAME}} "${ENV_VAR_VALUE}")
endforeach()

# The file's timestamp is updated only if the file's contents change
configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/whisper_version.h.in"
  "${WHISPER_VERSION_HEADER}"
)
