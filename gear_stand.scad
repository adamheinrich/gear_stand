/*
 *  Parametric gear stand
 *
 *  Copyright (C) 2020 Adam Heinrich <adam@adamh.cz>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

include <Round-Anything/MinkowskiRound.scad>;

$fn = 250;

/* Gear geometry: */
gear_size = 177;
gear_depth = 12;

/* Stand geometry: */
stand_width = 39;
shear = 20;
angle = 28;
radius = 4;

/* Bottom rubber feet parameters
   MPN: 3M SJ5012 (7000001884): */
has_bottom_feet = true;
foot_diameter = 12.7 + 0.8;
foot_depth = 0.5;
foot_double = true;
foot_edge_distance = 1.5;

/* Anti-slip rubber parameters
   MPN: Fix & Fasten FIX-SF-152530: */
has_rubber = true;
rubber_w = 25 + 0.8;
rubber_h = 15 + 0.8;
rubber_z = 2.5;

/* Computed global variables: */
r2 = radius;
r1 = gear_depth - r2;

hyp = gear_size - gear_depth + r2;
x = hyp * cos(angle);
y = hyp * sin(angle);

module stand_2d() {
    pts=[[0, 0],
         [x + shear,0],
         [x, y]];

    difference() {
        minkowski() {
            difference() {
                /* Main body: */
                minkowski() {
                    polygon(pts);
                    circle(r = r1);
                }

                /* Cutout for the gear: */
                rotate(angle) {
                    translate([0, -r2]) {
                        square([gear_size, gear_depth + r2]);
                    }
                }
            }
            
            /* Extra rounding: */
            if (r2 > 0) {
                circle(r = r2);
            }
        }

        /* Copy of the polygon with reinforced hypotenuse: */
        dx = gear_depth / sin(angle);
        pts_inside = pts * (x + shear-dx) / (x + shear);
        
        /* Internal cutout: */
        translate([gear_depth / sin(angle), 0]) {
            round2d(r2, 0) {
                polygon(pts_inside);
            }
        }
    }
}

module stand_3d() {
    difference() {        
        /* Main body: */
        minkowski() {
            linear_extrude(height = stand_width, center = true) {
               stand_2d();
            }
        }
 
        /* Bottom feet: */
        if (has_bottom_feet) {
            for (i = [0, 1], j = [-1, 1]) {              
                dy = stand_width / 2 - foot_diameter / 2 - foot_edge_distance;
                posy = foot_double ? j * dy : 0;
                posx = (1 - 2 * i) * foot_diameter + i * (x + shear);

                rotate([-90, 0, 0]) {
                    translate([posx, posy, -gear_depth]) {
                        cylinder(d = foot_diameter,
                                 h = foot_depth * 2,
                                 center = true);
                    }
                }
            }
        }

        /* Anti-slip rubber on the hypotenuse: */
        if (has_rubber) {
            for (i = [0, 1]) {
                posx = (1 - 2 * i) * (1.5 * rubber_h) + i * gear_size;

                rotate([0, 0, angle]) {
                    translate([posx, -rubber_z/2, 0]) {
                        cube([rubber_h, rubber_z, rubber_w], center = true);
                    }
                }
            }
        }
    }
}

//stand_2d();
stand_3d();
