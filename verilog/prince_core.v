module prince_core
	#( parameter TEXT_SIZE=64,
        parameter KEY_SIZE=128,
	parameter SBOX_NUMBER=16) (
	input [TEXT_SIZE-1:0] data_in,
	input [KEY_SIZE-1:0] key,
	input mode,
	output wire [TEXT_SIZE-1:0] data_out
	);

wire [TEXT_SIZE-1:0] rcs [11:0];
wire [TEXT_SIZE-1:0] ims [11:0];

wire [TEXT_SIZE-1:0] sb_out[5:1];
wire [TEXT_SIZE-1:0] m_out[5:1];

wire [TEXT_SIZE-1:0] sb_in[10:6];
wire [TEXT_SIZE-1:0] m_in[10:6];

wire [KEY_SIZE/2-1:0] k0, k1;

wire [TEXT_SIZE-1:0] middle1, middle2;
wire [TEXT_SIZE-1:0] middle3;

//-- Constants 
wire [KEY_SIZE/2-1:0] alpha = 64'hC0AC29B7C97C50DD;
wire [KEY_SIZE/2-1:0] beta = 64'h3F84D5B5B5470917;

//-- Round constants
assign rcs[0]  = 64'h0000000000000000;
assign rcs[1]  = 64'h13198A2E03707344;
assign rcs[2]  = 64'hA4093822299F31D0;
assign rcs[3]  = 64'h082EFA98EC4E6C89;
assign rcs[4]  = 64'h452821E638D01377;
assign rcs[5]  = 64'hBE5466CF34E90C6C;
assign rcs[6]  = rcs[5] ^ alpha;
assign rcs[7]  = rcs[4] ^ beta;
assign rcs[8]  = rcs[3] ^ alpha;
assign rcs[9]  = rcs[2] ^ beta;
assign rcs[10] = rcs[1] ^ alpha;
assign rcs[11] = rcs[0] ^ beta;

//-- key assignement
assign {k0, k1} = key;

genvar i,j;

//-- instantiates sbox, sbox_inv, linear_m, 

//-- Round 0
assign ims[0] = data_in ^ rcs[0] ^ (mode ? k1 ^ beta : k0); 

//-- Round 1 to 5
generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox i_sbox (
      .data_in(ims[0][63 - 4*j:63 - 4*j - 3]),
      .data_out(sb_out[1][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox i_sbox (
      .data_in(ims[1][63 - 4*j:63 - 4*j - 3]),
      .data_out(sb_out[2][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox i_sbox (
      .data_in(ims[2][63 - 4*j:63 - 4*j - 3]),
      .data_out(sb_out[3][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox i_sbox (
      .data_in(ims[3][63 - 4*j:63 - 4*j - 3]),
      .data_out(sb_out[4][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox i_sbox (
      .data_in(ims[4][63 - 4*j:63 - 4*j - 3]),
      .data_out(sb_out[5][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (i = 1 ; i <= 5 ; i = i + 1) begin

  linear_m i_linear_m (
	.data_in(sb_out[i]),
	.data_out(m_out[i])
	);

  assign ims[i] = (i % 2) ? (m_out[i] ^ rcs[i] ^ (mode ? k0 ^ alpha : k1)) //-- odd
                            : (m_out[i] ^ rcs[i] ^ (mode ? k1 ^ beta : k0)); //-- even

  end
endgenerate

//-- Middle Layer for PRINCEv2

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox i_sbox (
      .data_in(ims[5][63 - 4*j:63 - 4*j - 3]),
      .data_out(middle1[63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

linear_mprime i_linear_mprime (
	.data_in(middle1 ^ (mode ? k1 ^ beta : k0)),
  .data_out(middle2)
);

assign middle3 = middle2 ^(mode ? k0 : k1 ^ beta);

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox_inv i_sbox_inv (
      .data_in(middle3[63 - 4*j:63 - 4*j - 3]),
      .data_out(ims[6][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

//-- Round 6 to 10

generate
  for (i = 6 ; i <= 10 ; i = i + 1) begin

  assign m_in[i] = (i % 2) ? (ims[i] ^ rcs[i] ^ (mode ? k0 ^ beta : k1)) //-- odd
                           : (ims[i] ^ rcs[i] ^ (mode ? k1 ^ alpha : k0)); //-- even

  linear_m_inv i_linear_m_inv (
        .data_in(m_in[i]),
        .data_out(sb_in[i])
        );

  end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox_inv i_sbox_inv (
      .data_in(sb_in[6][63 - 4*j:63 - 4*j - 3]),
      .data_out(ims[7][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox_inv i_sbox_inv (
      .data_in(sb_in[7][63 - 4*j:63 - 4*j - 3]),
      .data_out(ims[8][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox_inv i_sbox_inv (
      .data_in(sb_in[8][63 - 4*j:63 - 4*j - 3]),
      .data_out(ims[9][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox_inv i_sbox_inv (
      .data_in(sb_in[9][63 - 4*j:63 - 4*j - 3]),
      .data_out(ims[10][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

generate
  for (j = 0 ; j <= (SBOX_NUMBER-1) ; j = j + 1) begin
    sbox_inv i_sbox_inv (
      .data_in(sb_in[10][63 - 4*j:63 - 4*j - 3]),
      .data_out(ims[11][63 - 4*j:63- 4*j - 3])
     );
   end
endgenerate

//-- Last Round 
assign data_out = ims[11] ^ (mode ? k0 : beta ^ k1); 


endmodule
