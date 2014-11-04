sp601_spi_test
==============

Simplest testbench for checking SPI transmission using  a SP601 board.

This test works by sending increasing numbers from a SPI master to a SPI slave block, routing the SPI signals outside the FPGA. The SPI slave block then checks if the result arrives in the correct order. If any value is skipped or incorrect, the received data is counted as NOK, expected values are counted as OK.

For small values of NOK (less than (2^g_width)-1), the total number of failed transmission may be calculated by subtracting the sender counter from the OK counter. The NOK counter is the number of "skips", as several transmission errors in a row count as just one skip.

The current top module simultaneously tests three links with different clocks: 25MHz, 40MHz and 100MHz. The results can be read using 2 Chipscope ILAs, and the signals are routed through FMC pins. More info in the docs folder.

The SPI core was designed by Jonny Doin and is licensed as LGPL (see full license and readme file in the corresponding folder). The testbench was designed by Aylons and is licensed as GPLv3.
