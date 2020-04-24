# -------------------------------------------------------------------------------------------------
# Helpers

function(_ini_fn_is_newline _char _var)
    if((_char EQUAL ${_ini_c_nl}) OR (_char EQUAL ${_ini_c_cr}))
        set(${_var} 1 PARENT_SCOPE)
    else()
        unset(${_var})
    endif()
endfunction()

function(_ini_is_kv_delim _char _var)

    list(FIND _ini_c_kv_delims ${_char} _found)

    if(_found EQUAL "-1")
        return()
    endif()

    set(${_var} 1 PARENT_SCOPE)

endfunction()

function(_ini_hex_arr_to_string _arr _str_out)

    set(_dx_arr "")

    foreach(_el ${_arr})
        math(EXPR _dec "0x${_el}" OUTPUT_FORMAT DECIMAL)
        list(APPEND _dx_arr ${_dec})
    endforeach()
    
    string(ASCII ${_dx_arr} __str)

    set(${_str_out} "${__str}" PARENT_SCOPE)

endfunction()

function(_ini_list_last_element _list _out)

    list(LENGTH ${_list} _len)
    math(EXPR _pos "${_len} - 1")

    list(GET ${_list} ${_pos} _vout)

    set(${_out} ${_vout} PARENT_SCOPE)

endfunction()

function(_ini_list_contains _list _val _out_var)

    list(FIND ${_list} ${_val} _result)

    if(NOT (_result EQUAL "-1"))
        set(${_out_var} ON PARENT_SCOPE)
    else()
        set(${_out_var} OFF PARENT_SCOPE)
    endif()

endfunction()

macro(_ini_mc_propagate_vars)
    set(_current_qs                         ${_current_qs}                          PARENT_SCOPE)
    set(_current_qs_val                     ${_current_qs_val}                      PARENT_SCOPE)
    set(_current_qs_qty                     ${_current_qs_qty}                      PARENT_SCOPE)
    set(_current_key                        ${_current_key}                         PARENT_SCOPE)
    set(_current_value                      ${_current_value}                       PARENT_SCOPE)
    set(_current_section                    ${_current_section}                     PARENT_SCOPE)
    set(_current_identifier                 ${_current_identifier}                  PARENT_SCOPE)
    set(_current_identifier_started_parsing ${_current_identifier_started_parsing}  PARENT_SCOPE)
    set(_sections                           ${_sections}                            PARENT_SCOPE)
    set(_is_parsing_comment                 ${_is_parsing_comment}                  PARENT_SCOPE)
    set(_parser_state                       ${_parser_state}                        PARENT_SCOPE)
    set(_utf8_decoder_fmt                   ${_utf8_decoder_fmt}                    PARENT_SCOPE)
    set(_utf8_decoder_cnt                   ${_utf8_decoder_cnt}                    PARENT_SCOPE)
    set(_utf8_decoder_buf                   ${_utf8_decoder_buf}                    PARENT_SCOPE)
endmacro()

function(_ini_char_is_whitespace _char _out_var)

    string(REGEX MATCH "(09)|(0d)|(0a)|(20)" __did_match ${_char})

    if(__did_match)
        set(${_out_var} True PARENT_SCOPE)
    endif()

endfunction()

function(_ini_get_ascii _char _out_var)

    math(EXPR __dec_val "0x${_char}" OUTPUT_FORMAT DECIMAL)
    string(ASCII ${__dec_val} __out_val)

    set(${_out_var} ${__out_val} PARENT_SCOPE)

endfunction()

function(_ini_char_is_legal_in_identifier _char _out_val)

    _ini_get_ascii(${_char} _ascii_char)

    string(REGEX MATCH "[a-zA-Z0-9_~${}@\t -]" _matches "${_ascii_char}")

    # message(STATUS "${_ascii_char} : ${_matches}")
    
    if(NOT (_matches STREQUAL ""))
        set(${_out_val} 1 PARENT_SCOPE)
    endif()

endfunction()

function(_ini_parser_error _message)
    message(FATAL_ERROR "INI parser failed to parse line ${_line}: ${_message}")
endfunction()

