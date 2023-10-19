module top(clk, hsl_valid, h, s, l, rgb_valid, r, g, b);

input wire clk;

input wire hsl_valid;
input wire [7:0] h;
input wire [7:0] s;
input wire [7:0] l;

output wire rgb_valid;
output wire [7:0] r;
output wire [7:0] g;
output wire [7:0] b;

assign rgb_valid = hsl_valid;
hsl_to_rgb #(.HUE_DEPTH(8))
	conversion(.h(h), .s(s), .l(l), .r(r), .g(g), .b(b));

endmodule
