# Desktop Pet
It's Ghost (aka the Knight) from Hollow Knight!

I did all the art (and suffered for it).

# Controls & How to Use
Left click to drag, right click to pet them.
Release left click while moving to throw!

Occasionally they will decide that the middle of your screen is the perfect place to live - you can just yeet them down.

They will also sometimes freeze and turn around like a centrifuge. Give them some time.

# How does this work?
Pain and suffering.

Honestly, though, this was just me wrestling with Godot for 9 hours. And then wrestling with Krita for another 3. I've been animating for years but this was like a hundred unique frames. In five days.

And I've never used Godot before, so yippee new language.

The core of the program is a physics process that does a bunch of stuff to deal with idling and inputs, and then tries to fix turning, before finally adding gravity in like 3 lines. Actually half of the code is just me v.s. animations and flipping animations.

The throwing system works by remembering the velocity of the window before un-clicking and continuing that velocity while decelerating to walking speed. The gravity works like real life physics does (if it were at like middle school level).