function(_parse_unicode _char _is_uni _done_var _output_var)

    set(_xchar "0x${_char}")

    if(_xchar GREATER 0x7E)
        if(_xchar LESS 0xC0)

            # this is a continuation byte
            math(EXPR _utf8_decoder_cnt "${_utf8_decoder_cnt} + 1")
            list(APPEND _utf8_decoder_buf ${_char})

        elseif((_xchar GREATER 0xC1) AND (_xchar LESS 0xE0))

            # this is the first byte of a two byte sequence
            set(_utf8_decoder_fmt 2)
            list(APPEND _utf8_decoder_buf ${_char}) 
            set(_utf8_decoder_cnt 2)

        elseif((_xchar GREATER 0xDF) AND (_xchar LESS 0xF0))

            # this is the first byte of a three byte sequence
            set(_utf8_decoder_fmt 3)
            list(APPEND _utf8_decoder_buf ${_char}) 
            set(_utf8_decoder_cnt 2)

        elseif(_xchar GREATER 0xE9)

            # this is the first byte of a four byte sequence
            set(_utf8_decoder_fmt 4)
            list(APPEND _utf8_decoder_buf ${_char}) 
            set(_utf8_decoder_cnt 2)

        else()
            message(FATAL_ERROR "This really should not happen")
        endif()

        set(${_is_uni} 1 PARENT_SCOPE)
        
    endif()

    if(${_utf8_decoder_cnt} GREATER ${_utf8_decoder_fmt})

        set(${_output_var} "${_utf8_decoder_buf}" PARENT_SCOPE)

        unset(_utf8_decoder_cnt)
        unset(_utf8_decoder_buf)
        unset(_utf8_decoder_fmt)

        set(${_done_var} 1 PARENT_SCOPE)

    endif()
    
    _ini_mc_propagate_vars()

endfunction()

function(_ini_reset_unicode_parser)

    unset(_utf8_decoder_cnt)
    unset(_utf8_decoder_buf)
    unset(_utf8_decoder_fmt)

    _ini_mc_propagate_vars()

endfunction()

function(_ini_make_sect_keys_var _section_name _out_var)
    set(${_out_var} "_ini_zz_keys_${_section_name}" PARENT_SCOPE)
endfunction()

function(_ini_make_key_var _section_name _key_name _out_var)
    set(${_out_var} "_ini_zz_val_${_section_name}_${_key_name}" PARENT_SCOPE)
endfunction()

function(_ini_get_cached_keys_var_name _section _out_var)
    set(${_out_var} "_ini_zz_do_cache_${_section}_keys" PARENT_SCOPE)
endfunction()
# -------------------------------------------------------------------------------------------------

# parser functions

macro(_ini_autoparse_comment _char)

    if(_is_parsing_comment EQUAL 1)

        # message(STATUS "Parsing comment ${_line}")
        _ini_fn_is_newline(${_char} _is_nl)

        if(_is_nl)
            # message(STATUS "Stop parsing comments")
            set(_is_parsing_comment 0)
            _ini_mc_propagate_vars()
        else()
            _ini_mc_propagate_vars()
            return()
        endif()
    else()
    
        list(FIND _ini_c_comments ${_char} _cm_found)

        if(NOT ("${_cm_found}" STREQUAL "-1"))
            # message(STATUS "Start parsing comment ${_cm_found}")
            set(_is_parsing_comment 1)

            _ini_mc_propagate_vars()
            return()
        endif()
    endif()
endmacro()

function(_ini_parse_identifier _char _is_done)

    _ini_char_is_legal_in_identifier(${_char} _is_legal)

    # message(STATUS "${_char} is legal ${_is_legal}")

    if(_is_legal)
        list(APPEND _current_identifier ${_char})
    else()
        _ini_parser_error("Illegal character in identifier")
    endif()

    _ini_mc_propagate_vars()

endfunction()   

function(_ini_save_identifier _out_var)

    _ini_hex_arr_to_string("${_current_identifier}" _str)

    # message(STATUS "Saved identifier ${_str}")

    string(STRIP "${_str}" _str)
    string(MAKE_C_IDENTIFIER ${_str} _str)

    set(${_out_var} "${_str}")

    unset(_current_identifier)

    _ini_mc_propagate_vars()
endfunction()

function(_ini_err_on_unicode _char _expected)

    _parse_unicode(${_char} _is_uni _ _)
    _ini_reset_unicode_parser()

    if(_is_uni)
        _ini_parser_error("Unexpected unicode character, ${_expected}")
    endif()

endfunction()

function(_ini_parser_find_section _char)

    _ini_autoparse_comment(${_char})
    _ini_err_on_unicode(${_char} "expected section start ([)")

    _ini_char_is_whitespace(${_char} _is_whitespace)

    if(_is_whitespace)
        return()
    elseif(_char STREQUAL ${_ini_c_sect_begin})
        set(_parser_state ${_ini_pss_section})
    else()
        _ini_get_ascii(${_char} __achar)
        _ini_parser_error("Unexpected character ${__achar}, expected section start ([)") 
    endif()
        
    _ini_mc_propagate_vars()
endfunction()

