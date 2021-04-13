`timescale 1ns / 1ps


module stage_0(P,G,a,b);
input[7:0] a, b;
output[7:0] P, G;
assign P[0]=a[0]^b[0], P[1]=a[1]^b[1], P[2]=a[2]^b[2], P[3]=a[3]^b[3], P[4]=a[4]^b[4], P[5]=a[5]^b[5], P[6]=a[6]^b[6], P[7]=a[7]^b[7],
       G[0]=a[0]&b[0], G[1]=a[1]&b[1], G[2]=a[2]&b[2], G[3]=a[3]&b[3], G[4]=a[4]&b[4], G[5]=a[5]&b[5], G[6]=a[6]&b[6], G[7]=a[7]&b[7];    
endmodule


module stage_1(ip,ig,p,g);
input[7:0] p,g;
output[3:0] ip,ig;
assign ip[0]=p[0]&p[1], ip[1]=p[2]&p[3], ip[2]=p[4]&p[5], ip[3]=p[6]&p[7],
       ig[0]=g[1]|(g[0]&p[1]), ig[1]=g[3]|(g[2]&p[3]), ig[2]=g[5]|(g[4]&p[5]), ig[3]=g[7]|(g[6]&p[7]);
endmodule


module stage_2(ip,ig,p,g);
input[3:0] p,g;
output[2:0] ip,ig;
assign ip[0]=p[0]&p[1], ip[1]=p[1]&p[2], ip[2]=p[2]&p[3],
       ig[0]=g[1]|(g[0]&p[1]), ig[1]=g[2]|(g[1]&p[2]), ig[2]=g[3]|(g[2]&p[3]);
endmodule


module stage_3(ip,ig,ip0,P2,ip4,P4,ip5,ip6,ig0,G2,ig4,G4,ig5,ig6);
input ip0,P2,ip4,P4,ip5,ip6,ig0,G2,ig4,G4,ig5,ig6;
output[3:0] ip,ig;
assign ip[0]=ip0&P2, ip[1]=ip4&P4, ip[2]=ip0&ip5, ip[3]=ip4&ip6,
       ig[0]=G2|(ig0&P2), ig[1]=G4|(ig4&P4), ig[2]=ig5|(ig0&ip5), ig[3]=ig6|(ig4&ip6);
endmodule


module stage_4(ip,ig,ip9,P6,ig9,G6);
input ip9,P6,ig9,G6;
output ip,ig;
assign ip=ip9&P6, ig=G6|(ig9&P6);
endmodule


module carryint(C,cout,cin,ip,ig,P0,G0);
input cin,P0,G0; input[11:0] ip,ig;
output[6:0] C; output cout;
assign C[0]=G0|(P0&cin), C[1]=ig[0]|(ip[0]&cin), C[2]=ig[7]|(ip[7]&cin), C[3]=ig[4]|(ip[4]&cin),
       C[4]=ig[8]|(ip[8]&cin), C[5]=ig[9]|(ip[9]&cin), C[6]=ig[11]|(ip[11]&cin), cout=ig[10]|(ip[10]&cin);
endmodule


module sumout(s,C,cin,P);
input[6:0] C; input[7:0] P; input cin;
output[7:0] s;
assign s[0]=P[0]^cin, s[1]=P[1]^C[0], s[2]=P[2]^C[1], s[3]=P[3]^C[2],
       s[4]=P[4]^C[3], s[5]=P[5]^C[4], s[6]=P[6]^C[5], s[7]=P[7]^C[6];
endmodule


module HCadd8(a,b,cin,s,cout);
input[7:0] a,b; input cin;
output[7:0] s; output cout;
wire[7:0] P,G; wire[6:0] C; wire[11:0] ip,ig;
stage_0 s0(P,G,a,b);
stage_1 s1(ip[3:0],ig[3:0],P,G);
stage_2 s2(ip[6:4],ig[6:4],ip[3:0],ig[3:0]);
stage_3 s3(ip[10:7],ig[10:7],ip[0],P[2],ip[4],P[4],ip[5],ip[6],ig[0],G[2],ig[4],G[4],ig[5],ig[6]);
stage_4 s4(ip[11],ig[11],ip[9],P[6],ig[9],G[6]);
carryint c5(C,cout,cin,ip,ig,P[0],G[0]);
sumout s6(s,C,cin,P);
endmodule


module tbHC;
wire[7:0] s; wire cout;
reg[7:0] a,b; reg cin;
HCadd8 HC(a,b,cin,s,cout);
initial begin 
    a<=8'b10100011; b<=8'b10101111; cin<=1'b0;
    #20 $finish;
end
endmodule