module AFE4403 (
    input clk,         // 系统时钟
    input rst,         // 系统复位
    input adc_rdy,     // ADC 转换完成标志位
    input spisomi,     // SPI 输入
    input diag_end,    // 诊断结束标志
    output spisimo,    // SPI 输出
    output spiste,     // SPI 使能
    output sclk,       // SPI 时钟
    output afe4403_rst,// AFE 芯片复位
    output afe_pdnz    // AFE 低功耗控制
);
wire div_clk, afe_rdover;
wire signed [23:0] led2_sub_aled2;
wire signed [23:0] led1_sub_aled1;
wire conver;
reg adc_rdy_temp;
reg [4:0] count;

assign afe_pdnz = ~rst;
assign afe4403_rst = ~rst;

wire led_add1 = 1'b0, led_add2 = 1'b0, led_sub1 = 1'b0, led_sub2 = 1'b0;
wire diag_start = 1'b0;

always@(posedge clk or posedge rst) begin
    if (rst)
        count <= 5'b0;
    else if (count == 5'd3)
        count <= 5'b0;
    else if (count >= 5'b1)
        count <= count + 1'b1;
    else if (adc_rdy)
        count <= 5'b1;
end

always@(posedge clk or posedge rst) begin
    if (rst)
        adc_rdy_temp <= 1'b0;
    else if (count == 5'b0)
        adc_rdy_temp <= 1'b0;
    else 
        adc_rdy_temp <= 1'b1;
end

clk_gen i0(.clk(clk), .div_clk(div_clk), .rst(rst));

spi_total   i1( 
    .div_clk(div_clk),
    .rst(rst),
    .adc_rdy(adc_rdy_temp),
    .sclk(sclk),
    .spiste(spiste),
    .spisimo(spisimo),
    .spisomi(spisomi),
    .conver(conver),
    
    .led_add1(led_add1),
    .led_add2(led_add2),
    .led_sub1(led_sub1),
    .led_sub2(led_sub2),
    
    .diag_start(diag_start),
    .diag_end(diag_end),
    .led2_sub_aled2(led2_sub_aled2),
    .led1_sub_aled1(led1_sub_aled1),
    .afe_rdover(afe_rdover)
);

ila_0 u_ila (
    .clk(clk),
    .probe0(rst),  
    .probe1(adc_rdy),
    .probe2(spiste),
    .probe3(spisimo),
    .probe4(spisomi),
    .probe5(sclk),
    .probe6(afe4403_rst),
    .probe7(afe_pdnz),
    .probe8(diag_end),
    .probe9(led2_sub_aled2),
    .probe10(led1_sub_aled1)
);

endmodule