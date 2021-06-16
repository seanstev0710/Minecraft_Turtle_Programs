# Minecraft Turtle Programs

This is a collection of several Minecraft ComputerCraft turtle programs.

------------------------------------------------------------------------------

## [Dig.lua](dig.lua)
dig.lua will make the turtle mine a square of length "x" read from user input.
It will mine from y-axis 16 to 11, under the assumption that the user input for the current y-value is correct.

- Turtle sends location to a remote computer if GPS is setup
- Returns to start location if fuel is low or if inventory is full
- Goes back to mining after resupplying

### bugs

1. The turtle occassionally gets lost and eventually mines in a straight line until it reaches an unloaded chunk.

2. The turtle can run out of fuel without reaching starting location

### Features to add

1. Have multiple turtles work together by being launched from a main computer

2. Turtles will go around any specified ores written in a config file


------------------------------------------------------------------------------
