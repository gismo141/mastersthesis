import geometry;
texpreamble("\usepackage{lmodern}");

size(20cm,0);
//settings.render=16;

show("$O'$", "$X_{Body}$", "$Y_{Body}$", currentcoordsys, xpen=invisible);
show(shift(2,2) * rotate(-45) * currentcoordsys, xpen=invisible);