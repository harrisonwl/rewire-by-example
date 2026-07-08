
// Transmitter code below
module uart_tx #(
    parameter CLKS_PER_BIT = 868 // e.g., 100MHz clock / 115200 baud
) (
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output reg tx_pin,
    output reg tx_done
);

    // FSM States
    localparam IDLE = 2'b00;
    localparam START_BIT = 2'b01;
    localparam DATA_BITS = 2'b10;
    localparam STOP_BIT = 2'b11;

    reg [1:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            tx_pin <= 1'b1;
            tx_done <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_pin <= 1'b1;
                    tx_done <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;
                    
                    if (tx_start) begin
                        data_reg <= tx_data;
                        state <= START_BIT;
                    end
                end

                START_BIT: begin
                    tx_pin <= 1'b0; // Start bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    tx_pin <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    tx_pin <= 1'b1; // Stop bit
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        tx_done <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule

// Receiver code below
module uart_rx #(
    parameter DATA_BITS = 8
)(
    input  wire                 clk,      // System clock
    input  wire                 reset,    // Active-high reset
    input  wire                 rx,       // Incoming serial data line
    input  wire                 s_tick,   // 16x Over-sampling tick from baud rate generator
    output reg                  rx_done,  // High for 1 clock cycle when data is ready
    output reg [DATA_BITS-1:0] dout      // 8-bit output data byte
);

    // FSM State Encoding
    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;         // Counts the 16 oversampling ticks
    reg [2:0] n_reg, n_next;         // Counts the number of data bits received
    reg [DATA_BITS-1:0] b_reg, b_next; // Shifts in and stores the data bits

    // State and Register Upgrades
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
        end
    end

    // Next-State Logic
    always @* begin
        state_next = state_reg;
        s_next     = s_reg;
        n_next     = n_reg;
        b_next     = b_reg;
        rx_done    = 1'b0;
        dout       = b_reg;

        case (state_reg)
            IDLE: begin
                if (~rx) begin          // Falling edge detected (Start bit)
                    state_next = START;
                    s_next     = 0;
                end
            end

            START: begin
                if (s_tick) begin
                    if (s_reg == 7) begin // Center of start bit reached
                        state_next = DATA;
                        s_next     = 0;
                        n_next     = 0;
                    end else begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end

            DATA: begin
                if (s_tick) begin
                    if (s_reg == 15) begin // Center of data bit reached
                        s_next = 0;
                        b_next = {rx, b_reg[DATA_BITS-1:1]}; // Shift right (LSB first)
                        if (n_reg == (DATA_BITS - 1))
                            state_next = STOP;
                        else
                            n_next = n_reg + 1'b1;
                    end else begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end

            STOP: begin
                if (s_tick) begin
                    if (s_reg == 15) begin // Center of stop bit reached
                        state_next = IDLE;
                        rx_done    = 1'b1; // Signal that 'dout' is valid
                    end else begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end
        endcase
    end
endmodule
