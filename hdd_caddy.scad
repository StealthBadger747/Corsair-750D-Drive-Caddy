include <shape_trapezium.scad>;

// Hard Drive Width plus a bit of tolerance
$hhdWidth = 102.15;

// Base Plate
$baseHeight_mm = 1;
$baseLength_mm = 126;
$baseWidth_mm = 116;
// Base Plate holes
$baseHoleWidth_mm = 37;
$baseHoleLength_mm = 52;

// Rails
$railHeight_mm = 11.5;
$railLength_mm = $baseLength_mm;
$railWidth_mm = ($baseWidth_mm - $hhdWidth) / 2;

// Rail Lever
$railLeverHeight = $railHeight_mm;
$railLeverWidth = 2.5;
$railLeverTabLength = 22;

// Rail Notch
$railNotchHeight = $railHeight_mm - 4;
$railNotchLength = $railLength_mm - 8;
$railNotchWidth = $railWidth_mm - 1;

// HDD hole locations starting from the back
$holeXAxisOffset_mm = 18;
$holeHeightOffset = $baseHeight_mm + 6;
$holeDiameter_mm = 4;

$holeOne = $holeXAxisOffset_mm + 0;
$holeTwo = $holeXAxisOffset_mm + 37 + $holeDiameter_mm;
$holeThree = $holeXAxisOffset_mm + 97 + $holeDiameter_mm;

// Triangle Clip
$clipXOffset = $baseLength_mm + 7.4 + 4.8;
$clipHeight = 6.4;
$clipLength = 4.45;
$clipWidth = 1.5;


// Draw the base unit and next draw the clip and lever
union() {
    // Draw the base plate
    difference() {
        // Base Cube
        cube([$baseLength_mm,$baseWidth_mm,$baseHeight_mm]);
        
        // The holes in the base plate
        firstBaseHoles();
        secondBaseHoles();
    }
    
    // Draw the first rail
    firstRail();

    // Draw the second rail
    secondRail();
}

module firstBaseHoles() {
    quadrantLength = $baseLength_mm / 2;
    quadrantWidth = ($baseWidth_mm / 2) + 3 * $railWidth_mm;
    xPos1 = abs(quadrantLength - $baseHoleLength_mm) / 2;
    yPos1 = abs(quadrantWidth - $baseHoleLength_mm) / 2;
    
    translate([xPos1, yPos1, 0]) {
        roundedcube([$baseHoleLength_mm,$baseHoleWidth_mm,$baseHeight_mm],
        false, 6, "z");
    }
    
    xPos2 = xPos1 + quadrantLength;
    yPos2 = yPos1;
    translate([xPos2, yPos2, 0]) {
        roundedcube([$baseHoleLength_mm,$baseHoleWidth_mm,$baseHeight_mm],
        false, 6, "z");
    }
}

module secondBaseHoles() {
    translate([0, $baseWidth_mm, 0]) {
        mirror([0,1,0]) {
            firstBaseHoles();
        }
    }
}
    

// It is really (x,y,z), but named differently because the rotate
// screws it up.
module screwHole(xOffset, zOffset, yOffset) {
    rotate(a=[90,0,0]) {
        translate([xOffset,yOffset,(0 - $railWidth_mm)]) {
            cylinder(h=$railWidth_mm, d=$holeDiameter_mm,$fn=20);
        }
    }
}

module firstRail() {
    translate([0,0,$baseHeight_mm]) {
        // The rail base
        difference() {
            // The rail rectangle
            cube([$railLength_mm,$railWidth_mm,$railHeight_mm]);
            // Hole One
            screwHole($holeOne,(0 - $railWidth_mm),$holeHeightOffset);
            // Hole Two
            screwHole($holeTwo,(0 - $railWidth_mm),$holeHeightOffset);
            // Hole Three
            screwHole($holeThree,(0 - $railWidth_mm),$holeHeightOffset);
            // Notch
            translate([5, 0, 3]) {
                cube([$railNotchLength,$railNotchWidth,$railNotchHeight]);
            }
        }
        // Side supports/reinforcement
        for (i = [1,3,4,5,5.8,,7.65,8,9,10,11,12,13]) {
            translate([($railLength_mm / 15) * i, 0, 0])
            cube([3.2,$railWidth_mm,$railHeight_mm]);
        }
  
        // Rail One's Clip
        translate([$clipXOffset, 0 - $clipWidth, ($railHeight_mm / 3)]) {
            rotate(a=[0,270,-15]) {
                l = $clipLength;
                w = $clipWidth;
                h = $clipHeight;
                polyhedron(
                    points=[[0,0,0],
                            [l,0,0],
                            [l,w,0],
                            [0,w,0],
                            [0,w,h],
                            [l,w,h]],
                    faces=[[0,1,2,3],
                            [5,4,3,2],
                            [0,4,5,1],
                            [0,3,4],
                            [5,2,1]]
                );
            }
        }
        
        // Rail One's Lever
        translate([$railLength_mm + 4, 0, $railHeight_mm / 2]) {
            rotate(a=[180,90,-90]) {
                linear_extrude(height=$railLeverWidth,
                scale=1, slices=20, twist=0)
                polygon(
                    shape_trapezium([$railHeight_mm / 2, $railHeight_mm], 
                    h=8,
                    corner_r=0)
                );
            }
        }
        // Lever continued
        translate([$railLength_mm + 8, 0, $railHeight_mm / 4]) {
            cube([$railLeverTabLength, $railLeverWidth,$railHeight_mm / 2]);
        }
    }
}

module secondRail() {
    translate([0, $baseWidth_mm, 0]) {
        mirror([0,1,0]) {
            firstRail();
        }
    }
}

/** ------------ Rounded Cube ------------ **/

// Higher definition curves
$fs = 0.01;

module roundedcube(size = [1, 1, 1], center = false, radius = 0.5,
    apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	module build_point(type = "sphere", rotate = [0, 0, 0]) {
		if (type == "sphere") {
			sphere(r = radius);
		} else if (type == "cylinder") {
			rotate(a = rotate)
			cylinder(h = diameter, r = radius, center = true);
		}
	}

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							build_point("sphere");
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							build_point("cylinder", rotate);
						}
					}
				}
			}
		}
	}
}