function(_ini_parse_section _char)

    _ini_autoparse_comment(${_char})
    _ini_err_on_unicode(${_char} "section labels must not contain unicode characters")

    if(_char STREQUAL ${_ini_c_sect_end})

        _ini_save_identifier(_current_section)

        # message(STATUS "Append section ${_str}")

        list(APPEND _sections ${_current_section})
        set(_parser_state ${_ini_pss_k_or_s})
    else()
        _ini_parse_identifier(${_char} _is_done)
    endif()

    _ini_mc_propagate_vars()

endfunction()

function(_ini_parse_key_or_section _char)

    _ini_autoparse_comment(${_char})
    _ini_err_on_unicode(${_char} "identifiers must not contain unicode characters")

    _ini_char_is_whitespace(${_char} _is_whitespace)

    if(NOT _is_whitespace)

        if(_char STREQUAL ${_ini_c_sect_begin})

            set(_parser_state ${_ini_pss_section})

        else()
            set(_parser_state ${_ini_pss_key})
            _ini_parse_key(${_char})
        endif()

    endif()

    _ini_mc_propagate_vars()

endfunction()

function(_ini_parse_key _char)

    _ini_autoparse_comment(${_char})
    _ini_err_on_unicode(${_char} "identifiers must not contain unicode characters")

    _ini_is_kv_delim(${_char} _is_kv_delim)

    if(NOT _is_kv_delim)
        _ini_parse_identifier(${_char} _is_done)
    else()
        _ini_save_identifier(_current_key)

        set(_parser_state ${_ini_pss_section})

        _ini_list_last_element(_sections _sect)

        # message(STATUS "Append key ${_sect}::${_current_key}")

        _ini_make_sect_keys_var(${_current_section} _sect_key_list_var)

        list(APPEND ${_sect_key_list_var} ${_current_key})

        set(${_sect_key_list_var} ${${_sect_key_list_var}} PARENT_SCOPE)
        set(_parser_state ${_ini_pss_value})

    endif()

    _ini_mc_propagate_vars()

endfunction()

function(_ini_parse_value _char)

    _ini_autoparse_comment(${_char})
    _ini_fn_is_newline(${_char} _is_newline)

    list(APPEND _current_value ${_char})

    if(_is_newline)

        _ini_make_key_var(${_current_section} ${_current_key} _value_var)
        # message(STATUS ${_value_var})
        set(${_value_var} ${_current_value} PARENT_SCOPE)
        set(_parser_state ${_ini_pss_k_or_s})
        unset(_current_value)
    endif()

    _ini_mc_propagate_vars()

endfunction()

# -------------------------------------------------------------------------------------------------

# Public API begins here

function(ini_get_key_list_var _prefix _section_name _out_var)
    set(${_out_var} "${_prefix}_${_section_name}_KEYS" PARENT_SCOPE)
endfunction()

function(ini_get_key_list _prefix _section_name _out_var)

    ini_get_key_list_var(${_prefix} ${_section_name} _klist)

    set(${_out_var} ${${_klist}} PARENT_SCOPE)
    
endfunction()

function(ini_get_value_var _prefix _section _key _out_var)
    set(${_out_var} "${_prefix}_${_section}_${_key}" PARENT_SCOPE)
endfunction()

function(ini_get_value _prefix _section _key _out_var)
    
    ini_get_value_var(${_prefix} ${_section} ${_key} _val)

    set(${_out_var} ${{_val}} PARENT_SCOPE)

endfunction()

