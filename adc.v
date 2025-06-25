module adc (
    input div_clk,
    input rst,
    input [7:0] adc_rx_data,
    input spi_done,
    input adc_rdy,
    input flash,
    input brt_adj_en,
    input diag_en,
    input [1:0] data_part,
    output reg adc_rd_en,
    output reg adc_wr_en,
    output reg [7:0] adc_tx_data,
    output reg conver,
    output reg [23:0] led1_sub_aled1,
    output reg [23:0] led2_sub_aled2
);
    
parameter   adder_data = 2'b00;
parameter   h_data = 2'b01;
parameter   m_data = 2'b10;
parameter   l_data = 2'b11;
    

always @ (posedge div_clk or posedge rst)
    begin
    if(rst)
        conver <= 1'b0;
    else if (brt_adj_en || diag_en)
        conver <= 1'b0;
    else if (adc_rdy )
        conver <= 1'b1;
    else if (adc_tx_data == 8'h30)
        conver <= 1'b0;
    end
    
    // 当前进行哪个转换数据寄存器的读取,读转换数据的地址
    // LED2VAL:2A  ALED2VAL:2B  LED1VAL:2C  ALED1VAL:2D 
always @ (posedge div_clk or posedge rst)
    begin
    if(rst)
        adc_tx_data <= 8'h2e;
    else if (brt_adj_en || diag_en)
        adc_tx_data <= 8'h2e;
    else if (adc_rdy)
        adc_tx_data <= 8'h2e;
    else if(data_part == l_data && spi_done == 1'b1 && conver == 1'b1)
        adc_tx_data <= adc_tx_data + 1'b1;
    end
        
        
always @ (posedge div_clk or posedge rst)
    begin
        if(rst)
            begin
            led1_sub_aled1 <= 24'b0;
            led2_sub_aled2 <= 24'b0;
            end
        else if (brt_adj_en || diag_en)
            begin
            led1_sub_aled1 <= led1_sub_aled1;
            led2_sub_aled2 <= led2_sub_aled2;
        end
        else if (spi_done)
            begin
            case({adc_tx_data[3:0],data_part})
                6'b1110_01:led2_sub_aled2[23:16] <= adc_rx_data;
                6'b1110_10:led2_sub_aled2[15:8]  <= adc_rx_data;
                6'b1110_11:led2_sub_aled2[7:0]   <= adc_rx_data;
                6'b1111_01:led1_sub_aled1[23:16] <= adc_rx_data;
                6'b1111_10:led1_sub_aled1[15:8]  <= adc_rx_data;
                6'b1111_11:led1_sub_aled1[7:0]   <= adc_rx_data;
                default:begin
                    led1_sub_aled1 <= led1_sub_aled1;
                    led2_sub_aled2 <= led2_sub_aled2;
                end
            endcase
            end
    end
                

always @ (posedge div_clk or posedge rst)
    begin
    if(rst)
        begin
        adc_wr_en <= 1'b0;
        adc_rd_en <= 1'b0;
        end
    else if (brt_adj_en || diag_en)
        begin
        adc_wr_en <= 1'b0;
        adc_rd_en <= 1'b0;
        end
    else if (data_part == adder_data)
        begin
        if (flash)
            begin
            adc_wr_en <= 1'b1;
            adc_rd_en <= 1'b0;
            end
        else if(spi_done)
            begin
            adc_wr_en <= 1'b0;
            adc_rd_en <= 1'b0;
            end
        else 
            begin
            adc_wr_en <= 1'b1;
            adc_rd_en <= 1'b0;
            end
        end
    else begin
        if (flash)
            begin
            adc_wr_en <= 1'b0;
            adc_rd_en <= 1'b1;
            end
        else if(spi_done)
            begin
            adc_wr_en <= 1'b0;
            adc_rd_en <= 1'b0;
            end
        else 
            begin
            adc_wr_en <= 1'b0;
            adc_rd_en <= 1'b1;
            end
        end
    end
endmodule