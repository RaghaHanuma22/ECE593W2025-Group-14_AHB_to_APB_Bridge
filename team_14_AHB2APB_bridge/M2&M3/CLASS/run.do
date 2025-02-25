vlog -cover sbfcet top.sv

vsim -coverage work.ahb_apb_top -voptargs="+cover=sbfcet"

run -all


# Save coverage data
coverage save coverage_data.ucdb

# Generate code coverage report
vcover report -code sbcfet coverage_data.ucdb -output code_coverage.txt \
	-du=ahb_apb_top -du=top_sv_unit

# Generate functional coverage report
vcover report -details -cvg coverage_data.ucdb -output functional_coverage.txt
