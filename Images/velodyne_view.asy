import three;
import "Images/velodyne" as laserscanner;
texpreamble("\usepackage{lmodern}");

size(15cm);
settings.render=16;
currentprojection=orthographic(8,4,1.5, center=true);

pen outside = white+opacity(1);
pen viewpoint = red+white;

draw(shift(-.02Z) * scale(.12,.12,.12) * velodyne(), outside);

path3 view = rotate(90,X) * path3((0,0) -- arc((0,0), 1, 10, -30) --- cycle);
draw(surface(rotate(90, Z) * view), emissive(red+black+opacity(0.2)));
draw(surface(revolution(view)), viewpoint+opacity(0.2));

draw(-.8Z -- .5Z, linetype(new real[] {0,4}));
draw(shift(0,0,.23) * path3(arc((0,0),.25, 180, -170)), black, arrow=Arrow3(emissive(black)), L=Label("$\theta$"));
draw(rotate(90,Z) * rotate(90,X) * path3(arc((0,0),.85, -30, 10)), L=Label("$\psi$", align=E));
draw(rotate(90,Z) * rotate(90,X) * path3(arc((0,0),.85, 0, 10)), arrow=Arrow3(emissive(black)), L=Label("$10^{\circ}$", align=W));
draw(rotate(90,Z) * rotate(90,X) * path3(arc((0,0),.85, 0, -30)), arrow=Arrow3(emissive(black)), L=Label("$30^{\circ}$", align=W));
draw(rotate(-90,X) * (O--1Z), linetype(new real[] {0,4}), arrow=Arrow3(emissive(black)), L=Label("$d$", align=S));