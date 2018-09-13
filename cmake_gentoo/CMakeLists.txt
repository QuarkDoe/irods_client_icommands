cmake_minimum_required( VERSION 3.5.0 FATAL_ERROR )
#=====================================================

project( icommands C CXX )

#-----------------------------------------------------

set(
	CMAKE_MODULE_PATH
	${CMAKE_SOURCE_DIR}/cmake_find/
	${CMAKE_SOURCE_DIR}/cmake_modules/
)

get_filename_component( ICOMMANDS_SOURCE_DIR "${CMAKE_SOURCE_DIR}/.." ABSOLUTE )

include( DefineCMakeDefaults )
include( RequireOutOfSourceBuild )

find_package( Clang REQUIRED )

include( DefineCompilerOptions )

find_package( AvroCpp REQUIRED )
message( STATUS "AVROCPP_ROOT_DIR:${AVROCPP_ROOT_DIR}" )
message( STATUS "AVROCPP_LIBRARIES:${AVROCPP_LIBRARIES}" )
message( STATUS "AVROCPP_INCLUDE_DIR:${AVROCPP_INCLUDE_DIR}" )
message( STATUS "AVROCPP_LIB_DIR:${AVROCPP_LIB_DIR}" )
message( STATUS "AVROCPP_AVROGEN:${AVROCPP_AVROGEN}" )

set( Boost_USE_MULTITHREADED ON )
find_package(
	Boost 1.60 REQUIRED
	COMPONENTS
	filesystem
	system
	program_options
)

find_package( PkgConfig REQUIRED )
pkg_check_modules( LIBARCHIVE libarchive>=3.1.2 REQUIRED )
pkg_check_modules( JANSSON jansson>=2.7 REQUIRED )
pkg_check_modules( ZEROMQ libzmq>=4.2.1 REQUIRED )

include( CheckIncludeFile )
include( CheckIncludeFileCXX )

check_include_file_cxx( zmq.hpp HAVE_ZMQ_HPP )
if( NOT HAVE_ZMQ_HPP )
	message( FATAL_ERROR "Require zmq.hpp. HAVE_ZMQ_HPP : ${HAVE_ZMQ_HPP}" )
else( NOT HAVE_ZMQ_HPP )
	message( STATUS "Found zmq.hpp. HAVE_ZMQ_HPP : ${HAVE_ZMQ_HPP}" )
endif( NOT HAVE_ZMQ_HPP )

find_package( IRODS 4.2.4 EXACT REQUIRED CONFIG )

message( STATUS "iRODS found" )
# message( STATUS "IRODS_TARGETS_PATH ${IRODS_TARGETS_PATH}" )
# message( STATUS "IRODS_INCLUDE_DIR ${IRODS_INCLUDE_DIR}")
# message( STATUS "IRODS_COMPILE_DEFINITIONS ${IRODS_COMPILE_DEFINITIONS}")
# message( STATUS "IRODS_CXX_STANDARD ${IRODS_CXX_STANDARD}")
# include( IRODSTargets )
include( ${IRODS_TARGETS_PATH} )

get_cmake_property( _variableNames VARIABLES )
list( SORT _variableNames )
foreach( _variableName ${_variableNames} )
	if( _variableName MATCHES ^IRODS )
		message( STATUS "${_variableName}=${${_variableName}}" )
	endif()
endforeach()

find_program( HELP2MAN help2man )
if( NOT HELP2MAN )
	message( FATAL_ERROR "Cann't found help2man executable" )
endif()

set(
	IRODS_CLIENT_ICOMMANDS_EXECUTABLES
	iadmin
	iapitest
	ibun
	icd
	ichksum
	ichmod
	iclienthints
	icp
	ienv
	ierror
	iexecmd
	iexit
	ifsck
	iget
	igroupadmin
	ihelp
	iinit
	ils
	ilsresc
	imcoll
	imeta
	imiscsvrinfo
	imkdir
	imv
	ipasswd
	iphybun
	iphymv
	ips
	iput
	ipwd
	iqdel
	iqmod
	iqstat
	iquest
	iquota
	ireg
	irepl
	irm
	irmdir
	irmtrash
	irods-grid
	irsync
	irule
	iscan
	isysmeta
	iticket
	itrim
	iuserinfo
	ixmsg
	izonereport
)

foreach( EXECUTABLE ${IRODS_CLIENT_ICOMMANDS_EXECUTABLES} )
	add_executable(
		${EXECUTABLE}
		${ICOMMANDS_SOURCE_DIR}/src/${EXECUTABLE}.cpp
	)

	target_link_libraries(
		${EXECUTABLE}
		PRIVATE
		irods_client
		irods_plugin_dependencies
		irods_common
		${AVROCPP_LIBRARIES}
		${Boost_FILESYSTEM_LIBRARY}
		${Boost_PROGRAM_OPTIONS_LIBRARY}
		${Boost_SYSTEM_LIBRARY}
		${JANSSON_LIBRARIES}
		${ZEROMQ_LIBRARIES}
	)

	target_include_directories(
		${EXECUTABLE}
		PRIVATE
		${IRODS_INCLUDE_DIR}
		${AVROCPP_INCLUDE_DIR}
		${Boost_INCLUDE_DIRS}
		${JANSSON_INCLUDE_DIRS}
		${LIBARCHIVE_INCLUDE_DIRS}
		${ZEROMQ_INCLUDE_DIRS}
	)
 	target_compile_definitions( ${EXECUTABLE} PRIVATE RODS_SERVER ${IRODS_COMPILE_DEFINITIONS} BOOST_SYSTEM_NO_DEPRECATED )
	target_compile_options( ${EXECUTABLE} PRIVATE -Wno-write-strings )
	set_property( TARGET ${EXECUTABLE} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
	install(
		TARGETS
		${EXECUTABLE}
		RUNTIME DESTINATION bin
	)

	if ( ${EXECUTABLE} STREQUAL "iapitest" )
		continue()
	endif()

	add_custom_command(
		OUTPUT ${CMAKE_BINARY_DIR}/man/${EXECUTABLE}.1.gz
		DEPENDS ${EXECUTABLE}
		COMMAND ${ICOMMANDS_SOURCE_DIR}/packaging/make_man_page.sh ${IRODS_VERSION} ${CMAKE_BINARY_DIR} ${EXECUTABLE} ${CMAKE_BINARY_DIR}/man
	)
	add_custom_target( IRODS_ICOMMANDS_PHONY_TARGET_${EXECUTABLE} ALL DEPENDS ${CMAKE_BINARY_DIR}/man/${EXECUTABLE}.1.gz ) #forces execution of custom_command
	install(
		FILES
		${CMAKE_BINARY_DIR}/man/${EXECUTABLE}.1.gz
		DESTINATION share/man/man1
	)
endforeach()
