settings.render=16;
import three;
import graph3;
import solids;

import "Images/velodyne" as graph;

size(15cm);
currentprojection=orthographic(8,4,3, center=true);

pen outside = white+opacity(1);
pen viewpoint = red+opacity(0.2);

drawVelodyne(.12,.12,.12);

path3 view = rotate(90,X) * path3((0,0) -- arc((0,0), 1, 10, -30) --- cycle);
draw(surface(rotate(90, Z) * view), emissive(red+black+opacity(0.2)));
draw(surface(revolution(view)), surfacepen=viewpoint);

draw(shift(0,0,.32) * arc(c=(0,0,0),-.25(X), .25(X), -Z), black, arrow=Arrow3(emissive(black)), L=Label("$\Theta$"));
draw(rotate(90,Z) * rotate(90,X) * path3(arc((0,0),.85, 0, 10)), black, arrow=Arrow3(emissive(black)), L=Label("$10^{\circ}$"));
draw(rotate(90,Z) * rotate(-90,X) * path3(arc((0,0),.85, 0, 30)), black, arrow=Arrow3(emissive(black)), L=Label("$30^{\circ}$"));
draw(rotate(-90,X) * (O--1Z), black, arrow=Arrow3(emissive(black)), L=Label("$Z$", position=Relative(0.8), align=S));
draw(rotate(-90,X) * (O--.6Y), black, Arrow3(emissive(black)), L=Label("$Y$", position=EndPoint));