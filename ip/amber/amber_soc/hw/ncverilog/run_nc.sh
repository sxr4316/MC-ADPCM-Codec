#!/bin/bash 

#--------------------------------------------------------------#
#                                                              #
#  run.sh                                                      #
#                                                              #
#  This file is part of the Amber project                      #
#  http://www.opencores.org/project,amber                      #
#                                                              #
#  Description                                                 #
#  Run a Verilog simulation using Modelsim                     #
#                                                              #
#  Author(s):                                                  #
#      - Conor Santifort, csantifort.amber@gmail.com           #
#      - Mark Indovina, maieee@rit.edu                         #
#                                                              #
#//////////////////////////////////////////////////////////////#
#                                                              #
# Copyright (C) 2013 Authors and OPENCORES.ORG                 #
#                                                              #
# This source file may be used and distributed without         #
# restriction provided that this copyright statement is not    #
# removed from the file and that any derivative work contains  #
# the original copyright notice and the associated disclaimer. #
#                                                              #
# This source file is free software; you can redistribute it   #
# and/or modify it under the terms of the GNU Lesser General   #
# Public License as published by the Free Software Foundation; #
# either version 2.1 of the License, or (at your option) any   #
# later version.                                               #
#                                                              #
# This source is distributed in the hope that it will be       #
# useful, but WITHOUT ANY WARRANTY; without even the implied   #
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      #
# PURPOSE.  See the GNU Lesser General Public License for more #
# details.                                                     #
#                                                              #
# You should have received a copy of the GNU Lesser General    #
# Public License along with this source; if not, download it   #
# from http://www.opencores.org/lgpl.shtml                     #
#                                                              #
#--------------------------------------------------------------#

. /classes/eeee720/etc/ENV-arm-unknown-eabi.sh

#--------------------------------------------------------
# Defaults
#--------------------------------------------------------
AMBER_LOAD_MAIN_MEM=" "
AMBER_TIMEOUT=0
AMBER_LOG_FILE="tests.log"
SET_G=0
SET_M=0
SET_T=0
SET_S=0
SET_5=1
SET_3=0
SET_L=0
SET_C=0


# show program usage
show_usage() {
    echo "Usage:"
    echo "run <test_name> [-h] [-c] [-g] [-l] [-s] [-5] [-3]"
    echo " -h : Help"
    echo " -c : Run 'make clean' before compiling"
    echo " -g : Use NC-Verilog GUI"
    echo " -l : Create dump of complete design"
    echo " -s : Use Xilinx Spatran6 Libraries (slower sim)"
    echo " -5 : Use Amber25 core (default)"
    echo " -3 : Use Amber23 core"
    echo ""
    exit
}


#--------------------------------------------------------
# Parse command-line options
#--------------------------------------------------------

# Minimum number of arguments needed by this program
MINARGS=1

# show usage if '-h' or  '--help' is the first argument or no argument is given
case $1 in
	""|"-h"|"--help"|"help"|"?") show_usage ;;
esac

# get the number of command-line arguments given
ARGC=$#

# check to make sure enough arguments were given or exit
if [[ $ARGC -lt $MINARGS ]] ; then
 echo "Too few arguments given (Minimum:$MINARGS)"
 echo
 show_usage
fi

# self-sorting argument types LongEquals, ShortSingle, ShortSplit, and ShortMulti
# process command-line arguments
while [ "$1" ]
do
    case $1 in
        -*)  true ;
            case $1 in
                -s)     SET_S=1   # Xilinx Spartan6 libs
                        shift ;;
                -5)     SET_5=1   # Amber25 core (default is Amber23 core)
                        shift ;;
                -3)     SET_5=1   # Amber23 core (default is Amber25 core)
                        shift ;;
                -g)     SET_G=1   # Bring up GUI
                        shift ;;
                -l)     SET_L=1   # Create wave dump file
                        shift ;;
                -c)     SET_C=1   # Run make clean first
                        shift ;;
                -*)
                        echo "Unrecognized argument $1"
                        shift ;;
            esac ;;  
        * ) AMBER_TEST_NAME=$1
            shift ;;
        
    esac
done


if [ $SET_5 == 1 ]; then
    AMBER_CORE="AMBER_A25_CORE"
else    
    if [ $SET_3 == 1 ]; then
        AMBER_CORE="AMBER_A23_CORE"
    else    
        AMBER_CORE="AMBER_A25_CORE"
    fi
fi

echo "AMBER CORE: $AMBER_CORE"



#--------------------------------------------------------
# Compile the test
#--------------------------------------------------------

# First check if its an assembly test
if [ -f ../tests/${AMBER_TEST_NAME}.S ]; then
    # hw-test
    TEST_TYPE=1
elif [ ${AMBER_TEST_NAME} == vmlinux ]; then
    TEST_TYPE=3
elif [ -d ../../sw/${AMBER_TEST_NAME} ]; then
    # Does this test type need the boot-loader ?
    if [ -e ../../sw/${AMBER_TEST_NAME}/sections.lds ]; then
        grep 8000 ../../sw/${AMBER_TEST_NAME}/sections.lds > /dev/null
        if [ $? == 0 ]; then
            # Needs boot loader, starts at 0x8000
            TEST_TYPE=4
        else
            TEST_TYPE=2
        fi
    else
        TEST_TYPE=2
    fi    
else    
    echo "Test ${AMBER_TEST_NAME} not found"
    exit
fi

echo "Test ${AMBER_TEST_NAME}, type $TEST_TYPE"

