############################################################################
# CMakeLists.txt
# Copyright (C) 2014  Belledonne Communications, Grenoble France
#
############################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
############################################################################

include(ExternalProject)

set(ep_base "${LINPHONE_BUILDER_WORK_DIR}/${CONFIG_NAME}")
set_property(DIRECTORY PROPERTY EP_BASE ${ep_base})


# Define the architecture. It will be used to generate the URL to get prebuilt dependencies.
if(WIN32)
	set(LINPHONE_BUILDER_ARCHITECTURE "Win32")
elseif(UNIX)
	if(APPLE)
		set(LINPHONE_BUILDER_ARCHITECTURE "OsX64")
	endif()
endif()


if(CMAKE_VERBOSE_MAKEFILE)
	set(AUTOTOOLS_VERBOSE_MAKEFILE 1)
else()
	set(AUTOTOOLS_VERBOSE_MAKEFILE 0)
endif()


# Check for build tools and show an error if one of them is not present
include(cmake/CheckBuildTools.cmake)


set(LINPHONE_BUILDER_EP_VARS)
set(LINPHONE_BUILDER_INCLUDED_BUILDERS)

macro(linphone_builder_expand_external_project_vars)
	set(LINPHONE_BUILDER_EP_ARGS "")
	set(LINPHONE_BUILDER_EP_VARNAMES "")
	foreach(arg ${LINPHONE_BUILDER_EP_VARS})
		string(REPLACE ":" ";" varname_and_vartype ${arg})
		set(target_info_list ${target_info_list})
		list(GET varname_and_vartype 0 _varname)
		list(GET varname_and_vartype 1 _vartype)
		list(APPEND LINPHONE_BUILDER_EP_ARGS -D${_varname}:${_vartype}=${${_varname}})
		list(APPEND LINPHONE_BUILDER_EP_VARNAMES ${_varname})
	endforeach()
endmacro()

list(APPEND LINPHONE_BUILDER_EP_VARS
	CMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH
	CMAKE_BUILD_TYPE:STRING
	CMAKE_BUILD_WITH_INSTALL_RPATH:BOOL
	CMAKE_BUNDLE_OUTPUT_DIRECTORY:PATH
	CMAKE_C_FLAGS_DEBUG:STRING
	CMAKE_C_FLAGS_MINSIZEREL:STRING
	CMAKE_C_FLAGS_RELEASE:STRING
	CMAKE_C_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_C_FLAGS:STRING
	CMAKE_CXX_FLAGS_DEBUG:STRING
	CMAKE_CXX_FLAGS_MINSIZEREL:STRING
	CMAKE_CXX_FLAGS_RELEASE:STRING
	CMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_CXX_FLAGS:STRING
	CMAKE_EXE_LINKER_FLAGS_DEBUG:STRING
	CMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING
	CMAKE_EXE_LINKER_FLAGS_RELEASE:STRING
	CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_EXE_LINKER_FLAGS:STRING
	CMAKE_EXTRA_GENERATOR:STRING
	CMAKE_GENERATOR_PLATFORM:STRING
	CMAKE_INSTALL_PREFIX:PATH
	CMAKE_INSTALL_RPATH:PATH
	CMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL
	CMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH
	CMAKE_MODULE_LINKER_FLAGS_DEBUG:STRING
	CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL:STRING
	CMAKE_MODULE_LINKER_FLAGS_RELEASE:STRING
	CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_MODULE_LINKER_FLAGS:STRING
	CMAKE_MODULE_PATH:PATH
	CMAKE_NO_BUILD_TYPE:BOOL
	CMAKE_PREFIX_PATH:STRING
	CMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH
	CMAKE_SHARED_LINKER_FLAGS_DEBUG:STRING
	CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL:STRING
	CMAKE_SHARED_LINKER_FLAGS_RELEASE:STRING
	CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO:STRING
	CMAKE_SHARED_LINKER_FLAGS:STRING
	CMAKE_SKIP_RPATH:BOOL
	CMAKE_SKIP_BUILD_RPATH:BOOL
	CMAKE_VERBOSE_MAKEFILE:BOOL
	MSVC_C_ARCHITECTURE_ID:STRING
	MSVC_CXX_ARCHITECTURE_ID:STRING
	MSVC_VERSION:STRING
)
if(CMAKE_CROSSCOMPILING)
	list(APPEND LINPHONE_BUILDER_EP_VARS
		CMAKE_SYSTEM_NAME:STRING
		CMAKE_SYSTEM_VERSION:STRING
	)
