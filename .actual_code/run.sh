ghdl -a -fsynopsys TopLevel.vhdl
ghdl -a -fsynopsys TopLevel_tb.vhdl
ghdl -e -fsynopsys TopLevel_tb
ghdl -r -fsynopsys TopLevel_tb --vcd=TopLevel_tb.vcd