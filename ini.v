module ini (
    input div_clk,
    input rst,
    input spi_done,
    input flash,
    input [1:0] data_part,
    output reg ini_wr_en,
    output reg ini_rd_en,
    output reg [7:0] ini_tx_data,
    output reg ini_over
);


parameter   adder_data = 2'b00; // 发送地址位
parameter   h_data = 2'b01;     // 发送高8位
parameter   m_data = 2'b10;     // 发送中8位
parameter   l_data = 2'b11;     // 发送低8位
parameter   reg_num = 33;

wire [31:0] value[0:reg_num-1] ;

assign value[0] =   {8'h01,24'h17c0};
assign value[1] =   {8'h02,24'h1f3e};
assign value[2] =   {8'h03,24'h1770};
assign value[3] =   {8'h04,24'h1f3f};
assign value[4] =   {8'h05,24'h50};
assign value[5] =   {8'h06,24'h7ce};
assign value[6] =   {8'h07,24'h820};
assign value[7] =   {8'h08,24'hf9e};
assign value[8] =   {8'h09,24'h7d0};
assign value[9] =   {8'h0a,24'hf9f};
assign value[10] =  {8'h0b,24'hff0};
assign value[11] =  {8'h0c,24'h176e};
assign value[12] =  {8'h0d,24'h6};
assign value[13] =  {8'h0e,24'h7cf};
assign value[14] =  {8'h0f,24'h7d6};
assign value[15] =  {8'h10,24'hf9f};
assign value[16] =  {8'h11,24'hfa6};
assign value[17] =  {8'h12,24'h176f};
assign value[18] =  {8'h13,24'h1776};
assign value[19] =  {8'h14,24'h1f3f};
assign value[20] =  {8'h15,24'h0};
assign value[21] =  {8'h16,24'h5};
assign value[22] =  {8'h17,24'h7d0};
assign value[23] =  {8'h18,24'h7d5};
assign value[24] =  {8'h19,24'hfa0};
assign value[25] =  {8'h1a,24'hfa5};
assign value[26] =  {8'h1b,24'h1770};
assign value[27] =  {8'h1c,24'h1775};
assign value[28] =  {8'h1d,24'h1f3f};
assign value[29] =  {8'h1e,12'b0,3'b000,1'b1,6'b0,2'b01};
assign value[30] =  {8'h21,24'h0000_00};
assign value[31] =  {8'h22,8'h01,8'h44,8'h44};
assign value[32] =  {8'h23,24'h04_0100};
assign value[33] =  {8'h29,24'h00_0000};
assign value[34] =  {8'h00,24'h00_0001};

// assign value[0] =   {8'h01,24'h17a2};
// assign value[1] =   {8'h02,24'h1f3e};
// assign value[2] =   {8'h03,24'h1770};
// assign value[3] =   {8'h04,24'h1f3f};
// assign value[4] =   {8'h05,24'h32};
// assign value[5] =   {8'h06,24'h7ce};
// assign value[6] =   {8'h07,24'h802};
// assign value[7] =   {8'h08,24'hf9e};
// assign value[8] =   {8'h09,24'h7d0};
// assign value[9] =   {8'h0a,24'hf9f};
// assign value[10] =  {8'h0b,24'hfd2};
// assign value[11] =  {8'h0c,24'h176e};
// assign value[12] =  {8'h0d,24'h4};
// assign value[13] =  {8'h0e,24'h7cf};
// assign value[14] =  {8'h0f,24'h7d4};
// assign value[15] =  {8'h10,24'hf9f};
// assign value[16] =  {8'h11,24'hfa4};
// assign value[17] =  {8'h12,24'h176f};
// assign value[18] =  {8'h13,24'h1774};
// assign value[19] =  {8'h14,24'h1f3f};
// assign value[20] =  {8'h15,24'h0};
// assign value[21] =  {8'h16,24'h3};
// assign value[22] =  {8'h17,24'h7d0};
// assign value[23] =  {8'h18,24'h7d3};
// assign value[24] =  {8'h19,24'hfa0};
// assign value[25] =  {8'h1a,24'hfa3};
// assign value[26] =  {8'h1b,24'h1770};
// assign value[27] =  {8'h1c,24'h1773};
// assign value[28] =  {8'h1d,24'h1f3f};
// assign value[29] =  {8'h1e,12'b0,3'b000,1'b1,6'b0,2'b01}; // 设置要平均的 ADC 采样数量为2，设置的值为实际采样数量减去 1。例如，如果要平均 4 个 ADC 采样值，那么需要将 NUMAV[7:0] 设置为 3。
// assign value[30] =  {8'h22,8'h01,8'h44,8'h44}; 
// assign value[31] =  {8'h23,24'h04_0100}; // For a 3-V to 3.6-V supply, use TX_REF = 0.25 or 0.5 V. For a 4.75-V to 5.25-V supply, use TX_REF = 0.75 V or 1.0 V，这里设置为 1.0 V
// assign value[32] =  {8'h00,24'h00_0001}; // Enable SPI_READ


reg [7:0] ini_num;//初始化寄存器的个数

always @(posedge div_clk or posedge rst) begin
    if (rst)
        begin
            ini_wr_en <= 1'b0;
            ini_rd_en <= 1'b0;
        end
    else begin
        ini_rd_en <= 1'b0;
        if (ini_num == reg_num)
            ini_wr_en <= 1'b0;
        else if (flash)
            ini_wr_en <= 1'b1;
        else if(spi_done)
            ini_wr_en <= 1'b0;
        else 
            ini_wr_en <= 1'b1;  
        end
    end
always @ (posedge div_clk or posedge rst )
    begin
    if (rst)
        ini_tx_data <= 8'b0;
    else 
        begin
        case(data_part)
            adder_data: ini_tx_data <= value[ini_num][31:24];
            h_data  :   ini_tx_data <= value[ini_num][23:16];
            m_data  :   ini_tx_data <= value[ini_num][15:8];
            l_data  :   ini_tx_data <= value[ini_num][7:0];
        endcase
        end     
    end 
     
always @(posedge div_clk or posedge rst)
    begin
        if(rst)
            begin
            ini_num <= 8'b0;
            end
        else if (data_part == l_data && spi_done == 1'b1)
            begin
            ini_num <= ini_num +1'b1;
            end
    end

always@ (posedge div_clk or posedge rst)
    begin
    if (rst)
        begin
            ini_over <= 1'b0;
        end
    else if (ini_num == reg_num)
        begin
            ini_over <= 1'b1;
        end
    end

endmodule
