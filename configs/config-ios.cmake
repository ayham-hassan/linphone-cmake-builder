############################################################################
# config-ios.cmake
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

# Define default values for the linphone builder options
set(DEFAULT_VALUE_ENABLE_VIDEO ON)
set(DEFAULT_VALUE_ENABLE_GPL_THIRD_PARTIES ON)
set(DEFAULT_VALUE_ENABLE_FFMPEG ON)
set(DEFAULT_VALUE_ENABLE_ZRTP ON)
set(DEFAULT_VALUE_ENABLE_SRTP ON)
set(DEFAULT_VALUE_ENABLE_DTLS ON)
set(DEFAULT_VALUE_ENABLE_AMRNB ON)
set(DEFAULT_VALUE_ENABLE_AMRWB ON)
set(DEFAULT_VALUE_ENABLE_G729 ON)
set(DEFAULT_VALUE_ENABLE_GSM ON)
set(DEFAULT_VALUE_ENABLE_ILBC ON)
set(DEFAULT_VALUE_ENABLE_ISAC OFF)
set(DEFAULT_VALUE_ENABLE_OPUS ON)
set(DEFAULT_VALUE_ENABLE_SILK ON)
set(DEFAULT_VALUE_ENABLE_SPEEX ON)
set(DEFAULT_VALUE_ENABLE_WASAPI OFF)
set(DEFAULT_VALUE_ENABLE_WEBRTC_AEC OFF)
set(DEFAULT_VALUE_ENABLE_H263 ON)
set(DEFAULT_VALUE_ENABLE_H263P ON)
set(DEFAULT_VALUE_ENABLE_MPEG4 ON)
set(DEFAULT_VALUE_ENABLE_OPENH264 ON)
set(DEFAULT_VALUE_ENABLE_VPX ON)
set(DEFAULT_VALUE_ENABLE_X264 OFF)
set(DEFAULT_VALUE_ENABLE_TUNNEL OFF)
set(DEFAULT_VALUE_ENABLE_UNIT_TESTS ON)
set(DEFAULT_VALUE_CMAKE_LINKING_TYPE "-DENABLE_STATIC=YES")


# Global configuration
set(SDK_VERSION 6.0)
get_filename_component(COMPILER_NAME ${CMAKE_C_COMPILER} NAME)
string(REGEX REPLACE "-clang$" "" LINPHONE_BUILDER_HOST ${COMPILER_NAME})
unset(COMPILER_NAME)
if("${PLATFORM}" MATCHES "Simulator")
	set(CLANG_TARGET_SPECIFIER "ios-simulator-version-min")
else("${PLATFORM}" MATCHES "Simulator")
	set(CLANG_TARGET_SPECIFIER "iphoneos-version-min")
endif("${PLATFORM}" MATCHES "Simulator")
list(GET CMAKE_FIND_ROOT_PATH 0 SYSROOT_PATH)
set(COMMON_FLAGS "-arch ${SYSTEM_ARCH} -isysroot ${SYSROOT_PATH} -m${CLANG_TARGET_SPECIFIER}=${SDK_VERSION} -DTARGET_OS_IPHONE=1 -D__IOS -fms-extensions")
set(LINPHONE_BUILDER_CPPFLAGS "${COMMON_FLAGS} -Dasm=__asm")
#set(LINPHONE_BUILDER_CFLAGS "-std=c99")
set(LINPHONE_BUILDER_LDFLAGS "${COMMON_FLAGS}")
set(LINPHONE_BUILDER_PKG_CONFIG_LIBDIR ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)	# Restrict pkg-config to search in the install directory
unset(COMMON_FLAGS)
unset(CLANG_TARGET_SPECIFIER)
unset(SYSROOT_PATH)
unset(SDK_VERSION)


# Include builders
include(builders/CMakeLists.txt)


# belle-sip
list(APPEND EP_bellesip_CMAKE_OPTIONS "-DENABLE_TESTS=NO")

# bzrtp
list(APPEND EP_bzrtp_CMAKE_OPTIONS "-DENABLE_TESTS=NO")

# ffmpeg
set(EP_ffmpeg_LINKING_TYPE "--enable-static" "--disable-shared")

# linphone
list(APPEND EP_linphone_CMAKE_OPTIONS
	"-DENABLE_RELATIVE_PREFIX=YES"
	"-DENABLE_CONSOLE_UI=NO"
	"-DENABLE_GTK_UI=NO"
	"-DENABLE_NOTIFY=NO"
	"-DENABLE_TOOLS=NO"
	"-DENABLE_TUTORIALS=NO"
	"-DENABLE_UPNP=NO"
	"-DENABLE_MSG_STORAGE=YES"
	"-DENABLE_DOC=NO" 
	"-DENABLE_UNIT_TESTS=YES"
)

# mediastreamer2
list(APPEND EP_ms2_CMAKE_OPTIONS
	"-DENABLE_RELATIVE_PREFIX=YES"
	"-DENABLE_ALSA=NO"
	"-DENABLE_PULSEAUDIO=NO"
	"-DENABLE_OSS=NO"
	"-DENABLE_GLX=NO"
	"-DENABLE_X11=NO"
	"-DENABLE_XV=NO"
	"-DENABLE_TOOLS=NO"
	"-DENABLE_DOC=NO"
	"-DENABLE_UNIT_TESTS=NO"
)

# opus
list(APPEND EP_opus_CMAKE_OPTIONS "-DENABLE_FIXED_POINT=YES")

# ortp
list(APPEND EP_ortp_CMAKE_OPTIONS "-DENABLE_DOC=NO")

# polarssl
set(EP_polarssl_LINKING_TYPE "-DUSE_SHARED_POLARSSL_LIBRARY=0")

# speex
list(APPEND EP_speex_CMAKE_OPTIONS "-DENABLE_FLOAT_API=NO" "-DENABLE_FIXED_POINT=YES")

# vpx
set(EP_vpx_LINKING_TYPE "--enable-static" "--disable-shared")
