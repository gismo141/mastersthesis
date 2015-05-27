module velodyne() {
    %color("red") circle(r=5);  // center of gravity
    %circle(d=85.3);  // base
    translate([-51.6/2,-51.6/2]) circle(d=4.2);
    translate([-51.6/2,51.6/2]) circle(d=4.2);
    translate([51.6/2,-51.6/2]) circle(d=4.2);
    translate([51.6/2,51.6/2]) circle(d=4.2);
    translate([51.6/2,51.6,10]) cube([51.6,5,5]);
}

module imar_iTraceRT_F400() {
    %color("red") circle(r=5);  // center of gravity
    height = 160;
    width = 186;
    cog_x = 93+37.4;
    cog_y = (height-104.2);
    %translate([-cog_x,-cog_y]) square([width,height]); // base
    translate([-cog_x+width/2+67, -cog_y+10]) circle(d=5);
    translate([-cog_x+width/2+80.5, -cog_y+150.5]) circle(d=5);
    translate([-cog_x+width/2-79, -cog_y+16]) circle(d=5);
    translate([-cog_x+width/2-79, -cog_y+150.5]) circle(d=5);
    // H7 +0.01 0
    //translate([-cog_x+width/2+68.5, -cog_y+59.5]) circle(d=5);
    //translate([-cog_x+width/2-78, -cog_y+59.5]) circle(d=5);
}

linear_extrude([0,0,5]){
difference() {
    square([370,230],0);  // mounting plate (threadhead in plate)
    translate([50,80]) velodyne();
    translate([50,180]) rotate([0,0,-45]) velodyne();
    translate([25,7]) text("HDL-32e");
    translate([300,80]) imar_iTraceRT_F400();
    translate([210,7]) text("imar iTraceRT-F400");
}}