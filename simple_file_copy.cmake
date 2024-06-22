#specific/tied to utils.cmake file copy usage arguments...

cmake_path(GET CMAKE_ARGV5 PARENT_PATH parentPath)
cmake_path(GET CMAKE_ARGV5 FILENAME filename)
message("Copying file ${CMAKE_ARGV4} to ${parentPath}/${filename}")
file(COPY ${CMAKE_ARGV4} DESTINATION ${parentPath})
