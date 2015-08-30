settings.render = 4;
size(20cm,0);
texpreamble("\usepackage[setpagesize=false]{hyperref}");

fill(box((0,0),(3.5,-.2)),.8white);
draw((0,0)--(3.5,0), linewidth(3.0pt));

draw(shift(0,2.16) * rotate(-60) * ((0,0)--(2.5,0)), red+linewidth(1.0pt));
draw(shift(1.25,0) * rotate(60) * ((0,0)--(2.5,0)), red+linewidth(1.0pt), arrow=ArcArrow(TeXHead));

draw(shift(0.25,2.16) * rotate(-60) * ((0,0)--(2.5,0)), red+linewidth(1.0pt));
draw(shift(1.5,0) * rotate(60) * ((0,0)--(2.5,0)), red+linewidth(1.0pt), arrow=ArcArrow(TeXHead));