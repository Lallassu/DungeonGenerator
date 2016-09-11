#!/usr/bin/perl -w
#   The MIT License (MIT)
#   
#   Copyright (c) 2016 Magnus Persson (magnus@nergal.se)
#   
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#   
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.
use strict;
use GD;
use Data::Dumper;

my $width = 512;
my $height = 512;
my $ok = 0;

my $image;
my $black;
my $red;
my $green; 
my $blue;
my $white;
my $player_spawn;
my $portal_spawn;
my @map;
my @map2;
my @doors;
my @spawns;

main();

sub main {
    InitImage();
    InitMap();
    CreateRooms();
    CreateRoads();

    my @list;
    my $max_count = 0;

    for(my $x = 0; $x < $width ; $x++) {
        for(my $y = 0; $y < $height ; $y++) {
            $map2[$x][$y] = $map[$x][$y];
        }
    }
    my %world = ();
    while(!$ok) {
        my $start_y = 0;
        my $start_x = 0;
        for(my $x = 0; $x < $width; $x++) {
            for( my $y = 0; $y < $height; $y++) {
                if($map2[$x][$y] == 1 || $map2[$x][$y] == 2) {
                    $start_x = $x;
                    $start_y = $y;
                    last;
                }
            }
            if($start_x != 0) {
                last;
            }
        }

        my $res = FloodFill($start_x,$start_y);
        if($res->{count} == 1) {
            $ok = 1;
        } else {
            $world{$res->{count}} = $res->{list};
        }
    }
    my $largest = 0;
    foreach(keys %world) {
        if($_ > $largest) {
            $largest = $_;
        }
    }
    foreach(keys %world) {
        if($_ == $largest) {
            next;
        }
        foreach my $l (@{$world{$_}}) {
            $map[$l->[0]][$l->[1]] = 0;
            # Remove doors if included here.
            my $i = 0;
            foreach my $d (@doors) {
                $i++;
                if($d->[0] == $l->[0] && $d->[1] == $l->[1]) {
                    splice(@doors, $i, 1);
                }
            }
        }
    }
    Spawn();
    DrawMap();
}

sub InitImage {
    $image = new GD::Image($width, $height);
    $black = $image->colorAllocate(50,50,50);
    $red = $image->colorAllocate(255,0,0);
    $green = $image->colorAllocate(0,255, 0);
    $blue = $image->colorAllocate(0,0, 255);
    $white = $image->colorAllocate(255,255,255);
    $player_spawn = $image->colorAllocate(0,255,0);
    $portal_spawn = $image->colorAllocate(0,255,255);
}

sub InitMap {
    for(my $x = 0; $x < $width; $x++) {
        for( my $y = 0; $y < $height; $y++) {
            $map[$x][$y] = 0;
        }
    }
}

sub CreateRooms {
    for(my $i = 0; $i < 100; $i++) {
        my $rx = 50+int(rand($width-100));
        my $ry = 50+int(rand($height-100));

        my $size_w = 50+int(rand(50));
        my $size_h = 50+int(rand(50));

        # Check if ok
        my $free = 1;
        for(my $x = $rx - int($size_w/1.1); $x < int($rx + $size_w/1.1); $x++) {
            for(my $y = int($ry - $size_h/1.1); $y < int($ry + $size_h/1.1); $y++) {
                if($x > 0 && $x < $width && $y > 0 && $y < $height) {
                    if($map[$x][$y] == 1) {
                        $free = 0;
                        last;
                    }
                }
            }
            if(!$free) { last; }
        }

        if($free) {
            for(my $x = $rx - int($size_w/2); $x < int($rx + $size_w/2); $x++) {
                for(my $y = int($ry - $size_h/2); $y < int($ry + $size_h/2); $y++) {
                    $map[$x][$y] = 1;
                    if($x == $rx && $y == $ry) {
                        push(@spawns, [$x,$y]);
                    }
                    if($x == $rx && $y == int($ry-$size_h/2) ) {
                        $map[$x][$y] = 2;
                        push(@doors, [$x, $y]);
                    }
                    if($x == $rx && $y == int($ry+$size_h/2-1) ) {
                        $map[$x][$y] = 2;
                        push(@doors, [$x, $y]);
                    }
                    if($y == $ry && $x == $rx-int($size_w/2)) {
                        $map[$x][$y] = 2;
                        push(@doors, [$x, $y]);
                    }
                    if($y == $ry && $x == $rx+int($size_w/2-1)) {
                        $map[$x][$y] = 2;
                        push(@doors, [$x, $y]);
                    }
                }
            }
        }
    }
}

