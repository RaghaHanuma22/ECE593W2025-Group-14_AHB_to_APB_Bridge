vlog -cover sbfcet ahb_interface.sv apb_interface.sv DUT.sv  tb_top.sv

vsim -coverage work.tb_top -voptargs="+cover=sbfcet"

run -all

# Save coverage data
coverage save coverage_data.ucdb

# Generate code coverage report
vcover report -code sbcfet coverage_data.ucdb -output code_coverage.txt \
	-du=tb_top -du=Bridge_Top

# Generate functional coverage report
vcover report -details -cvg coverage_data.ucdb -output functional_coverage.txt
