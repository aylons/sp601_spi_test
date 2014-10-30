-------------------------------------------------------------------------------
-- Title      : Slave checker
-- Project    : 
-------------------------------------------------------------------------------
-- File       : slave_checker.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2014-10-23
-- Last update: 2014-10-30
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Checks if slave is receiving incremental data and output the result
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

-------------------------------------------------------------------------------

entity slave_checker is

  generic (
    g_width : natural := 16
    );

  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    spi_valid_i : in  std_logic;
    data_i      : in  std_logic_vector(g_width-1 downto 0);
    ok_o        : out std_logic;
    nok_o       : out std_logic
    );

end entity slave_checker;

-------------------------------------------------------------------------------

architecture str of slave_checker is
  signal valid_d : std_logic;
begin  -- architecture str

  getdata : process(clk_i)
    variable cur_data  : unsigned(g_width-1 downto 0);
    variable prev_data : unsigned(g_width-1 downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        prev_data := (others => '0');
        valid_d   <= '0';
      else
        cur_data := unsigned(data_i);

        -- valid from spi slave is active for 2 cycles, get only the first
        if(spi_valid_i = '1' and valid_d = '0') then
          if cur_data = prev_data then
            ok_o <= '1';
          else
            nok_o <= '1';
          end if;

          prev_data := cur_data + 1;
        else
          ok_o  <= '0';
          nok_o <= '0';
        end if;  -- newdata

        valid_d <= spi_valid_i;
      end if;  --rst
    end if;  -- clk_i
  end process;

end architecture str;
