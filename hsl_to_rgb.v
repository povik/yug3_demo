module hsl_to_rgb #(
	parameter HUE_DEPTH = 8,
	parameter SAT_DEPTH = 8,
	parameter RGB_DEPTH = 8
)(h, s, l, r, g, b);

input wire [HUE_DEPTH-1:0] h;
input wire [SAT_DEPTH-1:0] s;
input wire [RGB_DEPTH-1:0] l;

output wire [RGB_DEPTH-1:0] r;
output wire [RGB_DEPTH-1:0] g;
output wire [RGB_DEPTH-1:0] b;

wire [HUE_DEPTH+3-1:0] h6 = h * 6;

wire [RGB_DEPTH+1-1:0] l_; 
wire [RGB_DEPTH+SAT_DEPTH-1:0] c_product; 
wire [RGB_DEPTH-1:0] c;

wire [HUE_DEPTH+1-1:0] h6_mod2;
wire [HUE_DEPTH+1-1:0] x_h_factor;

wire [HUE_DEPTH+1+RGB_DEPTH-1:0] x_product;
wire [RGB_DEPTH-1:0] x;


// https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB
assign l_ = l >= (1 << (RGB_DEPTH - 1)) ? ((2 << RGB_DEPTH) - l*2) : l*2;
assign c_product = l_ * s;
assign c = c_product >> SAT_DEPTH;

// Crop the two most significant bits off `h6`, by which
// we do modulo 2 in the fixed-point representation we are using
assign h6_mod2 = h6;
assign x_h_factor = h6_mod2[HUE_DEPTH] ? ((2 << HUE_DEPTH) - h6_mod2) : h6_mod2;

assign x_product = c * x_h_factor;
assign x = x_product >> HUE_DEPTH;

reg [RGB_DEPTH-1:0] r_;
reg [RGB_DEPTH-1:0] g_;
reg [RGB_DEPTH-1:0] b_;

always @(*) begin
	case (h6[HUE_DEPTH+3-1:HUE_DEPTH])
		0: begin r_ = c; g_ = x; b_ = 0; end
		1: begin r_ = x; g_ = c; b_ = 0; end
		2: begin r_ = 0; g_ = c; b_ = x; end
		3: begin r_ = 0; g_ = x; b_ = c; end
		4: begin r_ = x; g_ = 0; b_ = c; end
		5: begin r_ = c; g_ = 0; b_ = x; end
		default: begin r_ = 0; g_ = 0; b_= 0; end
	endcase
end

wire [RGB_DEPTH-1:0] m = l - (c >> 1);

// FIXME: can overflow in an edge case
assign r = r_ + m;
assign g = g_ + m;
assign b = b_ + m;

endmodule

module hue_sweep(clk);
input wire clk;
reg [8:0] hue = 0;

always @(posedge clk) begin
	$display("%d %d %d %d", hue, r, g, b);
	hue = hue + 1;
end

wire [7:0] r;
wire [7:0] g;
wire [7:0] b;

hsl_to_rgb #(.HUE_DEPTH(9))
	conversion(.h(hue), .l(127), .s(255),
			   .r(r), .g(g), .b(b));
endmodule
