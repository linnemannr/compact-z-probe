// Compact Z-Probe
// Author: Reid Linnemann <linnemannr@gmail.com>

//units are mm
switch_width = 12.8;
switch_height = 5;
switch_thickness = 5.7;
switch_hole_diameter = 1.5;
switch_hole_spacing = 6.5;
switch_hole_offset = 1.5;
switch_operating_height = 5.5;


armature_diameter = 2;
shaft_length = 4;
shaft_clearance = 1;
armature_thickness = .75;

probe_diameter = 2.8;
probe_clearance = 0.5;

base_thickness = shaft_length;

switch_hole_depth = switch_thickness/2;

guide_padding = 12;
guide_y = switch_width/2 - switch_operating_height - -switch_hole_offset - probe_clearance + guide_padding;

dovetail_width = switch_width/2;

module armature(collar_d, collar_h, shoulder_d, shoulder_h, l) {
    union() {
        hull() {
            cylinder(h=10, shoulder_h, r=shoulder_d/2, $fn=100);
            translate([0, -l, 0])
                cylinder(h=shoulder_h, r=2.25, $fn=100);
        };
        translate([0,0,1])
        rotate([180,0,0])
            cylinder(h=collar_h+1, r=collar_d/2, $fn=100);
   }
}

module screwtap(r,d) {
    translate([0,0,0.1])
    cylinder(r=r, h=d+0.1, $fn=100);
}

module screwtaps(r,d,w) {
    for(x=[-2, 2]) {
        translate([w/x, 0, 0])
            screwtap(r,d);
    }
}

module probe_guide() {
    difference() {
        cube([switch_width, guide_y, switch_thickness+base_thickness]);
        translate([4, switch_width/2+guide_padding, switch_thickness/2+base_thickness])
            rotate([90,0,0])
                cylinder(r=probe_diameter/2, h=switch_width+guide_padding, $fn=100);
    }
}
module plate(w,h) {
    hull() {
        cube([w, 2*w+guide_padding, h]);
            cube([w/4, w+guide_padding, h]);

    }
}

module full_plate(w,h) {
    difference() {
        plate(w,h);
        translate([w/2,w/2+guide_padding,h-3])
            rotate([0,0,180])
                scale(v=1.1)
                    armature(6,6,6,4,12);
        /*translate([w/2,(switch_height + w)/2+guide_padding, h-switch_hole_depth])
            screwtaps(switch_hole_diameter/2, switch_hole_depth,
                switch_hole_spacing);
 */
    }
}

module dovetail(w,h,l) {
    hull() {
        cube([l, 2*w/3, .01]);
        translate([0,-w/6,-h])
            cube([l,w,.01]);
    }
}
module switch_captor(w,h) {
    union() {
        cube([w, w+2+guide_padding, h]);
        translate([w-dovetail_width, guide_padding/4-.5, 0])
            dovetail(4, 1.75*h, dovetail_width);
        translate([w-dovetail_width, 3*guide_padding/4-.5, 0])
            dovetail(4, 1.75*h, dovetail_width);
        translate([w/2,(switch_height + w)/2+guide_padding, -switch_hole_depth*2/3])
            screwtaps(switch_hole_diameter/3, 2*switch_hole_depth/3,
                switch_hole_spacing);
    }
}
module assembled_guide() {
    difference() {
        union() {
            full_plate(switch_width,base_thickness);
            probe_guide();
        }
        translate([.01,0,base_thickness + switch_thickness]) {
            union() {
                translate([0,.2,0])
                    switch_captor(switch_width,base_thickness);
                translate([0,-.2,0])
                    switch_captor(switch_width,base_thickness);
            }
        }
    }
}

assembled_guide();
translate([-switch_width,0,base_thickness])
rotate([0,180,0])
switch_captor(switch_width, base_thickness);