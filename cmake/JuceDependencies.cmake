macro(_juce_module_dependency_add _dependency_name _dependency_list_var)

    list(FIND ${_dependency_list_var} ${_dependency_name} _dependency_list_index)

    # message(STATUS "Adding ${_dependency_name} to ${_dependency_list_var}")

    if(${_dependency_list_index} EQUAL "-1")
        list(APPEND ${_dependency_list_var} ${_dependency_name})
    endif()

endmacro(_juce_module_dependency_add)

function(_juce_module_add_one_dependency _dependency_type _dependency_name)

    # message(STATUS "Adding ${_dependency_type} dependency ${_dependency_name}")

    if(${_dependency_type} STREQUAL "module")
        _juce_module_dependency_add(${_dependency_name} _modules)
    elseif(${_dependency_type} STREQUAL "macos_framework")
        _juce_module_dependency_add(${_dependency_name} _macos_frameworks)
    elseif(${_dependency_type} STREQUAL "linux_lib")
        _juce_module_dependency_add(${_dependency_name} _linux_libs)
    elseif(${_dependency_type} STREQUAL "mingw_lib")
        _juce_module_dependency_add(${_dependency_name} _mingw_libs)
    else()
    endif()

    set(_modules            ${_modules}             PARENT_SCOPE)
    set(_macos_frameworks   ${_macos_frameworks}    PARENT_SCOPE)
    set(_linux_libs         ${_linux_libs}          PARENT_SCOPE)
    set(_mingw_libs         ${_mingw_libs}          PARENT_SCOPE)

endfunction()

