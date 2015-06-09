settings.render = 16;
shipout(scale(4.0)*currentpicture.fit());
import three;
import graph3;
import solids;
currentprojection=orthographic(3, 3, 2);

size(16cm);

draw(surface(sphere(O,.7)),surfacepen=green+white+opacity(0.2), meshpen=0.2*white);
draw(arc(c=O,-.7Z, .7Z, normal=X), black, L=Label("$Greenwich$", position=Relative(0.8), align=E));
draw(arc(c=O,.7Y, .7Y, normal=Z), black, L=Label("$Equator$"));

draw(rotate(45, Y) * (.7Z--1.2Z), red, Arrow3(emissive(red)), L=Label("$Z_{world}$", position=EndPoint));
draw(arc(c=O,.7X, .7(X+Z)), red, arrow=Arrow3(emissive(red)), L=Label("$Longitude$"));
draw(arc(c=O,.7Y, .7X), red, arrow=Arrow3(emissive(red)), L=Label("$Latitude$"));