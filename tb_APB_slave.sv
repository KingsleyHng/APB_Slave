`timescale 1ns / 1ps
module tb_APB_slave;

  // Parameters
  parameter ADDR_WIDTH = 8;
  parameter DATA_WIDTH = 32;

  // Signals
  reg                     PCLK;
  reg                     PRESETn;
  reg                     PSEL;
  reg                     PENABLE;
  reg                     PWRITE;
  reg  [ADDR_WIDTH-1:0]   PADDR;
  reg  [DATA_WIDTH-1:0]   PWDATA;
  wire [DATA_WIDTH-1:0]   PRDATA;
  wire                    PREADY;

  // Instantiate the APB slave module
  APB_Slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY)
  );

  // Clock generation
  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK; // 100MHz clock
  end


    task initialization;
        begin
            PRESETn = 0;
            PSEL = 0;
            PENABLE = 0;
            PWRITE = 0;
            PADDR = 0;
            PWDATA = 0;
            #15;
            PRESETn = 1;
        end
    endtask

    task apb_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            PSEL = 1;
            PWRITE = 1;
            PADDR = addr;
            PWDATA = data;
            @(posedge PCLK);
            PENABLE = 1;
            @(posedge PCLK);
            PENABLE = 0;
            PSEL = 0;
            PWDATA = 0;
            @(posedge PCLK);
        end
    endtask


    task apb_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
        begin
            PSEL = 1;
            PWRITE = 0;
            PADDR = addr;
            @(posedge PCLK);
            PENABLE = 1;
            @(posedge PCLK);
            data = PRDATA;
            PENABLE = 0;
            PSEL = 0;
            @(posedge PCLK);
        end
    endtask


    integer i;
    integer k;
    reg [DATA_WIDTH-1:0] read_data[0:3];
    reg [DATA_WIDTH-1:0] wr_data[0:3];
    reg [ADDR_WIDTH-1:0] wr_addr[0:3];
  // Test sequence
  initial begin
    $dumpfile("tb_APB_slave.vcd");
    $dumpvars(0, tb_APB_slave);
    $display("Starting Initialization");
    initialization;
    repeat(10) @(posedge PCLK);
    $display("Initialization Completed");
    $display("Starting Write Operations");

    // Write operation
    for (i = 0; i < 4; i++) begin
        wr_addr[i] = $urandom_range(0, (1<<ADDR_WIDTH)-1);
        wr_data[i] = $urandom;

        wait (PREADY);
        apb_write(wr_addr[i], wr_data[i]);

        $display("WRITE: addr=%h data=%h", wr_addr[i], wr_data[i]);
        repeat(1) @(posedge PCLK);
    end
    
    $display("Starting Read Operations");

    // Read operation
    for (k = 0; k < 4; k++) begin
        wait (PREADY);
        apb_read(wr_addr[k], read_data[k]);
        $display("READ : addr=%h data=%h exp=%h",wr_addr[k], read_data[k], wr_data[k]);
        if (read_data[k] !== wr_data[k])
            $error("DATA MISMATCH at addr %h", wr_addr[k]);
            @(posedge PCLK);
    end

    repeat(10) @(posedge PCLK);
    $display("Test Completed");
    $finish;
  end

endmodule