sub CreateRoads {
    my $roadSize = 10;
    foreach my $p (@doors) {
        my $count = 1;
        my @list = [];
        my $roadFail = 0;
        while($map[$p->[0]+$count][$p->[1]] == 0 && $p->[0]+$count > 1 && $p->[0]+$count < $width - 1) {
            # Check if we can make a broad road.
            for(my $yy = $p->[1]-$roadSize/2; $yy < $p->[1]+$roadSize/2; $yy++) {
                if($yy > 1 && $yy < $height) {
                    # Do not hit room our existing road.
                    if($map[$p->[0]+$count][$yy] == 1 || $map[$p->[0]+$count][$yy] == 2) {
                        $roadFail = 1;
                        last;
                    }
                }
            }
            if($roadFail) {
                last;
            }
            push(@list, [$p->[0]+$count, $p->[1]]);
            $count++;
        }
        if(!$roadFail) {
            for(my $yy = $p->[1]-$roadSize/2; $yy < $p->[1]+$roadSize/2; $yy++) {
                if($yy > 1 && $yy < $height) {
                    # Do not hit room our existing road.
                    if($map[$p->[0]+$count][$yy] == 0) {
                        $roadFail = 1;
                        last;
                    }
                }
            }
            if(!$roadFail) {
                foreach(@list) {
                    if(defined($_->[0])) {
                        for(my $yy = $_->[1]-$roadSize/2; $yy < $_->[1]+$roadSize/2; $yy++) {
                            $map[$_->[0]][$yy] = 2;
                        }
                    }
                }
            }
        }

        $count = 1;
        @list = [];
        $roadFail = 0;
        while($map[$p->[0]][$p->[1]+$count] == 0 && $p->[1]+$count > 1 && $p->[1]+$count < $height- 1) {
            for(my $xx = $p->[0]-$roadSize/2; $xx < $p->[0]+$roadSize/2; $xx++) {
                if($xx > 1 && $xx < $width) {
                    if($map[$xx][$p->[1]+$count] == 1 || $map[$xx][$p->[1]+$count] == 2) {
                        $roadFail = 1;
                        last;
                    }
                }
            }
            if($roadFail) {
                last;
            }
            push(@list, [$p->[0], $p->[1]+$count]);
            $count++;
        }
        if(!$roadFail) {
            for(my $xx = $p->[0]-$roadSize/2; $xx < $p->[0]+$roadSize/2; $xx++) {
                if($xx > 1 && $xx < $width) {
                    if($map[$xx][$p->[1]+$count] == 0) {
                        $roadFail = 1;
                        last;
                    }
                }
            }
            if(!$roadFail) {
                foreach(@list) {
                    if(defined($_->[0])) {
                        for(my $xx = $_->[0]-$roadSize/2; $xx < $_->[0]+$roadSize/2; $xx++) {
                            $map[$xx][$_->[1]] = 2;
                        }
                    }
                }
            }
        }
    }
    foreach my $d (@doors) {
        $map[$d->[0]][$d->[1]] = 1;
    }
}

# Floodfill to see if the map is complete.
sub FloodFill {
    my $start_x = shift;
    my $start_y = shift;

    my @stack;
    push(@stack, [$start_x,$start_y]);

    my $p;
    my $count = 0;
    my @list;
    while($#stack > -1) {
        $p = pop(@stack);
        push(@list, $p);
        $count++;
        if($map2[$p->[0]][$p->[1]] == 1 || $map2[$p->[0]][$p->[1]] == 2) {
            $map2[$p->[0]][$p->[1]] = 3;
            if($p->[0]+1 > 0 && $p->[0]+1 < $width) {
                push(@stack, [$p->[0]+1, $p->[1]]);
            }
            if($p->[0]-1 > 0 && $p->[0]-1 < $width) {
                push(@stack, [$p->[0]-1, $p->[1]]);
            }
            if($p->[1]-1 > 0 && $p->[1]-1 < $height) {
                push(@stack, [$p->[0], $p->[1]-1]);
            }
            if($p->[1]+1 > 0 && $p->[1]+1 < $height) {
                push(@stack, [$p->[0], $p->[1]+1]);
            }
        }
    }

    return {list => \@list, count => $count, status => 1};
}

sub Spawn {
    my $player;
    my $portal;

    my $max_dist = 0;
    foreach my $p (@spawns) {
        foreach my $p2 (@spawns) {
            my $dist = sqrt((($p2->[0]-$p->[0])**2)+(($p2->[1]-$p->[1])**2));
            if($dist > $max_dist) {
                $max_dist = $dist;
                $player = [$p->[0], $p->[1]];
                $portal = [$p2->[0], $p2->[1]];
            }
        }
    }
    $map[$player->[0]][$player->[1]] = 5;
    $map[$portal->[0]][$portal->[1]] = 6;
}

sub DrawMap {
    for(my $x = 0; $x < $width; $x++) {
        for( my $y = 0; $y < $height; $y++) {
            if($map[$x][$y] == 1) {
                $image->setPixel($x, $y, $red);
            }
            if($map[$x][$y] == 2) {
                $image->setPixel($x, $y, $green);
            }
            if($map[$x][$y] == 3) {
                $image->setPixel($x, $y, $white);
            }
            if($map[$x][$y] == 4) {
                $image->setPixel($x, $y, $green);
            }
            if($map[$x][$y] == 5) {
                $image->setPixel($x, $y, $player_spawn);
            }
            if($map[$x][$y] == 6) {
                $image->setPixel($x, $y, $portal_spawn);
            }
        }
    }

    binmode STDOUT;
    open(FILE, "+>dungeon.gif");
    print FILE $image->gif;
    close(FILE);
}

