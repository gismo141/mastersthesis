settings.render = 4;
size(20cm,0);
texpreamble("\usepackage[setpagesize=false]{hyperref}");

import fontsize;
defaultpen(fontsize(40));

pair z1=(0,0);
real r=1;
path s1_i=circle(z1,r);

fill(s1_i,lightred+lightgreen);
fill(shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill(shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill(box((-0.02,-0.02),(0.02,0.02)));
label("$S_1$",(0,0),S);

dot("E",(0.65,0.65),NW,red+10bp);