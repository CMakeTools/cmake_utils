#specific/tied to utils.cmake file copy usage arguments...

cmake_path(GET CMAKE_ARGV5 PARENT_PATH parentPath)
cmake_path(GET CMAKE_ARGV5 FILENAME filename)
message(VERBOSE "Copying file ${CMAKE_ARGV4} to ${parentPath}/${filename}")
if(EXISTS ${CMAKE_ARGV4})
file(COPY ${CMAKE_ARGV4} DESTINATION ${parentPath})
else()
message(WARNING "File ${CMAKE_ARGV4} Does Not Exist")
endif()