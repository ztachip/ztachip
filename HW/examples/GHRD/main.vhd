library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity zta is
    -- generic(EXMEM_DATA_WIDTH : integer);
    Port (
        -- External memory data bus is 64/32-bit wide
        -- This should match with exmem_data_width_c defined in HW/src/config.vhd
        -- EXMEM_DATA_WIDTH : out STD_LOGIC_VECTOR(63 downto 0);
        -- EXMEM_DATA_WIDTH : out STD_LOGIC_VECTOR(31 downto 0);
        
        -- Options for RISCV_MODE: 
        -- "RISCV_XILINX_BSCAN2_JTAG" means RISCV is booted using Xilinx built-in JTAG
        -- "RISCV_JTAG" means RISCV is booted using an external JTAG adapter
        -- "RISCV_SIM" means RISCV is running in simulation mode.
        -- RISCV_MODE : in STRING;

        -- Reference clock/external reset
        sys_resetn : in STD_LOGIC;
        sys_clock : in STD_LOGIC;

        -- DDR signals
        ddr3_sdram_addr : out STD_LOGIC_VECTOR(13 downto 0);
        ddr3_sdram_ba : out STD_LOGIC_VECTOR(2 downto 0);
        ddr3_sdram_cas_n : out STD_LOGIC;
        ddr3_sdram_ck_n : out STD_LOGIC_VECTOR(0 downto 0);
        ddr3_sdram_ck_p : out STD_LOGIC_VECTOR(0 downto 0);
        ddr3_sdram_cke : out STD_LOGIC_VECTOR(0 downto 0);
        ddr3_sdram_cs_n : out STD_LOGIC_VECTOR(0 downto 0);
        ddr3_sdram_dm : out STD_LOGIC_VECTOR(1 downto 0);
        ddr3_sdram_dq : inout STD_LOGIC_VECTOR(15 downto 0);
        ddr3_sdram_dqs_n : inout STD_LOGIC_VECTOR(1 downto 0);
        ddr3_sdram_dqs_p : inout STD_LOGIC_VECTOR(1 downto 0);
        ddr3_sdram_odt : out STD_LOGIC_VECTOR(0 downto 0);
        ddr3_sdram_ras_n : out STD_LOGIC;
        ddr3_sdram_reset_n : out STD_LOGIC;
        ddr3_sdram_we_n : out STD_LOGIC;

        -- UART signals
        UART_TXD : out STD_LOGIC;
        UART_RXD : in STD_LOGIC;

        -- GPIO signals
        led : out STD_LOGIC_VECTOR(3 downto 0);
        pushbutton : in STD_LOGIC_VECTOR(3 downto 0);

        -- VGA signals
        VGA_HS_O : out STD_LOGIC;
        VGA_VS_O : out STD_LOGIC;
        VGA_R : out STD_LOGIC_VECTOR(3 downto 0);
        VGA_B : out STD_LOGIC_VECTOR(3 downto 0);
        VGA_G : out STD_LOGIC_VECTOR(3 downto 0);

        -- CAMERA signals
        CAMERA_SCL : out STD_LOGIC;
        CAMERA_VS : in STD_LOGIC;
        CAMERA_PCLK : in STD_LOGIC;
        CAMERA_D : in STD_LOGIC_VECTOR(7 downto 0);
        CAMERA_RESET : out STD_LOGIC;
        CAMERA_SDR : inout STD_LOGIC;
        CAMERA_RS : in STD_LOGIC;
        CAMERA_MCLK : out STD_LOGIC;
        CAMERA_PWDN : out STD_LOGIC
    );
end zta;

