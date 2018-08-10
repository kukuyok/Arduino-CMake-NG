#=============================================================================#
# Writes the given lines of code belonging to the sketch to the given file path.
#        _sketch_loc - List of lines-of-code belonging to the sketch.
#        _file_path - Full path to the written source file.
#=============================================================================#
function(_write_source_file _sketch_loc _file_path)

    file(WRITE "${_file_path}" "") # Clear previous file's contents
    foreach (loc ${_sketch_loc})
        string(REGEX REPLACE "^(.+)${ARDUINO_CMAKE_SEMICOLON_REPLACEMENT}(.*)$" "\\1;\\2"
                original_loc "${loc}")
        file(APPEND "${_file_path}" "${original_loc}")
    endforeach ()

endfunction()

#=============================================================================#
# Finds the best line to insert an '#include' of the platform's main header to.
# The function assumes that the initial state of the given 'active index' is set to the line that
# best fitted the insertion, however, it might need a bit more optimization. Why?
# Because above those lines there might be a comment, or a comment block,
# all of which should be taken into account in order to minimize the effect on code's readability.
#        _sketch_loc - List of lines-of-code belonging to the sketch.
#        _active_index - Index that indicates the best-not-optimized loc to insert header to.
#        _return_var - Name of variable in parent-scope holding the return value.
#        Returns - Best fitted index to insert platform's main header '#include' to.
#=============================================================================#
function(_get_matching_header_insertion_index _sketch_loc _active_index _return_var)

    decrement_integer(_active_index 1)
    list(GET _sketch_loc ${_active_index} previous_loc)

    if ("${previous_loc}" MATCHES "^//") # Simple one-line comment
        set(matching_index ${_active_index})
    elseif ("${previous_loc}" MATCHES "\\*/$") # End of multi-line comment
        foreach (index RANGE ${_active_index} 0)
            list(GET _sketch_loc ${index} multi_comment_line)
            if ("${multi_comment_line}" MATCHES "^\\/\\*") # Start of multi-line comment
                set(matching_index ${index})
                break()
            endif ()
        endforeach ()
    else () # Previous line isn't a comment - Return original index
        increment_integer(_active_index 1)
        set(matching_index ${_active_index})
    endif ()

    set(${_return_var} ${matching_index} PARENT_SCOPE)

endfunction()

#=============================================================================#
# Converts the given sketch file into a valid 'cpp' source file under the project's working dir.
# During the conversion process the platform's main header file is inserted to the source file
# since it's critical for it to include it - Something that doesn't happen in "Standard" sketches.
#        _sketch_file - Full path to the original sketch file (Read from).
#        _target_file - Full path to the converted target source file (Written to).
#=============================================================================#
function(convert_sketch_to_source_file _sketch_file _target_file)

    file(STRINGS "${_sketch_file}" sketch_loc)
    list(LENGTH sketch_loc num_of_loc)
    decrement_integer(num_of_loc 1)

    set(refined_sketch)
    set(header_insert_pattern "#include|^([a-z]|[A-Z])+.*\(([a-z]|[A-Z])*\)")
    set(header_inserted FALSE)

    foreach (loc_index RANGE 0 ${num_of_loc})
        list(GET sketch_loc ${loc_index} loc)
        if (NOT ${header_inserted})
            if ("${loc}" MATCHES "${header_insert_pattern}")
                _get_matching_header_insertion_index("${sketch_loc}" ${loc_index} header_index)
                if (${header_index} GREATER_EQUAL ${loc_index})
                    decrement_integer(header_index 1)
                    set(include_line "\n#include <${ARDUINO_CMAKE_PLATFORM_HEADER_NAME}>")
                else ()
                    set(include_line "#include <${ARDUINO_CMAKE_PLATFORM_HEADER_NAME}>\n\n")
                endif ()
                list(INSERT refined_sketch ${header_index} ${include_line})
                set(header_inserted TRUE)
            endif ()
        endif ()
        if ("${loc}" STREQUAL "")
            list(APPEND refined_sketch "\n")
        else ()
            string(REGEX REPLACE "^(.+);(.*)$" "\\1${ARDUINO_CMAKE_SEMICOLON_REPLACEMENT}\\2"
                    refined_loc "${loc}")
            list(APPEND refined_sketch "${refined_loc}\n")
        endif ()
    endforeach ()

    _write_source_file("${refined_sketch}" "${target_source_path}")

endfunction()

#=============================================================================#
# Converts all the given sketch file into valid 'cpp' source files and returns their paths.
#        _sketch_files - List of paths to original sketch files.
#        _return_var - Name of variable in parent-scope holding the return value.
#        Returns - List of paths representing post-conversion sources.
#=============================================================================#
function(get_sources_from_sketches _sketch_files _return_var)

    set(sources)
    foreach (sketch ${_sketch_files})
        get_filename_component(sketch_file_name "${sketch}" NAME_WE)
        set(target_source_path "${CMAKE_CURRENT_SOURCE_DIR}/${sketch_file_name}.cpp")
        # Only convert sketch if it hasn't been converted yet
        if (NOT EXISTS "${target_source_path}")
            convert_sketch_to_source_file("${sketch}" "${target_source_path}")
        endif ()
        list(APPEND sources "${target_source_path}")
    endforeach ()

    set(${_return_var} ${sources} PARENT_SCOPE)

endfunction()