function(_find_platform_cores)

    file(GLOB sub-dir ${PLATFORM_CORES_PATH}/*)
    foreach (dir ${sub-dir})
        if (IS_DIRECTORY ${dir})
            get_filename_component(core ${dir} NAME)
            string(TOUPPER ${core} CORE)
            set(CORE_${CORE}_PATH "${dir}" CACHE INTERNAL "Path to ${core} core")
        endif ()
    endforeach ()

endfunction()

function(_find_platform_variants)

    file(GLOB sub-dir ${PLATFORM_VARIANTS_PATH}/*)
    foreach (dir ${sub-dir})
        if (IS_DIRECTORY ${dir})
            get_filename_component(variant ${dir} NAME)
            string(TOUPPER ${variant} VARIANT)
            set(VARIANT_${VARIANT}_PATH ${dir} CACHE INTERNAL "Path to ${variant} variant")
        endif ()
    endforeach ()

endfunction()

find_file(PLATFORM_CORES_PATH
        NAMES cores
        PATHS ${ARDUINO_CMAKE_PLATFORM_PATH}
        DOC "Path to directory containing the Platform's core sources"
        NO_CMAKE_FIND_ROOT_PATH)
_find_platform_cores()

find_file(PLATFORM_VARIANTS_PATH
        NAMES variants
        PATHS ${ARDUINO_CMAKE_PLATFORM_PATH}
        DOC "Path to directory containing the Platform's variant sources"
        NO_CMAKE_FIND_ROOT_PATH)
_find_platform_variants()

find_file(PLATFORM_BOOTLOADERS_PATH
        NAMES bootloaders
        PATHS ${ARDUINO_CMAKE_PLATFORM_PATH}
        DOC "Path to directory containing the Platform's bootloader images and sources"
        NO_CMAKE_FIND_ROOT_PATH)

find_file(PLATFORM_PROGRAMMERS_PATH
        NAMES programmers.txt
        PATHS ${ARDUINO_CMAKE_PLATFORM_PATH}
        DOC "Path to Platform's programmers definition file"
        NO_CMAKE_FIND_ROOT_PATH)

find_file(PLATFORM_BOARDS_PATH
        NAMES boards.txt
        PATHS ${ARDUINO_CMAKE_PLATFORM_PATH}
        DOC "Path to Platform's boards definition file"
        NO_CMAKE_FIND_ROOT_PATH)

find_file(PLATFORM_PROPERTIES_FILE_PATH
        NAMES platform.txt
        PATHS ${ARDUINO_CMAKE_PLATFORM_PATH}
        DOC "Path to Platform's properties file"
        NO_CMAKE_FIND_ROOT_PATH)

find_file(PLATFORM_LIBRARIES_PATH
        NAMES libraries
        PATHS ${ARDUINO_CMAKE_PLATFORM_PATH}
        DOC "Path to platform directory containing the Arduino libraries"
        NO_CMAKE_FIND_ROOT_PATH)