function(juce_get_module_dependencies)

    # message(STATUS ${_module})

    cmake_parse_arguments(PARSE_ARGV 1 _ "" 
        "MODULES_VAR;LINUX_LIBS_VAR;MACOS_FRAMEWORKS_VAR;MINGW_LIBS_VAR" "")

    set(_module ${ARGV0})

    if(${_module} STREQUAL "core")

        _juce_module_add_one_dependency(macos_framework Cocoa)
        _juce_module_add_one_dependency(macos_framework IOKit)

        _juce_module_add_one_dependency(linux_lib rt)
        _juce_module_add_one_dependency(linux_lib dl)
        _juce_module_add_one_dependency(linux_lib pthread)

        _juce_module_add_one_dependency(mingw_lib uuid)
        _juce_module_add_one_dependency(mingw_lib wsock32)
        _juce_module_add_one_dependency(mingw_lib wininet)
        _juce_module_add_one_dependency(mingw_lib version)
        _juce_module_add_one_dependency(mingw_lib ole32)
        _juce_module_add_one_dependency(mingw_lib ws2_32)
        _juce_module_add_one_dependency(mingw_lib oleaut32)
        _juce_module_add_one_dependency(mingw_lib imm32)
        _juce_module_add_one_dependency(mingw_lib comdlg32)
        _juce_module_add_one_dependency(mingw_lib shlwapi)
        _juce_module_add_one_dependency(mingw_lib rpcrt4)
        _juce_module_add_one_dependency(mingw_lib winmm)

    elseif(${_module} STREQUAL "events")

        _juce_module_add_one_dependency(module core)

    elseif(${_module} STREQUAL "graphics")

        _juce_module_add_one_dependency(module events)

        _juce_module_add_one_dependency(macos_framework Cocoa)
        _juce_module_add_one_dependency(macos_framework QuartzCore)

        _juce_module_add_one_dependency(linux_lib x11)
        _juce_module_add_one_dependency(linux_lib xinerama)
        _juce_module_add_one_dependency(linux_lib xext)
        _juce_module_add_one_dependency(linux_lib freetype2)

    elseif(${_module} STREQUAL "analytics")

        _juce_module_add_one_dependency(module gui_basics)

    elseif(${_module} STREQUAL "audio_basics")

        _juce_module_add_one_dependency(module core)

        _juce_module_add_one_dependency(macos_framework Accelerate)

    elseif(${_module} STREQUAL "audio_devices")

        _juce_module_add_one_dependency(module audio_basics)
        _juce_module_add_one_dependency(module events)

        _juce_module_add_one_dependency(macos_framework CoreAudio)
        _juce_module_add_one_dependency(macos_framework CoreMIDI)
        _juce_module_add_one_dependency(macos_framework AudioToolbox)

    elseif(${_module} STREQUAL "audio_formats")

        _juce_module_add_one_dependency(module audio_basics)

        _juce_module_add_one_dependency(macos_framework CoreAudio)
        _juce_module_add_one_dependency(macos_framework CoreMIDI)
        _juce_module_add_one_dependency(macos_framework AudioToolbox)
        _juce_module_add_one_dependency(macos_framework QuartzCore)

    elseif(${_module} STREQUAL "audio_plugin_client")

        _juce_module_add_one_dependency(module gui_basics)
        _juce_module_add_one_dependency(module audio_basics)
        _juce_module_add_one_dependency(module audio_processors)

    elseif(${_module} STREQUAL "audio_processors")

        _juce_module_add_one_dependency(module gui_extra)
        _juce_module_add_one_dependency(module audio_basics)

        _juce_module_add_one_dependency(macos_framework CoreAudio)
        _juce_module_add_one_dependency(macos_framework CoreMIDI)
        _juce_module_add_one_dependency(macos_framework AudioToolbox)

    elseif(${_module} STREQUAL "audio_utils")

        _juce_module_add_one_dependency(module gui_extra)
        _juce_module_add_one_dependency(module audio_processors)
        _juce_module_add_one_dependency(module audio_formats)
        _juce_module_add_one_dependency(module juce_audio_devices)

        _juce_module_add_one_dependency(macos_framework CoreAudioKit)
        _juce_module_add_one_dependency(macos_framework DiscRecording)

    elseif(${_module} STREQUAL "blocks_basics")

        _juce_module_add_one_dependency(module events)
        _juce_module_add_one_dependency(module audio_devices)

    elseif(${_module} STREQUAL "box2d")

        _juce_module_add_one_dependency(module graphics)

    elseif(${_module} STREQUAL "cryptography")

        _juce_module_add_one_dependency(module core)

    elseif(${_module} STREQUAL "data_structures")

        _juce_module_add_one_dependency(module events)

    elseif(${_module} STREQUAL "dsp")

        _juce_module_add_one_dependency(module audio_basics)
        _juce_module_add_one_dependency(module audio_formats)

        _juce_module_add_one_dependency(macos_framework Accelerate)

    elseif(${_module} STREQUAL "gui_basics")

        _juce_module_add_one_dependency(module graphics)
        _juce_module_add_one_dependency(module data_structures)

        _juce_module_add_one_dependency(macos_framework Cocoa)
        _juce_module_add_one_dependency(macos_framework Carbon)
        _juce_module_add_one_dependency(macos_framework QuartzCore)

        _juce_module_add_one_dependency(linux_lib x11)
        _juce_module_add_one_dependency(linux_lib xinerama)
        _juce_module_add_one_dependency(linux_lib xext)

    elseif(${_module} STREQUAL "gui_extra")

        _juce_module_add_one_dependency(module gui_basics)

        _juce_module_add_one_dependency(macos_framework WebKit)

    elseif(${_module} STREQUAL "opengl")

        _juce_module_add_one_dependency(module gui_extra)

        _juce_module_add_one_dependency(macos_framework OpenGL)

        _juce_module_add_one_dependency(linux_lib GL)

        _juce_module_add_one_dependency(mingw_lib opengl32)

    elseif(${_module} STREQUAL "osc")

        _juce_module_add_one_dependency(module core)
        _juce_module_add_one_dependency(module events)

    elseif(${_module} STREQUAL "product_unlocking")

        _juce_module_add_one_dependency(module cryptography)
        _juce_module_add_one_dependency(module core)
        _juce_module_add_one_dependency(module events)

    elseif(${_module} STREQUAL "video")

        _juce_module_add_one_dependency(module gui_extra)

        _juce_module_add_one_dependency(macos_framework AVKit)
        _juce_module_add_one_dependency(macos_framework AVFoundation)
        _juce_module_add_one_dependency(macos_framework CoreMedia)

    endif()

    if(__MODULES_VAR)
        list(APPEND ${__MODULES_VAR} ${_modules})
        set(${__MODULES_VAR} "${${__MODULES_VAR}}" PARENT_SCOPE)
    endif()

    if(__LINUX_LIBS_VAR)
        list(APPEND ${__LINUX_LIBS_VAR} ${_linux_libs})
        set(${__LINUX_LIBS_VAR} "${${__LINUX_LIBS_VAR}}" PARENT_SCOPE)
    endif()

    if(__MACOS_FRAMEWORKS_VAR)
        list(APPEND ${__MACOS_FRAMEWORKS_VAR} ${_macos_frameworks})
        set(${__MACOS_FRAMEWORKS_VAR} "${${__MACOS_FRAMEWORKS_VAR}}" PARENT_SCOPE)
    endif()

    if(__MINGW_LIBS_VAR)
        list(APPEND ${__MINGW_LIBS_VAR} ${_mingw_libs})
        set(${__MINGW_LIBS_VAR} "${${__MINGW_LIBS_VAR}}" PARENT_SCOPE)
    endif()

