ghdl -a math_problem_generator.vhdl
ghdl -a uart_receiver.vhdl
ghdl -a TopLevel.vhdl
ghdl -a TopLevel_tb.vhdl
ghdl -e TopLevel_tb
ghdl -r TopLevel_tb --vcd=TopLevel_tb.vcd