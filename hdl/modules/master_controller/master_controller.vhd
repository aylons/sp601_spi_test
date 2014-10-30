-------------------------------------------------------------------------------
-- Title      : Master controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : master_controller.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2014-10-23
-- Last update: 2014-10-30
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Simple controller for master SPI
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-10-23  1.0      aylons  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity master_controller is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    spi_req_i  : in  std_logic;
    spi_wen_o  : out std_logic;
    count_up_o : out std_logic
    );

end entity master_controller;

architecture str of master_controller is
  signal wen : std_logic := '1';
  
begin  -- architecture str

  send : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        wen   <= '1';
      else
        if spi_req_i = '1' and en_i = '1' then
          wen <= '1';
          if wen = '0' then
            count_up_o <= '1';
          else
            count_up_o <= '0';
          end if;
        else
          wen <= '0';
          count_up_o <= '0';
        end if;
      end if;
    end if;
  end process;

  spi_wen_o  <= wen;
  
end architecture str;

-------------------------------------------------------------------------------
