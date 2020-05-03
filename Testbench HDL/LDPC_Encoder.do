onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_encoder/test/clk
add wave -noupdate /test_encoder/test/rstb
add wave -noupdate /test_encoder/test/isop
add wave -noupdate /test_encoder/test/ivalid
add wave -noupdate /test_encoder/test/input_data
add wave -noupdate /test_encoder/test/edone
add wave -noupdate /test_encoder/test/code_data
add wave -noupdate /test_encoder/test/current_state
add wave -noupdate /test_encoder/test/next_state
add wave -noupdate /test_encoder/test/odata_i
add wave -noupdate /test_encoder/test/verify_code
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {139932 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 209
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
WaveRestoreZoom {0 ps} {119296 ps}
