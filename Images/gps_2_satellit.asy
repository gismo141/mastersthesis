settings.render = 16;
size(16cm);

pair z1=(0,0);
pair z2=(1.3,0);
real r=1;
path s1=circle(z1,r);
path s2=circle(z2,r);

fill(s1, white+(lightblue*0.2));
fill(shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill(shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill(box((-0.02,-0.02),(0.02,0.02)));
draw(box((-0.02,-0.02),(0.02,0.02)), L=Label("Satellit $1$", position=EndPoint, align=(0.5,-1.5)));

fill(s2, white+(lightblue*0.2));
fill(shift(z2) * shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill(shift(z2) * shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill(shift(z2) * box((-0.02,-0.02),(0.02,0.02)));
draw(shift(z2) * box((-0.02,-0.02),(0.02,0.02)), L=Label("Satellit $2$", position=EndPoint, align=(0.5,-1.5)));

picture intersection;
fill(intersection,s1,lightred+lightgreen);
clip(intersection,s2);
add(intersection);

draw(s1);
draw(s2);