endif()
if(APPLE)
	list(APPEND LINPHONE_BUILDER_EP_VARS
		CMAKE_MACOSX_RPATH:BOOL
		CMAKE_OSX_ARCHITECTURES:STRING
		CMAKE_OSX_DEPLOYMENT_TARGET:STRING
	)
endif()
if(CMAKE_TOOLCHAIN_FILE)
	list(APPEND LINPHONE_BUILDER_EP_VARS CMAKE_TOOLCHAIN_FILE:PATH)
endif()


function(linphone_builder_get_autotools_configuration)
	if(MSVC)
		set(_generator "MinGW Makefiles")
	else()
		set(_generator "${CMAKE_GENERATOR}")
		if(CMAKE_EXTRA_GENERATOR)
			set(_extra_generator "${CMAKE_EXTRA_GENERATOR}")
		endif()
	endif()
	set(_autotools_command ${CMAKE_COMMAND} -G "${_generator}")
	if(_extra_generator)
		list(APPEND _autotools_command -T "${_extra_generator}")
	endif()
	if(CMAKE_TOOLCHAIN_FILE)
		list(APPEND _autotools_command "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
	endif()
	if(LINPHONE_BUILDER_OSX_ARCHITECTURES)
		list(APPEND _autotools_command "-DLINPHONE_BUILDER_OSX_ARCHITECTURES=${LINPHONE_BUILDER_OSX_ARCHITECTURES}")
	endif()
	list(APPEND _autotools_command "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Autotools/")
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/Autotools)
	execute_process(COMMAND ${_autotools_command} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/Autotools)
	unset(_autotools_command)
	unset(_extra_generator)
	unset(_generator)
	include(${CMAKE_BINARY_DIR}/Autotools/Autotools.cmake)
endfunction()


macro(linphone_builder_create_targets_list)
	set(LINPHONE_BUILDER_TARGETS )
	if("${LINPHONE_BUILDER_TARGET}" STREQUAL "belle-sip")
		list(APPEND LINPHONE_BUILDER_TARGETS "belle-sip")
	elseif("${LINPHONE_BUILDER_TARGET}" STREQUAL "ortp")
		list(APPEND LINPHONE_BUILDER_TARGETS "ortp")
	elseif("${LINPHONE_BUILDER_TARGET}" STREQUAL "ms2")
		list(APPEND LINPHONE_BUILDER_TARGETS "ortp" "ms2")
	elseif("${LINPHONE_BUILDER_TARGET}" STREQUAL "ms2-plugins")
		list(APPEND LINPHONE_BUILDER_TARGETS "ortp" "ms2" "ms2-plugins")
	elseif("${LINPHONE_BUILDER_TARGET}" STREQUAL "linphone")
		list(APPEND LINPHONE_BUILDER_TARGETS "belle-sip" "ortp" "ms2" "ms2-plugins" "linphone")
	elseif("${LINPHONE_BUILDER_TARGET}" STREQUAL "flexisip")
		list(APPEND LINPHONE_BUILDER_TARGETS "ortp" "flexisip")
	elseif("${LINPHONE_BUILDER_TARGET}" STREQUAL "odb")
		list(APPEND LINPHONE_BUILDER_TARGETS "odb" )
	else()
		message(FATAL_ERROR "Invalid LINPHONE_BUILDER_TARGET '${LINPHONE_BUILDER_TARGET}'")
	endif()
endmacro()


macro(linphone_builder_include_builder BUILDER)
	list(FIND LINPHONE_BUILDER_INCLUDED_BUILDERS ${BUILDER} _already_included)
	if(_already_included EQUAL -1)
		message(STATUS "Including builder ${BUILDER}")
		include(${CMAKE_CURRENT_SOURCE_DIR}/builders/${BUILDER}.cmake)
		list(APPEND LINPHONE_BUILDER_INCLUDED_BUILDERS ${BUILDER})
	endif()
	unset(_already_included)
endmacro()


macro(linphone_builder_add_builder_to_target TARGETNAME BUILDER)
	linphone_builder_include_builder(${BUILDER})
	add_dependencies(${TARGETNAME} EP_${BUILDER})
