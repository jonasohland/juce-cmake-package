cmake_minimum_required(VERSION 3.4)

project(JUCE)

list(APPEND CMAKE_MODULE_PATH   "${CMAKE_CURRENT_LIST_DIR}/cmake")

set(juce_root                   "${CMAKE_CURRENT_LIST_DIR}/JUCE")
set(juce_modules_dir            "${juce_root}/modules")   

include(GitUtils)
include(SemVer)
include(JuceModuleBuilder)
include(JuceDependencies)

if(NOT juce_instance_name)
    set(juce_instance_name                          "JUCE")
endif()

git_get_full_version_details(${juce_root} JUCE)

message(STATUS "SHA:        ${JUCE_CURRENT_COMMIT_SHA}")
message(STATUS "Commits:    ${JUCE_COMMITS_SINCE_TAG}")

set(mods "video" "dsp" "graphics" "audio_processors")

juce_resolve_modules(${mods})

# juce_get_module_dependencies("graphics" MODULES_VAR juce_modules)

# message(STATUS "modules: ${juce_modules}")

# message(STATUS "JUCE Version: ${__version}")