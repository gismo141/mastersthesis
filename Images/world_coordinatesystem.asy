settings.render = 4;
import three;
import graph3;
import solids;

size(20cm,0);
texpreamble("\usepackage[setpagesize=false]{hyperref}");

real RE = 1;
revolution Earth=sphere(O, RE, 9);

draw(surface(Earth),surfacepen=white+green+opacity(.1), meshpen=0.8*white + linewidth(0.5pt));
draw(Earth,m=10,0.6*white);

draw(rotate(-35,Y) * rotate(90,X) * path3(unitcircle), black, L=Label("$Greenwich$", position=EndPoint, align=(2,0)));
draw(rotate(-35,Z) * path3(unitcircle), black, L=Label("$Equator$", position=MidPoint, align=(-2,0)));

draw(rotate(45, Z) * rotate(45, Y) * (Z--1.5Z), red + linewidth(1.0pt), Arrow3(emissive(red)), L=Label("$Height$"));
draw(path3(arc((0,0),1,0,45)), red + linewidth(1.0pt), arrow=Arrow3(emissive(red)), L=Label("$Longitude$", position=EndPoint, align=(0.5,-1.5)));
draw(rotate(45,Z) * rotate(90,X) * path3(arc((0,0),1,0,45)), red + linewidth(1.0pt), arrow=Arrow3(emissive(red)), L=Label("$Latitude$", align=(1.5,1)));