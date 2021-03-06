#=============================================================================#
# Validates a header file is included by the given target.
# i.e The header is located under one of the target's include directories.
#       _target_name - Name of the target to add the sketch file to.
#       _return_var - Name of variable in parent-scope holding the return value.
#       Returns - True if header is included by the target, false otherwise.
#=============================================================================#
function(_validate_target_includes_header _target_name _header _return_var)

    get_target_property(target_include_dirs ${_target_name} INCLUDE_DIRECTORIES)
    foreach (include_dir ${target_include_dirs})
        find_header_files("${include_dir}" include_dir_headers)
        if (${_header} IN_LIST include_dir_headers) # Header is included in the target
            set(${_return_var} True)
            return()
        endif ()
    endforeach ()

    set(${_return_var} False)

endfunction()

#=============================================================================#
# Resolves the header files included in a sketch by linking their appropriate library if necessary
# or by validating they're included by the sketch target.
#       _target_name - Name of the target to add the sketch file to.
#       _board_id - ID of the board to bind to the target (Each target can have a single board).
#       _sketch_file - Path to a sketch file to add to the target.
#=============================================================================#
function(resolve_sketch_headers _target_name _board_id _sketch_file)

    get_source_file_included_headers("${_sketch_file}" sketch_headers)
    foreach (header ${sketch_headers})
        # Header name without extension (such as '.h') can represent an Arduino/Platform library
        # So first we should check whether it's a library
        get_name_without_file_extension("${header}" header_we)

        is_platform_library(${header_we} is_header_platform_lib)
        if (is_header_platform_lib)
            string(TOLOWER ${header_we} header_we_lower)
            link_platform_library(${_target_name} ${header_we_lower} ${_board_id})
        else ()
            find_arduino_library(${header_we}_sketch_lib ${header_we} ${_board_id})
            # If library isn't found, display a wraning since it might be a user library
            if (NOT TARGET ${header_we}_sketch_lib OR "${${header_we}_sketch_lib}" MATCHES "NOTFOUND")
                _validate_target_includes_header(${_target_name} ${header} is_header_validated)
                if (NOT is_header_validated)
                    # Header hasn't been found in any of the target's include directories, Display warning
                    message(WARNING "The header '${header_we}' is used by the \
                                     '${_sketch_file}' sketch \
                                     but it isn't a Arduino/Platform library, nor it's linked \
                                     to the target manually!")
                endif ()
            else ()
                link_arduino_library(${_target_name} ${header_we}_sketch_lib ${_board_id})
            endif ()
        endif ()
    endforeach ()

endfunction()
