target = "xilinx"
action = "synthesis"

syn_device = "xc6slx16"
syn_grade = "-2"
syn_package = "csg324"
syn_top = "spi_test_top"
syn_project = "spi_test_top.xise"

modules = {"local": [ "../top" ] };