endmacro()


macro(linphone_builder_apply_flags)
	foreach(BUILD_CONFIG "" "_DEBUG" "_MINSIZEREL" "_RELEASE" "_RELWITHDEBINFO")
		if(NOT "${LINPHONE_BUILDER_CPPFLAGS}" STREQUAL "")
			set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_CPPFLAGS}")
			set(CMAKE_CXX_FLAGS${BUILD_CONFIG} "${CMAKE_CXX_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_CPPFLAGS}")
			set(AUTOTOOLS_C_FLAGS${BUILD_CONFIG} "${AUTOTOOLS_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_CPPFLAGS}")
			set(AUTOTOOLS_CXX_FLAGS${BUILD_CONFIG} "${AUTOTOOLS_CXX_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_CPPFLAGS}")
		endif()
		if(NOT "${LINPHONE_BUILDER_CFLAGS}" STREQUAL "")
			set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_CFLAGS}")
			set(AUTOTOOLS_C_FLAGS${BUILD_CONFIG} "${AUTOTOOLS_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_CFLAGS}")
		endif()
		if(NOT "${LINPHONE_BUILDER_CXXFLAGS}" STREQUAL "")
			set(CMAKE_CXX_FLAGS${BUILD_CONFIG} "${CMAKE_CXX_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_CXXFLAGS}")
			set(AUTOTOOLS_CXX_FLAGS${BUILD_CONFIG} "{AUTOTOOLS_CXX_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_CXX_FLAGS}")
		endif()
		if(NOT "${LINPHONE_BUILDER_OBJCFLAGS}" STREQUAL "")
			set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_OBJCFLAGS}")
			set(AUTOTOOLS_OBJC_FLAGS${BUILD_CONFIG} "${AUTOTOOLS_OBJC_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_OBJCFLAGS}")
		endif()
		if(NOT "${LINPHONE_BUILDER_LDFLAGS}" STREQUAL "")
			# TODO: The two following lines should not be here
			set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_LDFLAGS}")
			set(CMAKE_CXX_FLAGS${BUILD_CONFIG} "${CMAKE_CXX_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_LDFLAGS}")

			set(CMAKE_EXE_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_EXE_LINKER_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_LDFLAGS}")
			set(CMAKE_MODULE_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_MODULE_LINKER_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_LDFLAGS}")
			set(CMAKE_SHARED_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_SHARED_LINKER_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_LDFLAGS}")
			set(AUTOTOOLS_LINKER_FLAGS${BUILD_CONFIG} "${AUTOTOOLS_LINKER_FLAGS${BUILD_CONFIG}} ${LINPHONE_BUILDER_LDFLAGS}")
		endif()
	endforeach()
endmacro()


