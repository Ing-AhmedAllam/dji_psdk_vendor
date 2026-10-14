if(NOT TARGET payloadsdk)
    get_filename_component(
        _psdk_prefix
        "${CMAKE_CURRENT_LIST_DIR}/../../.."
        ABSOLUTE
    )

    set(_psdk_library
        "${_psdk_prefix}/lib/libpayloadsdk.a"
    )

    if(NOT EXISTS "${_psdk_library}")
        message(FATAL_ERROR
            "DJI Payload SDK library not found: ${_psdk_library}"
        )
    endif()

    add_library(payloadsdk STATIC IMPORTED)

    set_target_properties(payloadsdk PROPERTIES
        IMPORTED_LOCATION "${_psdk_library}"
    )
endif()