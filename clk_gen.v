module clk_gen (
    input clk,           // AFE4403 时钟
    input rst,           // 复位信号
    output reg div_clk   // SPI 时钟
);

parameter div_length = 4;      // 分频计数器长度
parameter div_cof = 4'd9;      // 分频系数，对主时钟进行20分频，100MHz -> 5MHz
reg [div_length-1:0] div_count;

always @(posedge clk or posedge rst) begin
    if (rst)
        div_count <= 0;
    else if (div_count == div_cof)
        div_count <= 0;
    else 
        div_count <= div_count + 1;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        div_clk <= 0;
    else if (div_count == div_cof)
        div_clk <= ~div_clk;
end

endmodule