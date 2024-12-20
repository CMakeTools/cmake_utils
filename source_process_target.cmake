include_guard(GLOBAL)






#Create a process process target - with name: TARGET_NAME,  it will be added as dependancy of TOP_LEVEL_TARGET.  
#Process each file in SOURCE_LIST.  
#OUTPUT_FILE_LIST is set to list of processed files
#
#
#HEADER_REPLACEMENTS list of header string eg "HC_API.h" to be replaced in the source files by eg "motioncontrolAPI.FILEEXT_CODE.h"

function(gen_source_preprocess_target)

    #TARGET_NAME FILEEXT_CODE TOP_LEVEL_TARGET SOURCE_LIST OUTPUT_FILE_LIST PCPP_PRE_DEFINES PCPP_PRE_UN_DEFINES PCPP_PRE_NEVER_DEFINES



    set(options "")
    set(oneValueArgs TARGET_NAME FILEEXT_CODE TOP_LEVEL_TARGET PROCESS_DEFINES)
    set(multiValueArgs SOURCE_LIST OUTPUT_FILE_LIST PCPP_PRE_DEFINES PCPP_PRE_UN_DEFINES PCPP_PRE_NEVER_DEFINES)
    
    cmake_parse_arguments("gen_source_preprocess_target" "${options}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN} )




    message("creating pre-process-target: ${gen_source_preprocess_target_TARGET_NAME}")

    #message("gen_source_preprocess_target_SOURCE_LIST: ${gen_source_preprocess_target_SOURCE_LIST}")

    add_custom_target(${gen_source_preprocess_target_TARGET_NAME}
    SOURCES ${gen_source_preprocess_target_SOURCE_LIST}
    #DEPENDS ${gen_source_preprocess_target_SOURCE_LIST}
    )

    #add the target to same folder as top target
    get_target_property(topTargetFolder ${gen_source_preprocess_target_TOP_LEVEL_TARGET} FOLDER)
    if(gen_source_preprocess_target_FILEEXT_CODE)
        set_target_properties (${gen_source_preprocess_target_TARGET_NAME} PROPERTIES
            FOLDER "${topTargetFolder}/PreProcessors/${gen_source_preprocess_target_FILEEXT_CODE}"
        )
    else()
        set_target_properties (${gen_source_preprocess_target_TARGET_NAME} PROPERTIES
            FOLDER "${topTargetFolder}/PreProcessors"
        )
    endif()


    foreach(def ${gen_source_preprocess_target_PCPP_PRE_DEFINES})
        string(APPEND preDefsString "${def} ")
    endforeach()

    #add preDefs from TOP_LEVEL_TARGET 
    # get_target_property(compileDefinitions ${gen_source_preprocess_target_TOP_LEVEL_TARGET} COMPILE_DEFINITIONS)
    # get_target_property(commonCompileDefinitions compileDefinesCommon INTERFACE_COMPILE_DEFINITIONS)#TODO - would be better if extracted direct from TOP_LEVEL_TARGET, but interface libraries dont seem to resolve definitions on target until build time.
    # if(commonCompileDefinitions)
    #     foreach(def ${commonCompileDefinitions})
    #         string(APPEND preDefsString "${def} ")
    #     endforeach()
    # endif()
    # if(compileDefinitions)
    #     foreach(def ${compileDefinitions})
    #         string(APPEND preDefsString "${def} ")
    #     endforeach()
    # endif()


    
    foreach(def ${gen_source_preprocess_target_PCPP_PRE_UN_DEFINES})
        string(APPEND preUnDefsString "${def} ")
    endforeach()
    foreach(def ${gen_source_preprocess_target_PCPP_PRE_NEVER_DEFINES})
        string(APPEND preNeverDefsString "${def} ")
    endforeach()



    # message("preDefsString is ${preDefsString}")
    # message("preUnDefsString is ${preUnDefsString}")
    # message("preNeverDefsString is ${preNeverDefsString}")



    # message("headerOriginalStringList is ${headerOriginalStringList}")
    # message("headerReplacementStringList is ${headerReplacementStringList}")
    # message("headerOriginalStringListSpaces is ${headerOriginalStringListSpaces}")
    # message("headerReplacementStringListSpaces is ${headerReplacementStringListSpaces}")
    # message("----------------------------------------------------------------------")
    # message("postHeaderOriginalStringList is ${postHeaderOriginalStringList}")
    # message("postHeaderReplacementStringList is ${postHeaderReplacementStringList}")
    # message("postHeaderOriginalStringListSpaces is ${postHeaderOriginalStringListSpaces}")
    # message("postHeaderReplacementStringListSpaces is ${postHeaderReplacementStringListSpaces}")

    #gather replacements strings for #includes in all the source files.
    foreach(srcFile ${gen_source_preprocess_target_SOURCE_LIST} )
        #TODO headers are the only files that actually need to be considered.
        get_filename_component(extension "${CMAKE_CURRENT_SOURCE_DIR}/${srcFile}" EXT)
        get_filename_component(nameNoExt "${CMAKE_CURRENT_SOURCE_DIR}/${srcFile}" NAME_WE   )
        get_filename_component(srcFileDirectory "${srcFile}" DIRECTORY  )

        list(APPEND headerOriginalStringList "${srcFile}")

        

        if(srcFileDirectory)
            set(replNamePart "${srcFileDirectory}/${nameNoExt}")
        else()
            set(replNamePart "${nameNoExt}")
        endif()

        if(gen_source_preprocess_target_FILEEXT_CODE)
            set(replExtPart ".${gen_source_preprocess_target_FILEEXT_CODE}${extension}")
        else()
            set(replExtPart "${extension}")
        endif()

        list(APPEND headerReplacementStringList "${replNamePart}${replExtPart}")
    endforeach()



    #append/attach those replacement strings to TOP_LEVEL_TARGET so they can be used in targets depending on TOP_LEVEL_TARGET
    get_target_property(a ${gen_source_preprocess_target_TOP_LEVEL_TARGET} SRC_PROC_TRG_HEADER_REPLACEMENTS_ORIG_${gen_source_preprocess_target_FILEEXT_CODE})
    get_target_property(b ${gen_source_preprocess_target_TOP_LEVEL_TARGET} SRC_PROC_TRG_HEADER_REPLACEMENTS_REPL_${gen_source_preprocess_target_FILEEXT_CODE})

    if(a AND b)
        list(APPEND headerOriginalStringList "${a}")
        list(APPEND headerReplacementStringList "${b}")
    endif()

    set_target_properties(${gen_source_preprocess_target_TOP_LEVEL_TARGET} PROPERTIES SRC_PROC_TRG_HEADER_REPLACEMENTS_ORIG_${gen_source_preprocess_target_FILEEXT_CODE} "${headerOriginalStringList}")
    set_target_properties(${gen_source_preprocess_target_TOP_LEVEL_TARGET} PROPERTIES SRC_PROC_TRG_HEADER_REPLACEMENTS_REPL_${gen_source_preprocess_target_FILEEXT_CODE} "${headerReplacementStringList}")


    #look at dependancy targets of TOP_LEVEL_TARGET and add their header replacement strings. 
    get_all_target_dependancies(${gen_source_preprocess_target_TOP_LEVEL_TARGET} ${gen_source_preprocess_target_TOP_LEVEL_TARGET} dependancyTargets)
    
    #message("dependants of ${gen_source_preprocess_target_TOP_LEVEL_TARGET} are ${dependancyTargets}")
    foreach(target ${dependancyTargets})

        get_target_property(headerReplOrig ${target} SRC_PROC_TRG_HEADER_REPLACEMENTS_ORIG_${gen_source_preprocess_target_FILEEXT_CODE})
        get_target_property(headerReplRepl ${target} SRC_PROC_TRG_HEADER_REPLACEMENTS_REPL_${gen_source_preprocess_target_FILEEXT_CODE})

        #message("considering target: ${target}")

        if(headerReplOrig AND headerReplRepl)
            #message("adding header replacment from target ${target}")
            #message("${headerReplOrig}")
            foreach(orig ${headerReplOrig})
                
                list(APPEND headerOriginalStringList "${orig}")
            endforeach()
            foreach(repl ${headerReplRepl})
                list(APPEND headerReplacementStringList "${repl}")
            endforeach()
        endif()

    endforeach()


    set(headerOriginalStringList_global ${headerOriginalStringList})
    set(headerReplacementStringList_global ${headerReplacementStringList})
    set(postHeaderOriginalStringList_global ${postHeaderOriginalStringList})
    set(postHeaderReplacementStringList_global ${postHeaderReplacementStringList})

    foreach(srcFile ${gen_source_preprocess_target_SOURCE_LIST} )

        #reset replacment vars to global for this target from above.
        set(headerOriginalStringList ${headerOriginalStringList_global})
        set(headerReplacementStringList ${headerReplacementStringList_global})
        set(postHeaderOriginalStringList ${postHeaderOriginalStringList_global})
        set(postHeaderReplacementStringList ${postHeaderReplacementStringList_global})


        get_filename_component(extension "${CMAKE_CURRENT_SOURCE_DIR}/${srcFile}" EXT)
        get_filename_component(nameNoExt "${CMAKE_CURRENT_SOURCE_DIR}/${srcFile}" NAME_WE   )
        get_filename_component(srcFileDirectory "${srcFile}" DIRECTORY  )
         

        string(TOUPPER ${nameNoExt} srcFileNameUpper)
        if(gen_source_preprocess_target_FILEEXT_CODE)
            #string(TOUPPER ${gen_source_preprocess_target_FILEEXT_CODE} gen_source_preprocess_target_FILEEXT_CODE_UPPER)
            set(aExtStr "_${gen_source_preprocess_target_FILEEXT_CODE}")
        else()
            set(aExtStr "")
        endif()

        #add header gaurd replacements
        
        list(APPEND postHeaderOriginalStringList "[[PREPROC_HEADER_GUARD_BEGIN]]")
        list(APPEND postHeaderReplacementStringList "\#ifndef{pyrepl{SPACE}}${srcFileNameUpper}${aExtStr}_H{pyrepl{NEWLINE}}\#define{pyrepl{SPACE}}${srcFileNameUpper}${aExtStr}_H")
        list(APPEND postHeaderOriginalStringList "[[PREPROC_HEADER_GUARD_END]]")
        list(APPEND postHeaderReplacementStringList "\#endif{pyrepl{SPACE}}//${srcFileNameUpper}${aExtStr}_H")
    
        #add "NOPROCESS" gaurd replacements by using commenting
        list(APPEND headerOriginalStringList "[[PREPROC_NOPROC_START]]")
        list(APPEND headerReplacementStringList "/*[[PREPROC_NOPROC_START]]")
        list(APPEND headerOriginalStringList "[[PREPROC_NOPROC_END]]")
        list(APPEND headerReplacementStringList "*/[[PREPROC_NOPROC_END]]")

        list(APPEND postHeaderOriginalStringList "/*[[PREPROC_NOPROC_START]]")
        list(APPEND postHeaderReplacementStringList "//[[PREPROC_NOPROC_START]]")
        list(APPEND postHeaderOriginalStringList "*/[[PREPROC_NOPROC_END]]")
        list(APPEND postHeaderReplacementStringList "//[[PREPROC_NOPROC_END]]")


        list(TRANSFORM headerOriginalStringList PREPEND "\"" OUTPUT_VARIABLE headerOriginalStringListSpaces)
        list(TRANSFORM headerOriginalStringListSpaces APPEND "\"" OUTPUT_VARIABLE headerOriginalStringListSpaces)
        list(TRANSFORM headerReplacementStringList PREPEND "\"" OUTPUT_VARIABLE headerReplacementStringListSpaces)
        list(TRANSFORM headerReplacementStringListSpaces APPEND "\"" OUTPUT_VARIABLE headerReplacementStringListSpaces)
        list(JOIN headerOriginalStringListSpaces "\ " headerOriginalStringListSpaces)
        list(JOIN headerReplacementStringListSpaces "\ " headerReplacementStringListSpaces)
    
    
        list(TRANSFORM postHeaderOriginalStringList PREPEND "\"" OUTPUT_VARIABLE postHeaderOriginalStringListSpaces)
        list(TRANSFORM postHeaderOriginalStringListSpaces APPEND "\"" OUTPUT_VARIABLE postHeaderOriginalStringListSpaces)
        list(TRANSFORM postHeaderReplacementStringList PREPEND "\"" OUTPUT_VARIABLE postHeaderReplacementStringListSpaces)
        list(TRANSFORM postHeaderReplacementStringListSpaces APPEND "\"" OUTPUT_VARIABLE postHeaderReplacementStringListSpaces)
        list(JOIN postHeaderOriginalStringListSpaces "\ " postHeaderOriginalStringListSpaces)
        list(JOIN postHeaderReplacementStringListSpaces "\ " postHeaderReplacementStringListSpaces)
    

        # message("headerOriginalStringListSpaces is ${headerOriginalStringListSpaces}")
        # message("headerReplacementStringListSpaces is ${headerReplacementStringListSpaces}")
        # message("postHeaderOriginalStringListSpaces is ${postHeaderOriginalStringListSpaces}")
        # message("postHeaderReplacementStringListSpaces is ${postHeaderReplacementStringListSpaces}")
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${srcFileDirectory}")
        if(gen_source_preprocess_target_FILEEXT_CODE)
            set(aExtStr ".${gen_source_preprocess_target_FILEEXT_CODE}")
        else()
            set(aExtStr "")
        endif()
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${srcFileDirectory}/${nameNoExt}${aExtStr}${extension}" "//CMake Generated - to be populated with processed source by the target: ${gen_source_preprocess_target_TARGET_NAME}")

        separate_arguments(definesOptionsPCPPList UNIX_COMMAND "${preDefsString} ${preUnDefsString} ${preNeverDefsString}")
        list(JOIN definesOptionsPCPPList "\ " definesOptionsPCPP)



        set(destDirStr "${CMAKE_CURRENT_BINARY_DIR}/${srcFileDirectory}")

        #message("headerOriginalStringListSpaces is ${headerOriginalStringListSpaces}")
        #message("headerReplacementStringListSpaces is ${headerReplacementStringListSpaces}")
        #message("postHeaderOriginalStringListSpaces is ${postHeaderOriginalStringListSpaces}")
        #message("postHeaderReplacementStringListSpaces is ${postHeaderReplacementStringListSpaces}")

        add_custom_command(TARGET ${gen_source_preprocess_target_TARGET_NAME} POST_BUILD
            

            COMMAND "python" "${CMAKE_SOURCE_DIR}/utilities/preProcessPipeline.py" 
                "${CMAKE_CURRENT_SOURCE_DIR}/${srcFile}" 
                "${destDirStr}/${nameNoExt}${aExtStr}${extension}"
                "${gen_source_preprocess_target_PROCESS_DEFINES}"
                "--defines" "${preDefsString}"
                "--undefines" "${preUnDefsString}"
                "--neverdefines" "${preNeverDefsString}"
                "--originalStringsStage1" "${headerOriginalStringListSpaces}"
                "--replacementStringsStage1" "${headerReplacementStringListSpaces}"
                "--originalStringsStage2" "${postHeaderOriginalStringListSpaces}"
                "--replacementStringsStage2" "${postHeaderReplacementStringListSpaces}"
             #   "--printMessage" "\"(python)running pre-process pipeline target ${gen_source_preprocess_target_TARGET_NAME}\""
            
            #COMMENT "running pre-process pipeline target ${gen_source_preprocess_target_TARGET_NAME} for file ${nameNoExt}${aExtStr}${extension}"
        )


        if(srcFileDirectory )
            list(APPEND outList "${srcFileDirectory}/${nameNoExt}${aExtStr}${extension}")
           

        else()
            list(APPEND outList "${nameNoExt}${aExtStr}${extension}")
           

        endif()
        

    endforeach()


    set(${gen_source_preprocess_target_OUTPUT_FILE_LIST} ${outList} PARENT_SCOPE)


    # message("${gen_source_preprocess_target_TOP_LEVEL_TARGET}")
    # message("${gen_source_preprocess_target_TARGET_NAME}")
    add_dependencies(${gen_source_preprocess_target_TOP_LEVEL_TARGET} ${gen_source_preprocess_target_TARGET_NAME})




endfunction()