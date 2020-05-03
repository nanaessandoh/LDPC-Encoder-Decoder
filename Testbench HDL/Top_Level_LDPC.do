onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_top_level/test/clk
add wave -noupdate /test_top_level/test/rstb
add wave -noupdate /test_top_level/test/isop
add wave -noupdate /test_top_level/test/ivalid
add wave -noupdate /test_top_level/test/input_data
add wave -noupdate /test_top_level/test/dec_done
add wave -noupdate /test_top_level/test/output_data
add wave -noupdate /test_top_level/test/code_data_i
add wave -noupdate /test_top_level/test/error_data_i
add wave -noupdate /test_top_level/test/edone_i
add wave -noupdate /test_top_level/test/edone_ii
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1999294 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {238080 ps}
