vlib work

vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/attempt_3/counter.vhd
vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/attempt_3/mask_reg.vhd
vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/attempt_3/register_Nbit.vhd
vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/attempt_3/SAR_CU.vhd
vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/attempt_3/final_reg.vhd
vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/attempt_3/SAR_DP.vhd
vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/attempt_3/SAR_ADC.vhd
vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/attempt_3/adc_test.vhd

vsim work.adc_test -t 10ps

add wave -position insertpoint sim:/adc_test/*
add wave -position insertpoint sim:/adc_test/adc/*

run 500 ns