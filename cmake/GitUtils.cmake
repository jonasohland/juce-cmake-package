message(STATUS "GitUtils module loaded")

find_package(Git REQUIRED)

function(git_get_version_string _working_dir _out_var)

    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags
                        WORKING_DIRECTORY ${_working_dir} 
                        OUTPUT_VARIABLE _extracted_version_str
                        RESULT_VARIABLE _git_return_code
                        OUTPUT_STRIP_TRAILING_WHITESPACE)

    if(_git_return_code)
        message(FATAL_ERROR "Git invocation failed with: ${_git_return_code}")
    endif()

    set(${_out_var} ${_extracted_version_str} PARENT_SCOPE)

endfunction()

function(git_get_current_commit_sha)
    
    cmake_parse_arguments(PARSE_ARGV 2 _ "SHORT" "" "")

    if(__SHORT)
        set(_command ${GIT_EXECUTABLE} rev-parse --short HEAD)
    else()
        set(_command ${GIT_EXECUTABLE} rev-parse HEAD)      
    endif()
    
    execute_process(COMMAND ${_command} 
                    WORKING_DIRECTORY ${ARGV0}
                    OUTPUT_VARIABLE _git_output
                    RESULT_VARIABLE _git_return_code
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
                    
    if(_git_return_code)
        message(FATAL_ERROR "Git invocation failed with code ${_git_return_code}")
    endif()

    set(${ARGV1} ${_git_output} PARENT_SCOPE)

endfunction()

function(git_get_full_version_details _working_dir _out_var_prefix)

    git_get_version_string(${_working_dir} _version_string)

    # split version string (v1.0.2-3-fweiuniuw -> v1;0;2-3-fweiuniuw)
    string(REPLACE "." ";" _split_version_str ${_version_string})

    # remove the v from major version component if it exists
    list(GET _split_version_str 0 _temp_major)
    string(REPLACE "v" "" _temp_major ${_temp_major})

    # get last component
    list(LENGTH _split_version_str _version_list_length)
    math(EXPR _version_last_component_index "${_version_list_length} - 1")

    list(GET _split_version_str ${_version_last_component_index} _temp_patch)

    # get commit sha and commits since last tags from last component if present there
    string(REPLACE "-" ";" _split_temp_patch ${_temp_patch})

    list(LENGTH _split_temp_patch _split_temp_patch_length)

    git_get_current_commit_sha(${_working_dir} _git_current_commit_sha SHORT)

    if(${_split_temp_patch_length} EQUAL 3)

        list(GET _split_temp_patch 2 _temp_current_commit_sha)
        list(GET _split_temp_patch 1 _temp_commits_since_tag)
        list(GET _split_temp_patch 0 _temp_last_component)

        string(REGEX REPLACE "^g" "" _temp_current_commit_sha ${_temp_current_commit_sha})

        if(NOT (${_git_current_commit_sha} EQUAL ${_temp_current_commit_sha}))
            message(FATAL_ERROR "Error parsing Git output")
        endif()

        set("${_out_var_prefix}_CURRENT_COMMIT_SHA" ${_temp_current_commit_sha} PARENT_SCOPE)
        set("${_out_var_prefix}_COMMITS_SINCE_TAG" ${_temp_commits_since_tag} PARENT_SCOPE)
        set(_last_component ${_temp_last_component})

    elseif(${_split_temp_patch_length} EQUAL 1)

        set("${_out_var_prefix}_CURRENT_COMMIT_SHA" ${_git_current_commit_sha} PARENT_SCOPE)
        set("${_out_var_prefix}_COMMITS_SINCE_TAG" 0 PARENT_SCOPE)

        set(_last_component ${_split_temp_patch})

    else()
        message(FATAL_ERROR "Could not parse version string")
    endif()

endfunction()