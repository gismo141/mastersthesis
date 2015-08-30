//settings.render = 16;
import three;
import graph3;
import solids;

currentprojection=orthographic(2, 3, 7);
currentlight=nolight;

size(16cm);

draw(shift(-1,-1,0) * scale3(0.05) * surface(sphere(1)));
draw(shift(-1,-1,0) * surface(sphere(1.5)), surfacepen=opacity(0.1)+lightblue);

draw(shift(1,1,0) * scale3(0.05) * surface(sphere(1)));
draw(shift(1,1,0) * scale3(1.5) * surface(sphere(1)), surfacepen=opacity(0.1)+lightblue);

draw(shift(-1,0.7,0) * scale3(0.05) * surface(sphere(1)));
label("Satellit $1$",(5,2,0));
draw(shift(-1,0.7,0) * scale3(1.3) * surface(sphere(1)), surfacepen=opacity(0.1)+lightblue);