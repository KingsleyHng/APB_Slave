module APB_Slave (
    input wire PCLK,
    input wire PRESETn,
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [ADDR_WIDTH-1:0] PADDR,
    input wire [DATA_WIDTH-1:0] PWDATA,
    output reg [DATA_WIDTH-1:0] PRDATA,
    output reg PREADY
);

    parameter ADDR_WIDTH = 8; // Address width
    parameter DATA_WIDTH = 32;  // Data width
    parameter ADDR_DEPTH = (1<<ADDR_WIDTH); // Depth of memory

    // Internal registers
    reg [DATA_WIDTH-1:0] memory [0:ADDR_DEPTH-1]; // Simple memory array

    reg[2:0] state;

    localparam IDLE = 3'b000,
               SETUP = 3'b001,
               ACCESS = 3'b010;

    // APB Slave State Machine
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state <= IDLE;
            PREADY <= 1'b0;
            PRDATA <= {DATA_WIDTH{1'b0}};
        end else begin
            case(state)
                IDLE: begin
                    PREADY <= 1'b1;
                    if (PSEL && !PENABLE) begin
                        state <= SETUP;
                    end
                end

                SETUP: begin
                    PREADY <= 1'b1;
                    if (PSEL && PENABLE ) begin
                        if(PWRITE) begin
                            memory[PADDR] <= PWDATA; // Write operation
                            state <= ACCESS;
                        end else begin
                            PRDATA <= memory[PADDR]; // Read operation
                            state <= ACCESS;
                        end
                    end else begin
                        state <= SETUP;
                        PREADY <= 1'b0;
                    end
         
                end

                ACCESS: begin
                   if(!PENABLE)begin 
                    PREADY <= 1'b0;
                    state <= IDLE;
                   end else begin
                    PREADY <= 1'b0;
                    state <= ACCESS;
                   end
                end

                default: state <= IDLE;
            endcase
    end
end


endmodule