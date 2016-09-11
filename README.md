# Dungeon Generator

## Description
Dungeon generator that produces a 2D-array of different values that can be used to create a dungeon for 
a game. The script is written in Perl and generates a gif image of the dungeon.

The values used for the algorithm in the 2D array is the following:
* 1 = room
* 2 = road
* 3 = Flood fill, temporary used, not used in the resulting map (array).
* 4 = (not used)
* 5 = Player spawn (adds a position in the middle of a room)
* 6 = Boss spawn (adds a position in a room as far away as possible from player)

The image used in the script is just used to represent the actual dungeon. In a game, the 2D array would be used and the different values in the array would be parsed.

The result of the script can look like this:
[dungeon.gif]
![alt tag](https://github.com/Lallassu/DungeonGenerator/blob/master/dungeon.gif)

The dungeon generator will be used in Qake voxel-engine that can be found here:
https://www.assetstore.unity3d.com/#!/content/68150

And the result implemented in Qake voxel engine using the output from the script (though ported to C#) can look like this:
[qake_dungeon.png]
![alt tag](https://github.com/Lallassu/DungeonGenerator/blob/master/qake_dungeon.png)

## Run
```
perl genmap.pl && open dungeon.gif
```

## Algorithm
The algorithm is very basic but produces very good random dungeons. 
The process is as follows.
* Generate rooms of random sizes and make sure that they don't overlap and also got some distance between them.
* Add doors in the middle of each room.
* From each door, try to draw a road of a certain size outwards until it hits either a road or another room.
* Flood fill each room of the map. Store the biggest flood filled map and remove the rest.


## License
MIT License.

