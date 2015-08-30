import three;
import "Images/velodyne" as laserscanner;

//settings.render=16;
size(15cm);

draw(velodyne(), surfacepen=white);
draw(rotate(-90,X) * (O--2.5Y), red, Arrow3(emissive(red)), L=Label("$Y$", position=EndPoint));
draw(rotate(-90,X) * (O--3Z), red, Arrow3(emissive(red)), L=Label("$Z$", position=EndPoint));
draw(rotate(-90,X) * arc(c=(0,0,0),1.1Z, 1.1X), red, arrow=Arrow3(emissive(red)), L=Label("$\Theta$"));