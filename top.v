module top(clk, hsl_valid, h, s, l, rgb_valid, r, g, b);

input wire clk;

input wire hsl_valid;
input wire [7:0] h;
input wire [7:0] s;
input wire [7:0] l;

output reg rgb_valid;
output reg [7:0] r;
output reg [7:0] g;
output reg [7:0] b;

reg [7:0] h_delay;
reg [7:0] s_delay;
reg hsl_delay_valid;
wire [15:0] l_sq = l * l;
reg [7:0] l_corrected;

always @(posedge clk) begin
	h_delay <= h;
	s_delay <= s;
	l_corrected = l_sq >> 8;
	hsl_delay_valid <= hsl_valid;
end

wire [7:0] r_ahead;
wire [7:0] g_ahead;
wire [7:0] b_ahead;

hsl_to_rgb #(.HUE_DEPTH(8), .RGB_DEPTH(8))
	conversion(.h(h_delay), .s(s_delay), .l(l_corrected),
			   .r(r_ahead), .g(g_ahead), .b(b_ahead));

always @(posedge clk) begin
	rgb_valid <= hsl_delay_valid;
	r <= r_ahead;
	g <= g_ahead;
	b <= b_ahead;
end

endmodule
