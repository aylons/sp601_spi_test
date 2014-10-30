-------------------------------------------------------------------------------
-- Title      : Testbench for design "spi_test_top"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spi_test_top_tb.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2014-10-24
-- Last update: 2014-10-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-10-24  1.0      aylons  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity spi_test_top_tb is

end entity spi_test_top_tb;

-------------------------------------------------------------------------------

architecture test of spi_test_top_tb is

  constant input_freq   : real     := 2.0e08;
  constant clock_period : time     := 1.0 sec /(input_freq);
  constant c_width      : positive := 16;

  -- component ports
  signal sys_clk_p_i : std_logic;
  signal sys_clk_n_i : std_logic;
  signal on_sw_i     : std_logic;
  signal rst_i       : std_logic;

  signal spi_sck  : std_logic;
  signal spi_mosi : std_logic;
  signal spi_miso : std_logic;
  signal spi_ssel : std_logic;

  signal nok_o : std_logic_vector(c_width-1 downto 0);
  signal ok_o  : std_logic_vector(c_width-1 downto 0);

  component spi_test_top is
    port (
      sys_clk_p_i : in  std_logic;
      sys_clk_n_i : in  std_logic;
      on_sw_i     : in  std_logic;
      rst_i       : in  std_logic;
      spi_sck_o   : out std_logic;
      spi_mosi_o  : out std_logic;
      spi_miso_i  : in  std_logic;
      spi_ssel_o  : out std_logic;
      spi_sck_i   : in  std_logic;
      spi_mosi_i  : in  std_logic;
      spi_miso_o  : out std_logic;
      spi_ssel_i  : in  std_logic;
      nok_o       : out std_logic_vector(c_width-1 downto 0);
      ok_o        : out std_logic_vector(c_width-1 downto 0));
  end component spi_test_top;
  
begin  -- architecture test

  clk_gen : process
  begin
    sys_clk_n_i <= '0';
    sys_clk_p_i <= '1';
    wait for clock_period/2.0;

    sys_clk_n_i <= '1';
    sys_clk_p_i <= '0';
    wait for clock_period/2.0;
  end process;

  on_sw_i <= '1';
  rst_i   <= '0';

  -- component instantiation
  uut : spi_test_top
    port map (
      sys_clk_p_i => sys_clk_p_i,
      sys_clk_n_i => sys_clk_n_i,
      spi_sck_o   => spi_sck,
      spi_mosi_o  => spi_mosi,
      spi_miso_i  => spi_miso,
      spi_ssel_o  => spi_ssel,
      spi_sck_i   => spi_sck,
      spi_mosi_i  => spi_mosi,
      spi_miso_o  => spi_miso,
      spi_ssel_i  => spi_ssel,
      nok_o       => nok_o,
      ok_o        => ok_o,
      on_sw_i     => on_sw_i,
      rst_i       => rst_i);

end architecture test;

