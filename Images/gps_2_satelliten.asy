settings.render = 4;
size(20cm,0);
texpreamble("\usepackage[setpagesize=false]{hyperref}");

import fontsize;
defaultpen(fontsize(40));

pair z1=(0,0);
pair z2=(1.3,0);
real r=1;
path s1=circle(z1,r);
path s2=circle(z2,r);

fill(s1, white+(lightblue*0.2));
fill(shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill(shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill(box((-0.02,-0.02),(0.02,0.02)));
draw(box((-0.02,-0.02),(0.02,0.02)));

fill(s2, white+(lightblue*0.2));
fill(shift(z2) * shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill(shift(z2) * shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill(shift(z2) * box((-0.02,-0.02),(0.02,0.02)));
draw(shift(z2) * box((-0.02,-0.02),(0.02,0.02)));

picture intersection;
fill(intersection,s1,lightred+lightgreen);
clip(intersection,s2);
add(intersection);

label("$S_1$",z1,S);
label("$S_2$",z2,S);

dot("E",(0.65,0.65),NW,red+10bp);