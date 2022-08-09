cmake_minimum_required(VERSION 3.20.0)

set(WHISPER_VERSION_HEADER_DIR ${CMAKE_BINARY_DIR}/generated/whisper_version/)
set(WHISPER_VERSION_HEADER ${WHISPER_VERSION_HEADER_DIR}/whisper_version.h)

add_custom_command(
    OUTPUT ${WHISPER_VERSION_HEADER}
           # Force this command to run as __DUMMY_OUTPUT never exists
           __DUMMY_OUTPUT
    COMMAND ${CMAKE_COMMAND}
        -DWHISPER_VERSION_HEADER=${WHISPER_VERSION_HEADER}
        -P ${CMAKE_CURRENT_LIST_DIR}/whisper_version_script.cmake
)

add_custom_target(
    whisper_version
    DEPENDS ${WHISPER_VERSION_HEADER}
)
