# Dungeon Generator

## Description
Dungeon generator that produces a 2D-array of different values that can be used to create a dungeon for 
a game. The script is written in Perl and generates a gif image of the dungeon.

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
    1. Generate rooms of random sizes and make sure that they don't overlap and also got some distance
       between them.
    2. Add doors in the middle of each room.
    3. From each door, try to draw a road of a certain size outwards until it hits either a road
       or another room.
    4. Flood fill each room of the map. Store the biggest flood filled map and remove the rest.

## License
MIT License.

