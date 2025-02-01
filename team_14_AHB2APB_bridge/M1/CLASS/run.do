vlog *.sv

vsim -voptargs="+acc" work.top 

add wave -position end  sim:/top/clk
add wave -position end  sim:/top/hresetn
add wave -position end  sim:/top/hb/haddr
add wave -position end  sim:/top/hb/paddr
add wave -position end  sim:/top/hb/hwrite
add wave -position end  sim:/top/hb/pwrite
add wave -position end  sim:/top/hb/hwdata
add wave -position end  sim:/top/hb/pwdata
add wave -position end  sim:/top/hb/hburst
add wave -position end  sim:/top/hb/hrdata
add wave -position end  sim:/top/hb/prdata
add wave -position end  sim:/top/hb/hreadyin
add wave -position end  sim:/top/hb/hreadyout

run -all
