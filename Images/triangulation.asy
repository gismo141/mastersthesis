settings.render = 4;
size(20cm,0);
texpreamble("\usepackage[setpagesize=false]{hyperref}");

import fontsize;
defaultpen(fontsize(30));

pair pos_laser = (0,2);
pair pos_detektor = (0,1);

path laser = (-.5,-.25) -- (.5,-.25) -- (.5,-.15) -- (.55,-.15) -- (.55,.15) -- (.5,.15) -- (.5,.25) -- (-.5,.25) --cycle;
draw(shift(pos_laser) * rotate(-20) * laser, L=Label("Emitter", S, align=(-1,0)), .5white);
fill(shift(pos_laser) * rotate(-20) * laser, .5white);
path detektor = box((-.15,-.25),(.15,.25));
fill(shift(pos_detektor) * box((-.15,-.25),(-.1,.25)), .5white);
draw(shift(pos_detektor) * detektor, L=Label("Detektor", S), .5white);

pair p0 = (-.15,1);
pair p1 = (.52,1.8);
pair p2 = (4,.5);

draw(p1 -- p2 -- p0, red+linewidth(1.0pt), arrow=Arrow(TeXHead,Relative(.75)));
draw(shift(pos_detektor) * (.15,0) -- p1, L=Label("$d$"), arrow=Arrows(TeXHead),WNW);

fill(box((-2,0),(5,-.2)),.8white);
draw((-2,0)--(5,0), linewidth(3.0pt));
fill(shift((.45,0)) * shift(p2) * scale(.48) * unitcircle, .5white);

draw(shift(0,1) * rotate(-90) * ((0,0) .. (.25,.75) .. (1,1)));