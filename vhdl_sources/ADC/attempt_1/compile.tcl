

vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/SAR_ADC.vhd
vcom -reportprogress 300 -work work D:/Documenti/GitHub/EFES_project/vhdl_sources/ADC/adc_test.vhd

vsim work.adc_test -t 10ps

add wave -position insertpoint sim:/adc_test/*
add wave -position insertpoint sim:/adc_test/adc/*

run 400 ns