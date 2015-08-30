settings.render = 4;
size(23cm,0);
\texpreamble("\usepackage[setpagesize=false]{hyperref}");

import fontsize;
defaultpen(fontsize(30));

pair p1 = (0,0);
pair p2 = (0.18,0);
pair p3 = (0.36,0);
pair p4 = (0.54,0);
pair p5 = (0.72,0);

path p = (4/4,0) .. (0,-5/4) .. (-4/4,0)
.. (0,5/4) .. (2,0);
draw(p);

fill(shift(p1) * box((-.2,-0.1),(.2,0.1)), .9*white);
fill(shift(p1) * scale(.02) * unitcircle);
draw(shift(p1) * scale(.02) * unitcircle, .9*white+linewidth(1.0pt), L=Label("$P_1$", align=(0,2)));
draw(p1--(4/4,0), .8*white+red+linewidth(1.0pt), arrow=ArcArrow(TeXHead), L=Label("$R_1$", position=EndPoint, NE));
fill(shift(p2) * box((-.2,-0.1),(.2,0.1)), .8*white);
fill(shift(p2) * scale(.02) * unitcircle);
draw(shift(p2) * scale(.02) * unitcircle, .8*white+linewidth(1.0pt), L=Label("$P_2$", align=(0,2)));
draw(p2--(0,-5/4), .6*white+red+linewidth(1.0pt), arrow=ArcArrow(TeXHead), L=Label("$R_2$", position=EndPoint, S));
fill(shift(p3) * box((-.2,-0.1),(.2,0.1)), .7*white);
fill(shift(p3) * scale(.02) * unitcircle);
draw(shift(p3) * scale(.02) * unitcircle, .7*white+linewidth(1.0pt), L=Label("$P_3$", align=(0,-2)));
draw(p3--(-4/4,0), .4*white+red+linewidth(1.0pt), arrow=ArcArrow(TeXHead), L=Label("$R_3$", position=EndPoint, W));
fill(shift(p4) * box((-.2,-0.1),(.2,0.1)), .6*white);
fill(shift(p4) * scale(.02) * unitcircle);
draw(shift(p4) * scale(.02) * unitcircle, .6*white+linewidth(1.0pt), L=Label("$P_4$", align=(0,-2)));
draw(p4--(0,5/4), .2*white+red+linewidth(1.0pt), arrow=ArcArrow(TeXHead), L=Label("$R_4$", position=EndPoint, N));
fill(shift(p5) * box((-.2,-0.1),(.2,0.1)), .5*white);
fill(shift(p5) * scale(.02) * unitcircle);
draw(shift(p5) * scale(.02) * unitcircle, .5*white+linewidth(1.0pt), L=Label("$P_5$", align=(0,-2)));
draw(p5--(2,0), .0*white+red+linewidth(1.0pt), arrow=ArcArrow(TeXHead), L=Label("$R_5$", position=EndPoint, E));