# Uncompress the vmlinux.mem file
if [ $TEST_TYPE == 3 ]; then
    pushd ../../sw/${AMBER_TEST_NAME} > /dev/null
    if [ ! -e vmlinux.mem ]; then 
        bzip2 -dk vmlinux.mem.bz2
        bzip2 -dk vmlinux.dis.bz2
    fi
    popd > /dev/null
fi

    
# Now compile the test
if [ $TEST_TYPE == 1 ]; then
    # hw assembly test
    echo "Compile ../tests/${AMBER_TEST_NAME}.S"
    pushd ../tests > /dev/null
    if [ $SET_C == 1 ]; then
        make --quiet clean
    fi
    make --quiet TEST=${AMBER_TEST_NAME}
    MAKE_STATUS=$?
        
    popd > /dev/null
    BOOT_MEM_FILE="../tests/${AMBER_TEST_NAME}.mem"
    
    if [ $SET_5 == 1 ]; then
        BOOT_MEM_PARAMS_FILE="../tests/${AMBER_TEST_NAME}_memparams128.v"
    else
        BOOT_MEM_PARAMS_FILE="../tests/${AMBER_TEST_NAME}_memparams32.v"
    fi
    
elif [ $TEST_TYPE == 2 ]; then
    # sw Stand-alone C test
    pushd ../../sw/${AMBER_TEST_NAME} > /dev/null
    if [ $SET_C == 1 ]; then
        make --quiet clean
    fi
    make CPPFLAGS=-DSIM_MODE
    MAKE_STATUS=$?
    popd > /dev/null
    BOOT_MEM_FILE="../../sw/${AMBER_TEST_NAME}/${AMBER_TEST_NAME}.mem"
    if [ $SET_5 == 1 ]; then
        BOOT_MEM_PARAMS_FILE="../../sw/${AMBER_TEST_NAME}/${AMBER_TEST_NAME}_memparams128.v"
    else
        BOOT_MEM_PARAMS_FILE="../../sw/${AMBER_TEST_NAME}/${AMBER_TEST_NAME}_memparams32.v"
    fi

elif [ $TEST_TYPE == 3 ] || [ $TEST_TYPE == 4 ]; then
    # sw test using boot loader
    pushd ../../sw/boot-loader-serial > /dev/null
    if [ $SET_C == 1 ]; then
        make --quiet clean
    fi
    make
    MAKE_STATUS=$?
    popd > /dev/null
    if [ $MAKE_STATUS != 0 ]; then
        echo "Error compiling boot-loader-serial"
        exit 1
    fi
    
    pushd ../../sw/${AMBER_TEST_NAME} > /dev/null
    if [ -e Makefile ]; then
        if [ $SET_C == 1 ]; then
            make --quiet clean
        fi
        make
    fi
    MAKE_STATUS=$?
    popd > /dev/null
    
    BOOT_MEM_FILE="../../sw/boot-loader-serial/boot-loader-serial.mem"
    if [ $SET_5 == 1 ]; then
        BOOT_MEM_PARAMS_FILE="../../sw/boot-loader-serial/boot-loader-serial_memparams128.v"
    else
        BOOT_MEM_PARAMS_FILE="../../sw/boot-loader-serial/boot-loader-serial_memparams32.v"
    fi
    MAIN_MEM_FILE="../../sw/${AMBER_TEST_NAME}/${AMBER_TEST_NAME}.mem"
    AMBER_LOAD_MAIN_MEM="+define+AMBER_LOAD_MAIN_MEM"

else
    echo "Error unrecognized test type"
fi

if [ $MAKE_STATUS != 0 ]; then
    echo "Failed " $AMBER_TEST_NAME " compile error" >> $AMBER_LOG_FILE
    exit
fi
 

NC="ncverilog +ncaccess+r +nclinedebug +ncvpicompat+1364v1995 +nowarnTFNPC \
+nowarnIWFA +nowarnSVTL +nowarnSDFNCAP"
INCA="./INCA_libs" ;

if [ $SET_G == 1 ]; then
	RGUI="+gui"
	RSIM=""
else
	RGUI=""
	RSIM="-run +ncrun"
fi
SIM="${NC} ${RGUI} ${RSIM}"

#--------------------------------------------------------
# NC-Verilog
#--------------------------------------------------------
\rm -rf ${INCA}
${SIM} \
  +define+$AMBER_CORE \
  +define+BOOT_MEM_FILE=\"$BOOT_MEM_FILE\" \
  +define+BOOT_MEM_PARAMS_FILE=\"$BOOT_MEM_PARAMS_FILE\" \
  +define+MAIN_MEM_FILE=\"$MAIN_MEM_FILE\" \
  +define+AMBER_LOG_FILE=\"$AMBER_LOG_FILE\" \
  +define+AMBER_TEST_NAME=\"$AMBER_TEST_NAME\" \
  +define+AMBER_SIM_CTRL=$TEST_TYPE \
  +define+AMBER_TIMEOUT=$AMBER_TIMEOUT \
  $AMBER_LOAD_MAIN_MEM \
  -f amber.rtl.f

if [ $? != 0 ]; then exit; fi


# Set a timeout value for the test if it passed
if [ $TEST_TYPE == 1 ]; then
    tail -1 < ${AMBER_LOG_FILE} | grep Passed > /dev/null
    if [ $? == 0 ]; then 
        TICKS=`tail -1 < ${AMBER_LOG_FILE} | awk '{print $3}'`
        TOTICKS=$(( $TICKS * 4 + 1000 ))
        ../tools/set_timeout.sh ${AMBER_TEST_NAME} $TOTICKS
    else
        # return non-zero on test fail
        exit 1
    fi
fi

