
out/elab.il: hsl_to_rgb.v
	yosys -p "read_verilog hsl_to_rgb.v top.v; proc; write_rtlil out/elab.il;"

out/log.txt: out/elab.il
	yosys -p "read_verilog hsl_to_rgb.v; hierarchy -top hue_sweep; prep; write_rtlil out/hue_sweep.il"
	# -Q -T: suppress banner and footer in log output
	yosys -Q -T \
		-p "read_rtlil out/hue_sweep.il; sim -clock clk -n 511 -q" \
		> out/log.txt

out/hue_sweep.png: out/log.txt
	gnuplot -e "set terminal png; \
		plot 'out/log.txt' using 1:2 linecolor rgb 'red' title 'r', \
		'out/log.txt' using 1:3 linecolor rgb 'green' title 'g', \
		'out/log.txt' using 1:4 linecolor rgb 'blue' title 'b'" > out/hue_sweep.png
