message(STATUS "JuceModuleBuilder module loaded")

include(JuceDependencies)

function(juce_build_module)

    set(juce_build_module_fn_options OVERWRITE)
    set(juce_build_module_fn_one_kw_args PREFIX JUCE_LIBRARY_CODE_DIR JUCE_SOURCES_LIST)

    if(NOT juce_modules_dir)
        message(FATAL_ERROR "juce_modules_dir not defined")
    endif()

    if(NOT juce_templates_dir)
        message(FATAL_ERROR "juce_modules_dir not defined")
    endif()
    
    cmake_parse_arguments(PARSE_ARGV 1 _ 
                            "${juce_build_module_fn_options}"
                            "${juce_build_module_fn_one_kw_args}"
                            "")

    set(_module_name ${ARGV0})
    set(_output_name "${__PREFIX}_${_module_name}")

    set(juce_cmake_module_name "juce_${_module_name}")

    if(APPLE)
        set(juce_cmake_source_file_extension "mm")
    else()
        set(juce_cmake_source_file_extension "cpp")
    endif()

    set(_module_template "${juce_templates_dir}/include_juce_module.in")
    set(_module_source "${__JUCE_LIBRARY_CODE_DIR}/include_${juce_cmake_module_name}.${juce_cmake_source_file_extension}")

    configure_file(${_module_template} ${_module_source})

    list(APPEND ${__JUCE_SOURCES_LIST} ${_module_source})
    set(${__JUCE_SOURCES_LIST} ${${__JUCE_SOURCES_LIST}} PARENT_SCOPE)

endfunction()