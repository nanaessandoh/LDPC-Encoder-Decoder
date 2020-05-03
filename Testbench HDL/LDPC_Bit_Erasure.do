onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_bit_erasure/test/clk
add wave -noupdate /test_bit_erasure/test/rstb
add wave -noupdate /test_bit_erasure/test/code_data
add wave -noupdate /test_bit_erasure/test/edone
add wave -noupdate /test_bit_erasure/test/error_data
add wave -noupdate /test_bit_erasure/test/current_state
add wave -noupdate /test_bit_erasure/test/next_state
add wave -noupdate /test_bit_erasure/test/error1
add wave -noupdate /test_bit_erasure/test/error2
add wave -noupdate /test_bit_erasure/test/error3
add wave -noupdate /test_bit_erasure/test/code_data_i
add wave -noupdate /test_bit_erasure/test/code_data_s
add wave -noupdate /test_bit_erasure/test/count1
add wave -noupdate /test_bit_erasure/test/count2
add wave -noupdate /test_bit_erasure/test/count3
add wave -noupdate /test_bit_erasure/test/count
add wave -noupdate /test_bit_erasure/test/verify_code
add wave -noupdate /test_bit_erasure/test/gen_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 230
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
WaveRestoreZoom {0 ps} {232448 ps}
