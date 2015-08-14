//settings.render = 16;
import three;
import graph3;
import solids;
currentprojection=orthographic(9, 3, 2);
currentlight=nolight;

size(16cm);

real RE = 1;
revolution Earth=sphere(O, RE, 9);

draw(surface(Earth),surfacepen=white+green+opacity(.1), meshpen=0.6*white);
draw(Earth,m=10,0.6*white);

//draw(rotate(90,X) * path3(unitcircle), black, L=Label("$Greenwich$"));
//draw(path3(unitcircle), black, L=Label("$Equator$"));

//draw(rotate(45, Z) * rotate(45, Y) * (Z--1.5Z), red, Arrow3(emissive(red)), L=Label("$Z_{world}$", position=EndPoint));
//draw(path3(arc((0,0),1,0,45)), red, arrow=Arrow3(emissive(red)), L=Label("$Longitude$"));
//draw(rotate(45,Z) * rotate(90,X) * path3(arc((0,0),1,0,45)), red, arrow=Arrow3(emissive(red)), L=Label("$Latitude$"));

//draw(rotate(45,Y) * surface(path3(unitsquare)), green+opacity(0.2));