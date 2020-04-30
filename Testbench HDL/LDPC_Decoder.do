onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_decoder/test/clk
add wave -noupdate /test_decoder/test/rstb
add wave -noupdate /test_decoder/test/error_data
add wave -noupdate /test_decoder/test/dec_done
add wave -noupdate /test_decoder/test/output_data
add wave -noupdate /test_decoder/test/current_state
add wave -noupdate /test_decoder/test/next_state
add wave -noupdate /test_decoder/test/pcheck1
add wave -noupdate /test_decoder/test/pcheck2
add wave -noupdate /test_decoder/test/pcheck3
add wave -noupdate /test_decoder/test/pcheck4
add wave -noupdate /test_decoder/test/pcheck5
add wave -noupdate /test_decoder/test/dec_code
add wave -noupdate /test_decoder/test/mp_code
add wave -noupdate /test_decoder/test/idata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 208
configure wave -valuecolwidth 82
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
WaveRestoreZoom {0 ps} {244224 ps}
