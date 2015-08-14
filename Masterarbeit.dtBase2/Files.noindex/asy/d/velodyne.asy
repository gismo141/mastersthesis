import solids;

surface velodyne() {
    real heightV=.8;
    path3 laserBase = path3((-0.4,0.7) -- (-0.5,sin(acos(-0.5))) .. (-1,0) .. (0,-1) .. (1,0) .. (0.5,sin(acos(0.5))) -- (0.4,0.7));

    surface top = shift(0.9Z) * scale(1,1,0.4) * unithemisphere;
    surface upperhead = surface(shift(0.4Z) * scale(1,1,0.5) * unitcylinder);
    surface laserEye = surface(shift(heightV/2*Z) * surface(unitcircle), shift(-heightV/2*Z) * extrude(laserBase --- cycle, heightV*Z), shift(-heightV/2*Z) * surface(unitcircle));
    surface lowerhead = surface(shift(-0.7Z) * scale(1,1,0.3) * unitcylinder, shift(-1Z) * surface(unitcircle));
    surface base = surface(shift(-0.75Z) * surface(unitcircle), shift(-1.7Z) * scale(1,1,0.95) * unitcylinder);
    surface velodyne = surface(top, upperhead, laserEye, lowerhead, base);

    return velodyne;
}