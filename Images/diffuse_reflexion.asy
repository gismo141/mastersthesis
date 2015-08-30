settings.render = 4;
size(20cm,0);
texpreamble("\usepackage[setpagesize=false]{hyperref}");

path surf = (0,0) .. (1,.01) .. (1.5,-.02) .. (1.7,.05) .. (2.3,.04) .. (3.1,-.02) .. (3.5,0);
draw(shift(0,-.1) * surf, linewidth(30.0pt)+.8white);
draw(surf, linewidth(3.0pt));

draw(shift(0,2.15) * rotate(-60) * ((0,0)--(2.5,0)), red+linewidth(1.0pt));
draw(shift(1.25,-.01) * rotate(50) * ((0,0)--(2.5,0)), blue+linewidth(1.0pt), arrow=ArcArrow(TeXHead));

draw(shift(0.25,2.16) * rotate(-60) * ((0,0)--(2.5,0)), red+linewidth(1.0pt));
draw(shift(1.5,0) * rotate(70) * ((0,0)--(2.5,0)), blue+linewidth(1.0pt), arrow=ArcArrow(TeXHead));