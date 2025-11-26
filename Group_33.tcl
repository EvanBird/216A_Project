################################################################################
# DESIGN COMPILER:  Logic Synthesis Tool                                       #
################################################################################
remove_design -all

# Add search paths for our technology libs.
set search_path "$search_path . /w/apps4/Synopsys/TSMC/CAD_TSMC-16-ADFP-FFC_Muse/Executable_Package/Collaterals/IP/stdcell/N16ADFP_StdCell/NLDM"
set target_library "N16ADFP_StdCellss0p72v125c.db"
set link_library "* N16ADFP_StdCellff0p88vm40c.db N16ADFP_StdCellss0p72v125c.db dw_foundation.sldb"
set synthetic_library "dw_foundation.sldb"

set_min_library "N16ADFP_StdCellff0p88vm40c.db" -min_version "N16ADFP_StdCellss0p72v125c.db"

# Define work path (note: The work path must exist, so you need to create a folder WORK first)
define_design_lib WORK -path ./WORK
set alib_library_analysis_path "./alib-52/"

# Read the gate-level verilog files
analyze -format verilog {M216A_TopModule.v M216A_Core.v}
set DESIGN_NAME M216A_TopModule

elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link


set_operating_conditions -min ff0p88vm40c -max ss0p72v125c


# Describe the clock waveform & setup operating conditions
# Change the Tclk to correct frequency
set Tclk 2.0
# Keep uncertainty as x/80
set TCU  0.025
set IN_DEL 0.6
set IN_DEL_MIN 0.3
set OUT_DEL 0.6
set OUT_DEL_MIN 0.3
set ALL_IN_BUT_CLK [remove_from_collection [all_inputs] "clk"]

create_clock -name "clk" -period $Tclk [get_ports "clk"]
set_fix_hold clk
set_dont_touch_network [get_clocks "clk"]
set_clock_uncertainty $TCU [get_clocks "clk"]

set_input_delay $IN_DEL -clock "clk" $ALL_IN_BUT_CLK
set_input_delay -min $IN_DEL_MIN -clock "clk" $ALL_IN_BUT_CLK
set_output_delay $OUT_DEL -clock "clk" [all_outputs]
set_output_delay -min $OUT_DEL_MIN -clock "clk" [all_outputs]

set_max_area 0.0


ungroup -flatten -all
uniquify

compile -only_design_rule
compile -map high
compile -boundary_optimization
compile -only_hold_time

report_timing -path full -delay min -max_paths 10 -nworst 2 > Design.holdtiming
report_timing -path full -delay max -max_paths 10 -nworst 2 > Design.setuptiming
report_area -hierarchy > Design.area
report_power -hier -hier_level 2 > Design.power
report_resources > Design.resources
report_constraint -verbose > Design.constraint
check_design > Design.check_design
check_timing > Design.check_timing

write -hierarchy -format verilog -output $DESIGN_NAME.vg
write_sdf -version 1.0 -context verilog $DESIGN_NAME.sdf
set_propagated_clock [all_clocks]
write_sdc $DESIGN_NAME.sdc
