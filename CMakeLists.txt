cmake_minimum_required(VERSION 3.4)

project(JUCE)

set(juce_root                       "${CMAKE_CURRENT_LIST_DIR}/JUCE") 

set(juce_install_dir                "lib")
set(juce_package_dir                "${juce_install_dir}/juce-${JUCE_VERSION_STRING}")

set(juce_modules_dir                "${juce_root}/modules")   
set(juce_resources_dir              "${CMAKE_CURRENT_LIST_DIR}/resources")
set(juce_templates_dir              "${CMAKE_CURRENT_LIST_DIR}/templates")
set(juce_cmake_scripts_dir          "${CMAKE_CURRENT_LIST_DIR}/cmake")

set(juce_installed_package_dir      "${CMAKE_INSTALL_PREFIX}/${juce_package_dir}")

set(juce_installed_juce_files_dir   "${juce_installed_package_dir}/JUCE")

set(juce_install_misc_files         "${juce_root}/README.md" 
                                    "${juce_root}/LICENSE.md"
                                    "${juce_root}/BREAKING-CHANGES.txt"
                                    "${juce_root}/ChangeList.txt")

set(juce_installed_juce_root        "${juce_installed_juce_files_dir}")
set(juce_installed_modules_dir      "${juce_installed_juce_files_dir}/modules")
set(juce_installed_scripts_dir      "${juce_installed_package_dir}/cmake")
set(juce_installed_templates_dir    "${juce_installed_package_dir}/templates")
set(juce_installed_resources_dir    "${juce_installed_package_dir}/resources")

set(juce_modules_list_file          "${juce_resources_dir}/modules.txt")
set(juce_library_code_dir           "${CMAKE_CURRENT_BINARY_DIR}/JuceLibraryCode")

set(juce_main_target                "headers")
set(juce_main_target_export         "juce_main_target_export")

list(APPEND CMAKE_MODULE_PATH       "${juce_cmake_scripts_dir}")

include(GitUtils)
include(JuceModuleBuilder)
include(JuceDependencies)
include(CMakePackageConfigHelpers)
include(INIFileParser)

set(juce_namespace                  "JUCE::")
set(juce_main_target                "JUCE")
set(juce_module_target_prefix       "JUCE_")

set(juce_version_file               "${CMAKE_CURRENT_BINARY_DIR}/JUCE-config-version.cmake")
set(juce_config_file_template       "${juce_templates_dir}/JUCE-config.cmake.in")
set(juce_config_file                "${CMAKE_CURRENT_BINARY_DIR}/JUCE-config.cmake")

git_get_full_version_details(${juce_root} JUCE)
git_get_full_version_details(${CMAKE_CURRENT_LIST_DIR} JUCE_CMAKE_PACKAGE)

set(JUCE_CMAKE_PACKAGE_VERSION 0.0.0)

# -------------------------------------------------------------------------------------------------

# setup module selection

if(NOT juce_include)

    file(READ ${juce_modules_list_file} juce_all_modules)
    string(REPLACE "\n" ";" juce_all_modules ${juce_all_modules})

    message(STATUS "Including default modules")

    string(REPLACE ";" " " _temp_juce_all_modules "${juce_all_modules}")
    set(juce_include ${_temp_juce_all_modules})

endif()

if(NOT juce_exclude)
    set(juce_exclude "")
endif()

# cache (recache) module selection

string(REPLACE " " ";" juce_include "${juce_include}")
set(juce_include ${juce_include} CACHE STRING "Include these JUCE modules" FORCE)

string(REPLACE " " ";" juce_exclude "${juce_exclude}")
set(juce_exclude ${juce_exclude} CACHE STRING "Exclude these JUCE modules" FORCE)

# -------------------------------------------------------------------------------------------------

configure_file(${juce_config_file_template} ${juce_config_file} @ONLY)

install(FILES ${juce_config_file} DESTINATION ${juce_package_dir})

# -------------------------------------------------------------------------------------------------

# create and install a version file

write_basic_package_version_file(
		${juce_version_file} 
		VERSION ${JUCE_CMAKE_PACKAGE_VERSION} 
		COMPATIBILITY SameMinorVersion
)

install(
		FILES ${juce_version_file} 
		DESTINATION ${juce_package_dir}
)

# -------------------------------------------------------------------------------------------------

install(DIRECTORY ${juce_templates_dir} DESTINATION ${juce_package_dir})
install(DIRECTORY ${juce_resources_dir} DESTINATION ${juce_package_dir})
install(DIRECTORY ${juce_cmake_scripts_dir} DESTINATION ${juce_package_dir})

# -------------------------------------------------------------------------------------------------

add_library(${juce_main_target} INTERFACE)

target_compile_features(${juce_main_target} INTERFACE cxx_std_14)

target_include_directories(
    ${juce_main_target}
    INTERFACE
    $<BUILD_INTERFACE:${juce_modules_dir}>
    $<INSTALL_INTERFACE:${juce_installed_modules_dir}>
)

install(
    TARGETS ${juce_main_target} 
    EXPORT ${juce_main_target_export} 
    DESTINATION ${juce_package_dir}
)

install(
    EXPORT ${juce_main_target_export} 
    NAMESPACE ${juce_namespace} 
    DESTINATION ${juce_package_dir}
)

# -------------------------------------------------------------------------------------------------

# install JUCE and other files

install(DIRECTORY ${juce_modules_dir}
        DESTINATION ${juce_installed_juce_files_dir})

install(FILES ${juce_install_misc_files} DESTINATION ${juce_installed_juce_files_dir})

parse_ini_file("${CMAKE_CURRENT_LIST_DIR}/test.ini" Test
    STRIP_VALUES
    CACHE_SECTIONS
        graphics)