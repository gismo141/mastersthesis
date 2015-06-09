settings.render=16;
shipout(scale(4.0)*currentpicture.fit());
import three;
import graph3;
import solids;
currentprojection=orthographic(3,4,1, center=true);

size(15cm);
pen outside = white+opacity(1);

real height=0.8;
path3 laserBase = path3((-0.4,0.7) -- (-0.5,sin(acos(-0.5))) .. (-1,0) .. (0,-1) .. (1,0) .. (0.5,sin(acos(0.5))) -- (0.4,0.7));
surface laserEye = extrude(laserBase --- cycle, height*Z);

draw(shift(0.9Z) * scale(1,1,0.4) * unithemisphere, surfacepen=outside); // Top
draw(shift(0.4Z) * scale(1,1,0.5) * unitcylinder, surfacepen=outside);   // upper rotating Head
draw(shift(-height/2*Z) * laserEye, surfacepen=white+opacity(0.8));      // Laser-Eye
draw(shift(-0.7Z) * scale(1,1,0.3) * unitcylinder, surfacepen=outside);  // lower rotating Head
draw(shift(-1.7Z) * scale(1,1,0.95) * unitcylinder, surfacepen=outside); // Base

draw(rotate(-90,X) * (O--3Y), red, Arrow3(emissive(red)), L=Label("$Y$", position=EndPoint));
draw(rotate(-90,X) * (O--3Z), red, Arrow3(emissive(red)), L=Label("$Z$", position=EndPoint));
draw(rotate(-90,X) * arc(c=(0,0,0),1.1Z, 1.1X), red, arrow=Arrow3(emissive(red)), L=Label("$\Theta$"));