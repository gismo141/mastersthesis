settings.render = 16;
size(16cm);

pair z1=(0,0);
pair z2=(1.3,0);
pair z3=(0,1.3);
pair z4=(1.3,1.3);
real r=1;
path s1=circle(z1,r);
path s2=circle(z2,r);
path s3=circle(z3,r);
path s4=circle(z4,r);

fill(s1, white+(lightblue*0.2));
fill(shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill(shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill(box((-0.02,-0.02),(0.02,0.02)));
draw(box((-0.02,-0.02),(0.02,0.02)), L=Label("Satellit $1$", position=EndPoint, align=(0.5,-1.5)));

fill(s2, white+(lightblue*0.2));
fill( shift(z2) * shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill( shift(z2) * shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill( shift(z2) * box((-0.02,-0.02),(0.02,0.02)));
draw(shift(z2) * box((-0.02,-0.02),(0.02,0.02)), L=Label("Satellit $2$", position=EndPoint, align=(0.5,-1.5)));

fill(s3, white+(lightblue*0.2));
fill( shift(z3) * shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill( shift(z3) * shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill( shift(z3) * box((-0.02,-0.02),(0.02,0.02)));
draw(shift(z3) * box((-0.02,-0.02),(0.02,0.02)), L=Label("Satellit $3$", position=EndPoint, align=(0.5,-1.5)));

fill(s4, white+(lightblue*0.2));
fill( shift(z4) * shift(0.03,-0.01) * box((0,0), (0.2,0.02)));
fill( shift(z4) * shift(-0.23,-0.01) * box((0.2,0.02), (0,0)));
fill( shift(z4) * box((-0.02,-0.02),(0.02,0.02)));
draw(shift(z4) * box((-0.02,-0.02),(0.02,0.02)), L=Label("Satellit $4$", position=EndPoint, align=(0.5,-1.5)));

picture intersection;
fill(intersection,s1,lightred+lightgreen);
clip(intersection,s2);
clip(intersection,s3);
clip(intersection,s4);
add(intersection);

draw(s1);
draw(s2);
draw(s3);
draw(s4);