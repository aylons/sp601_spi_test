-------------------------------------------------------------------------------
-- Title      : Top module for SPI test
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spi_test_top.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2014-10-23
-- Last update: 2014-11-01
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top module for SPI test. Outputs may be connected directly to pins
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

entity spi_test_top is
  port(
    sys_clk_p_i : in  std_logic;
    sys_clk_n_i : in  std_logic;
    on_sw_i     : in  std_logic;
    on_led_o    : out std_logic;
    rst_i       : in  std_logic;

    --master_1
    spi1_sck_o  : out std_logic;
    spi1_mosi_o : out std_logic;
    spi1_miso_i : in  std_logic;
    spi1_ssel_o : out std_logic;

    --slave_1
    spi1_sck_i  : in  std_logic;
    spi1_mosi_i : in  std_logic;
    spi1_miso_o : out std_logic;
    spi1_ssel_i : in  std_logic;

    --master_2
    spi2_sck_o  : out std_logic;
    spi2_mosi_o : out std_logic;
    spi2_miso_i : in  std_logic;
    spi2_ssel_o : out std_logic;

    --slave_2
    spi2_sck_i  : in  std_logic;
    spi2_mosi_i : in  std_logic;
    spi2_miso_o : out std_logic;
    spi2_ssel_i : in  std_logic;

    --master_3
    spi3_sck_o  : out std_logic;
    spi3_mosi_o : out std_logic;
    spi3_miso_i : in  std_logic;
    spi3_ssel_o : out std_logic;

    --slave_3
    spi3_sck_i  : in  std_logic;
    spi3_mosi_i : in  std_logic;
    spi3_miso_o : out std_logic;
    spi3_ssel_i : in  std_logic
    );

end entity spi_test_top;

architecture structural of spi_test_top is

  constant c_width : positive := 16;

  -- service signals
  signal clk_200M, clk_80M, clk_50M : std_logic;
  signal locked                     : std_logic;
  signal reset                      : std_logic := '0';
  signal reset_n                    : std_logic := '1';

-- debugging
  signal control1, control2, control3 : std_logic_vector(35 downto 0);

  component spi_single_test is
    generic (
      g_width : positive);
    port (
      clk_i             : in  std_logic;
      rst_i             : in  std_logic;
      spi_sck_o         : out std_logic;
      spi_mosi_o        : out std_logic;
      spi_miso_i        : in  std_logic;
      spi_ssel_o        : out std_logic;
      spi_sck_i         : in  std_logic;
      spi_mosi_i        : in  std_logic;
      spi_miso_o        : out std_logic;
      spi_ssel_i        : in  std_logic;
      chipscope_control : out std_logic_vector(35 downto 0));
  end component spi_single_test;

  component clk_wiz_v3_3 is
    port (
      CLK_IN_P : in  std_logic;
      CLK_IN_N : in  std_logic;
      CLK_200M : out std_logic;
      CLK_80M  : out std_logic;
      CLK_50M  : out std_logic;
      reset_i  : in  std_logic;
      locked_o : out std_logic);
  end component clk_wiz_v3_3;

  component reset_dcm is
    generic (
      cycles : positive);
    port (
      clk      : in  std_logic;
      locked_i : in  std_logic;
      reset_o  : out std_logic);
  end component reset_dcm;

  component chipscope_icon is
    port (
      CONTROL0 : inout std_logic_vector(35 downto 0);
      CONTROL1 : inout std_logic_vector(35 downto 0);
      CONTROL2 : inout std_logic_vector(35 downto 0));
  end component chipscope_icon;

begin

  on_led_o <= on_sw_i;

  cmp_dcm : clk_wiz_v3_3
    port map (
      CLK_IN_P => sys_clk_p_i,
      CLK_IN_N => sys_clk_n_i,
      CLK_200M => clk_200M,
      CLK_80M  => clk_80M,
      CLK_50M  => clk_50M,
      reset_i  => rst_i,
      locked_o => locked);

  cmp_reset_dcm : reset_dcm
    generic map (
      cycles => 100)
    port map (
      clk      => clk_50M,
      locked_i => locked,
      reset_o  => reset);

  cmp_spi_single_test_1 : spi_single_test
    generic map (
      g_width => c_width)
    port map (
      clk_i             => clk_200M,
      rst_i             => reset,
      spi_sck_o         => spi1_sck_o,
      spi_mosi_o        => spi1_mosi_o,
      spi_miso_i        => spi1_miso_i,
      spi_ssel_o        => spi1_ssel_o,
      spi_sck_i         => spi1_sck_i,
      spi_mosi_i        => spi1_mosi_i,
      spi_miso_o        => spi1_miso_o,
      spi_ssel_i        => spi1_ssel_i,
      chipscope_control => control1);

  cmp_spi_single_test_2 : spi_single_test
    generic map (
      g_width => c_width)
    port map (
      clk_i             => clk_80M,
      rst_i             => reset,
      spi_sck_o         => spi2_sck_o,
      spi_mosi_o        => spi2_mosi_o,
      spi_miso_i        => spi2_miso_i,
      spi_ssel_o        => spi2_ssel_o,
      spi_sck_i         => spi2_sck_i,
      spi_mosi_i        => spi2_mosi_i,
      spi_miso_o        => spi2_miso_o,
      spi_ssel_i        => spi2_ssel_i,
      chipscope_control => control2);

  cmp_spi_single_test_3 : spi_single_test
    generic map (
      g_width => c_width)
    port map (
      clk_i             => clk_50M,
      rst_i             => reset,
      spi_sck_o         => spi3_sck_o,
      spi_mosi_o        => spi3_mosi_o,
      spi_miso_i        => spi3_miso_i,
      spi_ssel_o        => spi3_ssel_o,
      spi_sck_i         => spi3_sck_i,
      spi_mosi_i        => spi3_mosi_i,
      spi_miso_o        => spi3_miso_o,
      spi_ssel_i        => spi3_ssel_i,
      chipscope_control => control3);

  cmp_icon : chipscope_icon
    port map (
      CONTROL0 => control1,
      CONTROL1 => control2,
      CONTROL2 => control3);

end architecture structural;