function(parse_ini_file)

    set(parse_ini_file_options 
        NO_COLON_KV_DELIM 
        NO_HASHSIGN_COMMENTS 
        STRIP_VALUES
        NO_CACHE
        NO_CACHE_CHECK)

    set(parse_ini_multival_keywords
        CACHE_SECTIONS
        CACHE_KEYS)

    cmake_parse_arguments(PARSE_ARGV 2 INI 
        "${parse_ini_file_options}" ";" 
        "${parse_ini_multival_keywords}")

    message(STATUS "Parsing INI file ${ARGV0}")

    set(__FILE      ${ARGV0})
    set(__PREFIX    ${ARGV1})
    
    set(_ini_pss_find_sect      fs)
    set(_ini_pss_section        s) 
    set(_ini_pss_k_or_s         i)
    set(_ini_pss_key            k)
    set(_ini_pss_value          v)
    set(_ini_pss_qs             qs)

    set(_ini_c_kv_delims        "3d")       # =
    set(_ini_c_sect_begin       "5b")       # [
    set(_ini_c_sect_end         "5d")       # ]
    set(_ini_c_comments         "3b")       # ;
    set(_ini_c_quotations       "22" "27")  # "/'

    set(_ini_c_nl               "0a")       # NL
    set(_ini_c_cr               "0d")       # CR

    if(NOT (INI_NO_COLON_KV_DELIM))
        list(APPEND _ini_c_kv_delims "3a")  # :
    endif()

    if(NOT INI_NO_HASHSIGN_COMMENTS)
        list(APPEND _ini_c_comments "23")   # #
    endif()

    # read all characters from file into a list of characters
    file(READ ${__FILE} __hex_chars HEX)
    string(LENGTH "${__hex_chars}" __hex_chars_len)

    set(_pos 0)
    while(${_pos} LESS ${__hex_chars_len})

        string(SUBSTRING ${__hex_chars} ${_pos} 2 __char)
        math(EXPR _pos "${_pos} + 2")

        math(EXPR __char_code_dec "0x${__char}" OUTPUT_FORMAT DECIMAL)

        list(APPEND __chars "${__char}")
    
    endwhile()
    
    set(_parser_state ${_ini_pss_find_sect})

    set(_current_value)
    set(_current_section)
    set(_sections)
    set(_line 1)

    foreach(_char_iter ${__chars})

        if(${_parser_state} STREQUAL ${_ini_pss_find_sect})
            _ini_parser_find_section(${_char_iter})
        elseif(${_parser_state} STREQUAL ${_ini_pss_section})
            _ini_parse_section(${_char_iter})
        elseif(${_parser_state} STREQUAL ${_ini_pss_k_or_s})
            _ini_parse_key_or_section(${_char_iter})
        elseif(${_parser_state} STREQUAL ${_ini_pss_key})
            _ini_parse_key(${_char_iter})
        elseif(${_parser_state} STREQUAL ${_ini_pss_value})
            _ini_parse_value(${_char_iter})
        elseif(${_parser_state} STREQUAL ${_ini_pss_qs})

        endif()

        # count newlines for error messages
        _ini_fn_is_newline(${_char_iter} _is_nl)

        if(_is_nl)
            math(EXPR _line "${_line} + 1")
        endif()

        unset(_is_nl)

    endforeach()

    set("${__PREFIX}_SECTIONS" ${_sections} PARENT_SCOPE)

    foreach(_sect_key_pair_str ${INI_CACHE_KEYS})
        
        string(REPLACE "::" ";" _sect_key_pair ${_sect_key_pair_str})
        message(STATUS "${_sect_key_pair}")

        list(LENGTH _sect_key_pair _sect_key_pair_length)

        if(NOT (_sect_key_pair_length EQUAL 2))
            message(FATAL_ERROR 
                "Invalid argument ${_sect_key_pair_str}. Section and key must be separated by \"::\"")
        endif()

        list(GET _sect_key_pair 0 __sect)
        list(GET _sect_key_pair 1 __key)

        _ini_get_cached_keys_var_name(${__sect} _cached_keys_list_var)

        message(STATUS "Cache to: ${_cached_keys_list_var}")

        list(APPEND ${_cached_keys_list_var} ${__key})
        
    endforeach()
    

    foreach(_section ${_sections})

        _ini_make_sect_keys_var(${_section} _int_key_list_var)
        ini_get_key_list_var(${__PREFIX} ${_section} _pub_key_list_var)

        set(${_pub_key_list_var} ${${_int_key_list_var}} PARENT_SCOPE)

        # should we cache this section?
        _ini_list_contains(INI_CACHE_SECTIONS ${_section} _cache_this_section)

        message(STATUS "Cache section [${_section}] : ${_cache_this_section}")

        foreach(_key ${${_int_key_list_var}})

            ini_get_value_var(${__PREFIX} ${_section} ${_key} _pub_value_var)
            _ini_make_key_var(${_section} ${_key} _var)

            _ini_hex_arr_to_string("${${_var}}" _out_str)

            if(NOT _cache_this_section)
                _ini_get_cached_keys_var_name(${_section} _cached_keys_list_var)
                _ini_list_contains(${_cached_keys_list_var} ${_key} _cache_this_key)
            else()
                set(_cache_this_key ON)
            endif()

            message(STATUS "Cache key [${_key}] ${_cache_this_key}")

            if(INI_STRIP_VALUES)
                string(STRIP "${_out_str}" _out_str)
            endif()

            if(_cache_this_key)
                set(${_pub_value_var} "${_out_str}" CACHE "Cached from ini file ${__FILE}" INTERNAL)
            else()
                set(${_pub_value_var} "${_out_str}" PARENT_SCOPE)
            endif()

        endforeach()

    endforeach()

    message(STATUS "Done")

endfunction()