endfunction()

function(juce_resolve_modules_recurse 
            _current_module 
            _module_list 
            _ext_dependencies_list)

    get_property(__recursion_depth GLOBAL PROPERTY _juce_deps_recursion_depth)

    set(__i 0)

    while(__i LESS ${__recursion_depth})
        string(APPEND _rec_msg_prefix "--")
        math(EXPR __i "${__i} + 1")
    endwhile()

    if(APPLE)
        juce_get_module_dependencies(${_current_module} 
                MODULES_VAR _rec_temp_modules
                MACOS_FRAMEWORKS_VAR _temp_externals)
    elseif(MINGW)
        juce_get_module_dependencies(${_current_module} 
                MODULES_VAR _rec_temp_modules
                MINGW_LIBS_VAR _temp_externals)
    elseif(MINGW)
        juce_get_module_dependencies(${_current_module} 
                MODULES_VAR _rec_temp_modules
                MINGW_LIBS_VAR _temp_externals)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        juce_get_module_dependencies(${_current_module} 
                MODULES_VAR _rec_temp_modules
                LINUX_LIBS_VAR _temp_externals)
    elseif(MSVC)
        juce_get_module_dependencies(${_current_module} 
                MODULES_VAR _rec_temp_modules)
    else()
        message(FATAL_ERROR "Unknown build system ${CMAKE_SYSTEM_NAME}")
    endif()

    list(REMOVE_DUPLICATES _rec_temp_modules)
    
    message("${_rec_msg_prefix} ${_current_module}")

    unset(_rec_msg_prefix)

    list(LENGTH _rec_temp_modules _rec_temp_modules_len)

    math(EXPR __recursion_depth "${__recursion_depth} + 1")
    set_property(GLOBAL PROPERTY _juce_deps_recursion_depth ${__recursion_depth})
    unset(__recursion_depth)

    foreach(_iter_module ${_rec_temp_modules})

        # !!!!! important / we would recurse forever if we would not remove the current module from the list
        list(REMOVE_ITEM _rec_temp_modules ${_iter_module})

        juce_resolve_modules_recurse(
            ${_iter_module}
            ${_module_list}
            ${_ext_dependencies_list}
            ${_new_recursion_depth})

    endforeach()

    list(APPEND ${_module_list} ${_current_module})
    list(APPEND ${_ext_dependencies_list} ${_temp_externals})
    list(REMOVE_DUPLICATES ${_ext_dependencies_list})
    list(REMOVE_DUPLICATES ${_module_list})

    set(${_module_list} "${${_module_list}}" PARENT_SCOPE)
    set(${_ext_dependencies_list} "${${_ext_dependencies_list}}" PARENT_SCOPE)

    get_property(__recursion_depth GLOBAL PROPERTY _juce_deps_recursion_depth)
    
    math(EXPR __recursion_depth "${__recursion_depth} - 1")

    set_property(GLOBAL PROPERTY _juce_deps_recursion_depth ${__recursion_depth})
    unset(__recursion_depth)

endfunction()

function(juce_resolve_modules _modules_to_resolve _output_prefix)

    foreach(_module_to_resolve "${_modules_to_resolve}")

        set_property(GLOBAL PROPERTY _juce_deps_recursion_depth 0)

        message("Resolving dependencies for ${_module_to_resolve}")

        set(output_module_deps_var "${_output_prefix}_${_module_to_resolve}_dependencies")
        set(output_external_deps_var "${_output_prefix}_${_module_to_resolve}_external_dependencies")

        juce_resolve_modules_recurse(${_module_to_resolve} ${output_module_deps_var} ${output_external_deps_var} 0)

        list(REMOVE_ITEM ${output_module_deps_var} ${_module_to_resolve})

        set(${output_module_deps_var} "${${output_module_deps_var}}" PARENT_SCOPE)
        set(${output_external_deps_var} "${${output_external_deps_var}}" PARENT_SCOPE)

        message(STATUS "Defined ${output_module_deps_var} as ${${output_module_deps_var}}")
        message(STATUS "Defined ${output_external_deps_var} as ${${output_external_deps_var}}")

        set_property(GLOBAL PROPERTY _juce_deps_recursion_depth 0)

    endforeach()

    message(STATUS "Modules: ${the_modules}")
    message(STATUS "External dependencies: ${the_ext_deps}")

endfunction()