macro(linphone_builder_apply_cmake_flags_to_autotools_project PROJNAME)
	if("${EP_${PROJNAME}_BUILD_METHOD}" STREQUAL "autotools")
		set(BUILD_TYPES "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
		list(FIND BUILD_TYPES "${CMAKE_BUILD_TYPE}" BUILD_TYPE_FOUND)
		set(BUILD_TYPE_SUFFIX "")
		if(NOT ${BUILD_TYPE_FOUND} EQUAL -1)
			string(TOUPPER "${CMAKE_BUILD_TYPE}" UPPER_BUILD_TYPE)
			set(BUILD_TYPE_SUFFIX "_${UPPER_BUILD_TYPE}")
		endif()
		set(ep_asflags "${AUTOTOOLS_AS_FLAGS${BUILD_TYPE_SUFFIX}}")
		set(ep_cppflags "${AUTOTOOLS_CPP_FLAGS${BUILD_TYPE_SUFFIX}}")
		set(ep_cflags "${AUTOTOOLS_C_FLAGS${BUILD_TYPE_SUFFIX}}")
		set(ep_cxxflags "${AUTOTOOLS_CXX_FLAGS${BUILD_TYPE_SUFFIX}}")
		set(ep_objcflags "${AUTOTOOLS_OBJC_FLAGS${BUILD_TYPE_SUFFIX}}")
		set(ep_ldflags "${AUTOTOOLS_LINKER_FLAGS${BUILD_TYPE_SUFFIX}}")
	endif()
endmacro()


macro(linphone_builder_apply_extra_flags PROJNAME)
	if("${EP_${PROJNAME}_BUILD_METHOD}" STREQUAL "autotools")
		set(ep_asflags "${ep_asflags} ${EP_${PROJNAME}_EXTRA_ASFLAGS}")
		set(ep_cppflags "${ep_cppflags} ${EP_${PROJNAME}_EXTRA_CPPFLAGS}")
		set(ep_cflags "${ep_cflags} ${EP_${PROJNAME}_EXTRA_CFLAGS}")
		set(ep_cxxflags "${ep_cxxflags} ${EP_${PROJNAME}_EXTRA_CXXFLAGS}")
		set(ep_objcflags "${ep_objcflags} ${EP_${PROJNAME}_EXTRA_OBJCFLAGS}")
		set(ep_ldflags "${ep_ldflags} ${EP_${PROJNAME}_EXTRA_LDFLAGS}")
	else()
		foreach(BUILD_CONFIG "" "_DEBUG" "_MINSIZEREL" "_RELEASE" "_RELWITHDEBINFO")
			if(NOT "${EP_${PROJNAME}_EXTRA_CFLAGS}" STREQUAL "")
				set(CMAKE_C_FLAGS${BUILD_CONFIG} "${CMAKE_C_FLAGS${BUILD_CONFIG}} ${EP_${PROJNAME}_EXTRA_CFLAGS}")
			endif()
			if(NOT "${EP_${PROJNAME}_EXTRA_CXXFLAGS}" STREQUAL "")
				set(CMAKE_CXX_FLAGS${BUILD_CONFIG} "${CMAKE_CXX_FLAGS${BUILD_CONFIG}} ${EP_${PROJNAME}_EXTRA_CXXFLAGS}")
			endif()
			if(NOT "${EP_${PROJNAME}_EXTRA_LDFLAGS}" STREQUAL "")
				set(CMAKE_EXE_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_EXE_LINKER_FLAGS${BUILD_CONFIG}} ${EP_${PROJNAME}_EXTRA_LDFLAGS}")
				set(CMAKE_MODULE_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_MODULE_LINKER_FLAGS${BUILD_CONFIG}} ${EP_${PROJNAME}_EXTRA_LDFLAGS}")
				set(CMAKE_SHARED_LINKER_FLAGS${BUILD_CONFIG} "${CMAKE_SHARED_LINKER_FLAGS${BUILD_CONFIG}} ${EP_${PROJNAME}_EXTRA_LDFLAGS}")
			endif()
		endforeach()
	endif()
endmacro()


macro(linphone_builder_set_ep_directories PROJNAME)
	if(EP_${PROJNAME}_SOURCE_DIR)
		set(ep_source "${EP_${PROJNAME}_SOURCE_DIR}")
	else()
		set(ep_source "${ep_base}/Source/EP_${PROJNAME}")
	endif()
	if(EP_${PROJNAME}_BUILD_IN_SOURCE)
		set(ep_build "${ep_source}")
	else()
		set(ep_build "${ep_base}/Build/${PROJNAME}")
	endif()
endmacro()


macro(linphone_builder_create_autogen_command PROJNAME)
	if(EP_${PROJNAME}_USE_AUTOGEN)
		if(EP_${PROJNAME}_CONFIGURE_OPTIONS_PASSED_TO_AUTOGEN)
			set(ep_autogen_options "")
			foreach(OPTION ${EP_${PROJNAME}_CROSS_COMPILATION_OPTIONS} ${EP_${PROJNAME}_LINKING_TYPE} ${EP_${PROJNAME}_CONFIGURE_OPTIONS})
				set(ep_autogen_options "${ep_autogen_options} \"${OPTION}\"")
			endforeach()
		endif()
		set(ep_autogen_command "${ep_source}/autogen.sh ${ep_autogen_options}")
	else()
		set(ep_autogen_command "")
	endif()
endmacro()


macro(linphone_builder_create_configure_command PROJNAME)
	if(EP_${PROJNAME}_CONFIGURE_OPTIONS_PASSED_TO_AUTOGEN)
		set(ep_configure_command "")
	else()
		set(ep_configure_options "")
		foreach(OPTION ${EP_${PROJNAME}_CROSS_COMPILATION_OPTIONS} ${EP_${PROJNAME}_LINKING_TYPE} ${EP_${PROJNAME}_CONFIGURE_OPTIONS})
			set(ep_configure_options "${ep_configure_options} \"${OPTION}\"")
		endforeach()
		set(ep_configure_env "${EP_${PROJNAME}_CONFIGURE_ENV}")
		set(ep_configure_command "${ep_source}/configure ${ep_configure_options}")
	endif()
endmacro()


macro(linphone_builder_create_build_command PROJNAME)
	set(ep_make_options "${EP_${PROJNAME}_MAKE_OPTIONS}")
endmacro()


# this function invokes configure_file() for the project, using the default file if 
# the specific file is not defined
function(linphone_builder_configure_file_for_project PROJNAME CMD DEFAULT_CONF_FILE OUTPUT)
	if("${EP_${PROJNAME}_${CMD}_COMMAND_SOURCE}" STREQUAL "")
		MESSAGE(STATUS "Using default file ${DEFAULT_CONF_FILE} for ${CMD} step of ${PROJNAME}")
		configure_file(${DEFAULT_CONF_FILE} ${OUTPUT})
	else()
		MESSAGE(STATUS "Using specific file ${EP_${PROJNAME}_${CMD}_COMMAND_SOURCE} for ${CMD} step of ${PROJNAME}")
		configure_file(${EP_${PROJNAME}_${CMD}_COMMAND_SOURCE} ${OUTPUT})	  
	endif()
endfunction()

function(linphone_builder_add_project PROJNAME)
	if(LINPHONE_BUILDER_EXTERNAL_SOURCE_PATH)
		foreach(SUBDIR ${EP_${PROJNAME}_EXTERNAL_SOURCE_PATHS})
			if(NOT EP_${PROJNAME}_SOURCE_DIR)
				if(EXISTS "${LINPHONE_BUILDER_EXTERNAL_SOURCE_PATH}/${SUBDIR}")
					set(EP_${PROJNAME}_SOURCE_DIR "${LINPHONE_BUILDER_EXTERNAL_SOURCE_PATH}/${SUBDIR}")
				endif()
			endif()
		endforeach()
	endif()

	linphone_builder_set_ep_directories(${PROJNAME})
	if(NOT EP_${PROJNAME}_DO_NOT_USE_CMAKE_FLAGS)
		linphone_builder_apply_cmake_flags_to_autotools_project(${PROJNAME})
	endif()
	linphone_builder_apply_extra_flags(${PROJNAME})
	linphone_builder_expand_external_project_vars()

	if("${EP_${PROJNAME}_BUILD_METHOD}" STREQUAL "prebuilt")
		message("Using prebuilt ${PROJNAME}")
		set(BUILD_COMMANDS
			CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo ""
			BUILD_COMMAND ${CMAKE_COMMAND} -E echo ""
			INSTALL_COMMAND ${CMAKE_COMMAND} -DSOURCE_DIR=<SOURCE_DIR> -DINSTALL_DIR=${CMAKE_INSTALL_PREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/install_prebuilt.cmake
		)
	elseif("${EP_${PROJNAME}_BUILD_METHOD}" STREQUAL "custom")
		set(ep_redirect_to_file "2>&1 >> ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}.log")
		configure_file(${EP_${PROJNAME}_CONFIGURE_COMMAND_SOURCE} ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.sh)
		configure_file(${EP_${PROJNAME}_BUILD_COMMAND_SOURCE} ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.sh)
		configure_file(${EP_${PROJNAME}_INSTALL_COMMAND_SOURCE} ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.sh)
		if(WIN32)
			set(SCRIPT_EXTENSION bat)
			set(MSVC_PROJNAME ${PROJNAME})
			configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/mingw_configure.bat.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.bat)
			configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/mingw_build.bat.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.bat)
			configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/mingw_install.bat.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.bat)
		else()
			set(SCRIPT_EXTENSION sh)
		endif()
		set(BUILD_COMMANDS
			CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.${SCRIPT_EXTENSION}
			BUILD_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.${SCRIPT_EXTENSION}
			INSTALL_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.${SCRIPT_EXTENSION}
		)
	elseif("${EP_${PROJNAME}_BUILD_METHOD}" STREQUAL "autotools")
		linphone_builder_create_autogen_command(${PROJNAME})
		linphone_builder_create_configure_command(${PROJNAME})
		linphone_builder_create_build_command(${PROJNAME})
		if("${EP_${PROJNAME}_CONFIG_H_FILE}" STREQUAL "")
			set(ep_config_h_file config.h)
		else()
			set(ep_config_h_file ${EP_${PROJNAME}_CONFIG_H_FILE})
		endif()
		if("${EP_${PROJNAME}_INSTALL_TARGET}" STREQUAL "")
			set(ep_install_target "install")
		else()
			set(ep_install_target "${EP_${PROJNAME}_INSTALL_TARGET}")
		endif()

		set(ep_redirect_to_file "2>&1 >> ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}.log")
		if(WIN32)
			set(SCRIPT_EXTENSION bat)
			set(MSVC_PROJNAME ${PROJNAME})
			configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/mingw_configure.bat.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.bat)
			configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/mingw_build.bat.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.bat)
			configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/mingw_install.bat.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.bat)
			# Build in source with MinGW as build out-of-source does not work
			set(ep_build ${ep_source})
			if(NOT "${ep_autogen_command}" STREQUAL "")
				set(ep_autogen_redirect_to_file ${ep_redirect_to_file})
			endif()
			if(NOT "${ep_configure_command}" STREQUAL "")
				set(ep_configure_redirect_to_file ${ep_redirect_to_file})
			endif()
		else()
			set(SCRIPT_EXTENSION sh)
		endif()

		if("${EP_${PROJNAME}_PKG_CONFIG}" STREQUAL "")
			set(LINPHONE_BUILDER_PKG_CONFIG "${PKG_CONFIG_PROGRAM}")
		else()
			set(LINPHONE_BUILDER_PKG_CONFIG "${EP_${PROJNAME}_PKG_CONFIG}")
		endif()

		configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.sh)
		configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/build.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.sh)
		configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/install.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.sh)

		set(BUILD_COMMANDS
			CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure.${SCRIPT_EXTENSION}
			BUILD_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build.${SCRIPT_EXTENSION}
			INSTALL_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install.${SCRIPT_EXTENSION}
		)
	elseif("${EP_${PROJNAME}_BUILD_METHOD}" STREQUAL "rpm")
		
		if(WIN32)
			message(SEND_ERROR "rpm build not supported on WIN32")
		endif()

		linphone_builder_create_autogen_command(${PROJNAME})
		linphone_builder_create_configure_command(${PROJNAME})
		
		if("${EP_${PROJNAME}_CONFIG_H_FILE}" STREQUAL "")
			set(ep_config_h_file config.h)
		else()
			set(ep_config_h_file ${EP_${PROJNAME}_CONFIG_H_FILE})
		endif()
		
		if("${EP_${PROJNAME}_INSTALL_TARGET}" STREQUAL "")
			set(ep_install_target "install")
		else()
			set(ep_install_target "${EP_${PROJNAME}_INSTALL_TARGET}")
		endif()

		if("${EP_${PROJNAME}_SPEC_FILE}" STREQUAL "")
			message( SEND_ERROR "rpm build requires EP_${PROJNAME}_SPEC_FILE to be defined")
		else()
			set(LINPHONE_BUILDER_SPEC_FILE "${EP_${PROJNAME}_SPEC_FILE}")
		endif()

		# a distinctive name of the generated RPM. It is used to find the rpms to install
		# in the install step. Defaults to $PROJNAME but could be something else
		if("${EP_${PROJNAME}_RPMBUILD_NAME}" STREQUAL "")
			set(LINPHONE_BUILDER_RPMBUILD_NAME "${PROJNAME}")
		else()
			set(LINPHONE_BUILDER_RPMBUILD_NAME "${EP_${PROJNAME}_RPMBUILD_NAME}")
		endif()
		
		# a distinctive name of the generated RPM. It is used to find the rpms to install
		# in the install step. Defaults to $PROJNAME but could be something else
		if(NOT "${EP_${PROJNAME}_RPMBUILD_OPTIONS}" STREQUAL "")
			set(LINPHONE_BUILDER_RPMBUILD_OPTIONS "${EP_${PROJNAME}_RPMBUILD_OPTIONS}")
		endif()

		set(LINPHONE_BUILDER_SPEC_PREFIX "${EP_${PROJNAME}_SPEC_PREXIX}")

		if("${EP_${PROJNAME}_PKG_CONFIG}" STREQUAL "")
			set(LINPHONE_BUILDER_PKG_CONFIG "${PKG_CONFIG_PROGRAM}")
		else()
			set(LINPHONE_BUILDER_PKG_CONFIG "${EP_${PROJNAME}_PKG_CONFIG}")
		endif()

		if(NOT "${EP_${PROJNAME}_CONFIGURE_EXTRA_CMD}" STREQUAL "")
			set(LINPHONE_BUILDER_CONFIGURE_EXTRA_CMD "${EP_${PROJNAME}_CONFIGURE_EXTRA_CMD}")
		endif()

		# allow to have special command steps
		linphone_builder_configure_file_for_project(${PROJNAME} CONFIGURE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.rpm.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure_rpm.sh)
		linphone_builder_configure_file_for_project(${PROJNAME} BUILD ${CMAKE_CURRENT_SOURCE_DIR}/cmake/build.rpm.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build_rpm.sh)
		linphone_builder_configure_file_for_project(${PROJNAME} INSTALL ${CMAKE_CURRENT_SOURCE_DIR}/cmake/install.rpm.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install_rpm.sh)

		set(BUILD_COMMANDS
			CONFIGURE_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_configure_rpm.sh
			BUILD_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_build_rpm.sh
			INSTALL_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/EP_${PROJNAME}_install_rpm.sh
		)
	else()
		# Use CMake build method
		set(BUILD_COMMANDS
			CMAKE_ARGS ${EP_${PROJNAME}_CMAKE_OPTIONS} ${EP_${PROJNAME}_LINKING_TYPE}
			CMAKE_CACHE_ARGS ${LINPHONE_BUILDER_EP_ARGS}
		)
	endif()

	if(LINPHONE_BUILDER_LATEST AND EP_${PROJNAME}_GIT_TAG_LATEST)
		set(DOWNLOAD_SOURCE GIT_REPOSITORY ${EP_${PROJNAME}_GIT_REPOSITORY} GIT_TAG ${EP_${PROJNAME}_GIT_TAG_LATEST})
	elseif(EP_${PROJNAME}_SOURCE_DIR)
		set(DOWNLOAD_SOURCE SOURCE_DIR ${EP_${PROJNAME}_SOURCE_DIR})
	elseif(EP_${PROJNAME}_URL)
		set(DOWNLOAD_SOURCE URL ${EP_${PROJNAME}_URL})
		if(EP_${PROJNAME}_URL_HASH)
			list(APPEND DOWNLOAD_SOURCE URL_HASH ${EP_${PROJNAME}_URL_HASH})
		endif()
	else()
		set(DOWNLOAD_SOURCE GIT_REPOSITORY ${EP_${PROJNAME}_GIT_REPOSITORY} GIT_TAG ${EP_${PROJNAME}_GIT_TAG})
	endif()

	ExternalProject_Add(EP_${PROJNAME}
		DEPENDS ${EP_${PROJNAME}_DEPENDENCIES}
		BINARY_DIR ${ep_build}
		${DOWNLOAD_SOURCE}
		PATCH_COMMAND ${EP_${PROJNAME}_PATCH_COMMAND}
		CMAKE_GENERATOR ${CMAKE_GENERATOR}
		${BUILD_COMMANDS}
	)

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/builders/${PROJNAME}/postinstall.cmake)
		ExternalProject_Add_Step(EP_${PROJNAME} postinstall
			COMMAND ${CMAKE_COMMAND} -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} -DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR} -DINSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/builders/${PROJNAME}/postinstall.cmake
			COMMENT "Performing post-installation step"
			DEPENDEES mkdir update patch download configure build install
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		)
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/builders/${PROJNAME}/postconfig.cmake)
		ExternalProject_Add_Step(EP_${PROJNAME} postinstall
			COMMAND ${CMAKE_COMMAND} -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} -DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR} -DINSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -P ${CMAKE_CURRENT_SOURCE_DIR}/builders/${PROJNAME}/postinstall.cmake
			COMMENT "Performing post-installation step"
			DEPENDEES mkdir update patch download configure build install
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		)
	endif()

endfunction()

function(linphone_builder_add_external_projects)
	foreach(BUILDER ${LINPHONE_BUILDER_INCLUDED_BUILDERS})
		linphone_builder_add_project(${BUILDER})
	endforeach()
endfunction()