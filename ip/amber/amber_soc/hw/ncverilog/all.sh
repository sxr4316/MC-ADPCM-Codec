#!/bin/bash 

#--------------------------------------------------------------#
#                                                              #
#  all.sh                                                      #
#                                                              #
#  This file is part of the Amber project                      #
#  http://www.opencores.org/project,amber                      #
#                                                              #
#  Description                                                 #
#  Runa list of tests from the $AMBER_BASE/hw/tests directory  #
#                                                              #
#  Author(s):                                                  #
#      - Conor Santifort, santifort@opencores.org              #
#                                                              #
#//////////////////////////////////////////////////////////////#
#                                                              #
# Copyright (C) 2010 Authors and OPENCORES.ORG                 #
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
set -e 

echo "-----------------------" >> tests.log
echo `date` >> tests.log

for i in `ls ../tests/*.S`; do
    filename=${i##*/}
    testname=${filename%.*}
    echo "Run test ${testname}"
    ./run_nc.sh ${testname} $1 $2
done