architecture arch of zta is
    -- Declaration of constants, signals and components as needed

    constant EXMEM_DATA_WIDTH: integer := 32;
        -- Other Option is 64 (for a wider bus width)

    constant RISCV_MODE: string := "RISCV_XILINX_BSCAN2_JTAG"
        -- Options for RISCV_MODE: 
        -- "RISCV_XILINX_BSCAN2_JTAG" means RISCV is booted using Xilinx built-in JTAG
        -- "RISCV_JTAG" means RISCV is booted using an external JTAG adapter
        -- "RISCV_SIM" means RISCV is running in simulation mode.

    -- SIGNALS
    signal SDRAM_clk : STD_LOGIC;
    signal SDRAM_araddr : STD_LOGIC_VECTOR(31 downto 0);
    signal SDRAM_arburst : STD_LOGIC_VECTOR(1 downto 0);
    signal SDRAM_arlen : STD_LOGIC_VECTOR(7 downto 0);
    signal SDRAM_arready : STD_LOGIC;
    signal SDRAM_arsize : STD_LOGIC_VECTOR(2 downto 0);
    signal SDRAM_arvalid : STD_LOGIC;
    signal SDRAM_awaddr : STD_LOGIC_VECTOR(31 downto 0);
    signal SDRAM_awburst : STD_LOGIC_VECTOR(1 downto 0);
    signal SDRAM_awlen : STD_LOGIC_VECTOR(7 downto 0);
    signal SDRAM_awready : STD_LOGIC;
    signal SDRAM_awsize : STD_LOGIC_VECTOR(2 downto 0);
    signal SDRAM_awvalid : STD_LOGIC;
    signal SDRAM_bready : STD_LOGIC;
    signal SDRAM_bresp : STD_LOGIC_VECTOR(1 downto 0);
    signal SDRAM_bvalid : STD_LOGIC;
    signal SDRAM_rlast : STD_LOGIC;
    signal SDRAM_rready : STD_LOGIC;
    signal SDRAM_rresp : STD_LOGIC_VECTOR(1 downto 0);
    signal SDRAM_rvalid : STD_LOGIC;
    signal SDRAM_wlast : STD_LOGIC;
    signal SDRAM_wready : STD_LOGIC;
    signal SDRAM_wvalid : STD_LOGIC;

    signal SDRAM_rdata : STD_LOGIC_VECTOR(EXMEM_DATA_WIDTH-1 downto 0);
    signal SDRAM_wdata : STD_LOGIC_VECTOR(EXMEM_DATA_WIDTH-1 downto 0);
    signal SDRAM_wstrb : STD_LOGIC_VECTOR(EXMEM_DATA_WIDTH/8-1 downto 0);

    signal VIDEO_tdata : STD_LOGIC_VECTOR(31 downto 0);
    signal VIDEO_tlast : STD_LOGIC;
    signal VIDEO_tready : STD_LOGIC;
    signal VIDEO_tvalid : STD_LOGIC;

    signal camera_tdata : STD_LOGIC_VECTOR(31 downto 0);
    signal camera_tlast : STD_LOGIC;
    signal camera_tready : STD_LOGIC;
    signal camera_tuser : STD_LOGIC_VECTOR(0 downto 0);
    signal camera_tvalid : STD_LOGIC;

    signal APB_PADDR : STD_LOGIC_VECTOR(19 downto 0);
    signal APB_PENABLE : STD_LOGIC;
    signal APB_PREADY : STD_LOGIC;
    signal APB_PWRITE : STD_LOGIC;
    signal APB_PWDATA : STD_LOGIC_VECTOR(31 downto 0);
    signal APB_PRDATA : STD_LOGIC_VECTOR(31 downto 0);
    signal APB_PSLVERROR : STD_LOGIC;


   -- COMPONENTS

    COMPONENT soc_base
    GENERIC (
        RISCV: RISCV_MODE
        -- Options: 
        -- "RISCV_XILINX_BSCAN2_JTAG" means RISCV is booted using Xilinx built-in JTAG
        -- "RISCV_JTAG" means RISCV is booted using an external JTAG adapter
        -- "RISCV_SIM" means RISCV is running in simulation mode.
    );
    PORT (
        -- Reference clock/external reset
        clk_main        :IN STD_LOGIC;
        clk_x2_main     :IN STD_LOGIC;
        clk_reset       :IN STD_LOGIC;

        -- JTAG signals
        TMS             :IN STD_LOGIC:='0';
        TDI             :IN STD_LOGIC:='0';
        TDO             :OUT STD_LOGIC;
        TCK             :IN STD_LOGIC:='0';

        -- SDRAM axi signals
        SDRAM_clk       :IN STD_LOGIC;
        SDRAM_reset     :IN STD_LOGIC;
        SDRAM_araddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
        SDRAM_arburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
        SDRAM_arlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
        SDRAM_arready   :IN STD_LOGIC;
        SDRAM_arsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
        SDRAM_arvalid   :OUT STD_LOGIC;
        SDRAM_awaddr    :OUT STD_LOGIC_VECTOR(31 downto 0);
        SDRAM_awburst   :OUT STD_LOGIC_VECTOR(1 downto 0);
        SDRAM_awlen     :OUT STD_LOGIC_VECTOR(7 downto 0);
        SDRAM_awready   :IN STD_LOGIC;
        SDRAM_awsize    :OUT STD_LOGIC_VECTOR(2 downto 0);
        SDRAM_awvalid   :OUT STD_LOGIC;
        SDRAM_bready    :OUT STD_LOGIC;
        SDRAM_bresp     :IN STD_LOGIC_VECTOR(1 downto 0);
        SDRAM_bvalid    :IN STD_LOGIC;
        SDRAM_rdata     :IN STD_LOGIC_VECTOR(exmem_data_width_c-1 downto 0);
        SDRAM_rlast     :IN STD_LOGIC;
        SDRAM_rready    :OUT STD_LOGIC;
        SDRAM_rresp     :IN STD_LOGIC_VECTOR(1 downto 0);
        SDRAM_rvalid    :IN STD_LOGIC;
        SDRAM_wdata     :OUT STD_LOGIC_VECTOR(exmem_data_width_c-1 downto 0);
        SDRAM_wlast     :OUT STD_LOGIC;
        SDRAM_wready    :IN STD_LOGIC;
        SDRAM_wstrb     :OUT STD_LOGIC_VECTOR(exmem_data_width_c/8-1 downto 0);
        SDRAM_wvalid    :OUT STD_LOGIC;

        -- APB bus signals
        APB_PADDR       :INOUT STD_LOGIC_VECTOR(19 downto 0);
        APB_PENABLE     :INOUT STD_LOGIC;
        APB_PREADY      :INOUT STD_LOGIC;
        APB_PWRITE      :INOUT STD_LOGIC;
        APB_PWDATA      :INOUT STD_LOGIC_VECTOR(31 downto 0);
        APB_PRDATA      :INOUT STD_LOGIC_VECTOR(31 downto 0);
        APB_PSLVERROR   :INOUT STD_LOGIC;

        -- VIDEO streaming bus  
        VIDEO_clk       :IN STD_LOGIC;
        VIDEO_tdata     :OUT STD_LOGIC_VECTOR(31 downto 0);
        VIDEO_tlast     :OUT STD_LOGIC;
        VIDEO_tready    :IN STD_LOGIC;
        VIDEO_tvalid    :OUT STD_LOGIC;

        -- Camera streaming bus
        camera_clk      :IN STD_LOGIC;
        camera_tdata    :IN STD_LOGIC_VECTOR(31 downto 0);
        camera_tlast    :IN STD_LOGIC;
        camera_tready   :OUT STD_LOGIC;
        camera_tvalid   :IN STD_LOGIC
    );
    END COMPONENT;


    COMPONENT VGA
    PORT (
        signal clk_in        : in  STD_LOGIC;
        signal tdata_in      : in  STD_LOGIC_VECTOR(31 downto 0);
        signal tready_out    : out STD_LOGIC;  
        signal tvalid_in     : in  STD_LOGIC;
        signal tlast_in      : in  STD_LOGIC;
        
        signal VGA_HS_O_out  : out STD_LOGIC;
        signal VGA_VS_O_out  : out STD_LOGIC;
        signal VGA_R_out     : out STD_LOGIC_VECTOR(3 downto 0);
        signal VGA_B_out     : out STD_LOGIC_VECTOR(3 downto 0);
        signal VGA_G_out     : out STD_LOGIC_VECTOR(3 downto 0)
    );
    END COMPONENT;

    
    COMPONENT UART
    GENERIC (
        BAUD_RATE: 115200,
        CLOCK_FREQUENCY: 125000000
    );
    PORT ( 
        signal clock_in              : IN  STD_LOGIC;
        signal reset_in              : IN  STD_LOGIC;
        signal uart_rx_in            : IN  STD_LOGIC;
        signal uart_tx_out           : OUT  STD_LOGIC;

        signal apb_paddr             : IN STD_LOGIC_VECTOR(19 downto 0);
        signal apb_penable           : IN STD_LOGIC;
        signal apb_pready            : OUT STD_LOGIC;
        signal apb_pwrite            : IN STD_LOGIC;
        signal apb_pwdata            : IN STD_LOGIC_VECTOR(31 downto 0);
        signal apb_prdata            : OUT STD_LOGIC_VECTOR(31 downto 0);
        signal apb_pslverror         : OUT STD_LOGIC
    );
    END COMPONENT;


    COMPONENT GPIO
    PORT (
        signal clock_in              : IN STD_LOGIC;
        signal reset_in              : IN STD_LOGIC;

        signal apb_paddr             : IN STD_LOGIC_VECTOR(19 downto 0);
        signal apb_penable           : IN STD_LOGIC;
        signal apb_pready            : OUT STD_LOGIC;
        signal apb_pwrite            : IN STD_LOGIC;
        signal apb_pwdata            : IN STD_LOGIC_VECTOR(31 downto 0);
        signal apb_prdata            : OUT STD_LOGIC_VECTOR(31 downto 0);
        signal apb_pslverror         : OUT STD_LOGIC;

        signal led_out               : OUT STD_LOGIC_VECTOR(3 downto 0);
        signal button_in             : IN STD_LOGIC_VECTOR(3 downto 0)       
    );
    END COMPONENT;


    COMPONENT CAMERA
    PORT (
        clk_in      : in STD_LOGIC;
        SIOC        : out STD_LOGIC;
        SIOD        : inout STD_LOGIC;
        RESET       : out STD_LOGIC;
        PWDN        : out STD_LOGIC;
        XCLK        : out STD_LOGIC;
        
        CAMERA_PCLK : in STD_LOGIC;           
        CAMERA_D    : in STD_LOGIC_VECTOR(7 downto 0);
        CAMERA_VS   : in STD_LOGIC;
        CAMERA_RS   : in STD_LOGIC;
        tdata_out   : out STD_LOGIC_VECTOR(31 downto 0);
        tlast_out   : out STD_LOGIC;
        tready_in   : in STD_LOGIC;
        tuser_out   : out STD_LOGIC_VECTOR(0 downto 0);
        tvalid_out  : out STD_LOGIC
    );
    END COMPONENT;


    COMPONENT TIME
    PORT (
        signal clock_in              : IN STD_LOGIC;
        signal reset_in              : IN STD_LOGIC;

        signal apb_paddr             : IN STD_LOGIC_VECTOR(19 downto 0);
        signal apb_penable           : IN STD_LOGIC;
        signal apb_pready            : OUT STD_LOGIC;
        signal apb_pwrite            : IN STD_LOGIC;
        signal apb_pwdata            : IN STD_LOGIC_VECTOR(31 downto 0);
        signal apb_prdata            : OUT STD_LOGIC_VECTOR(31 downto 0);
        signal apb_pslverror         : OUT STD_LOGIC   
    );
    END COMPONENT;


begin
    -- Implementation of the main module functionality

end arch;
