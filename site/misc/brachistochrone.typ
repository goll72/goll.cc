#import "/lib/lib.typ": *

#import "@preview/zero:0.5.0": zi

#let m = zi.declare("m")
#let s = zi.declare("s")
#let m-s2 = zi.declare("m/s^2")
#let kg = zi.declare("kg")

#show: page
#show: article

= Brachistochrone Demo

A brachistochrone curve is a curve that reduces the time needed
for a body under the influence of gravity to go from one point
to another.

Click #link("./brachistochrone/demo")[here] to see a physical simulation of such a
curve, that allows for measuring how long a ball with radius $r = 1/(2 sqrt(pi)) #m()$
and density $mu = 4$ (mass $m = 1$) takes to complete its trajectory going from an
initial to a final position when following a brachistochrone curve, and comparing it
to a straight line path.

#quote[
  In an ideal scenario, considering $m = #kg(1)$ and $g = #m-s2(9.81)$, the time taken
  for a point mass to go from $(0, 10)$ to $(10, 0)$ (the default simulation parameters)
  is approximately #s(1.84). The time measured by the simulation will invariably be higher,
  for various reasons, the most notorious being not actually using a point mass.
]

The simulation was written in Rust, using the Bevy game engine and the Rapier physics
engine, implementing an algorithm based on Dynamic Programming to approximate the
brachistochrone curve. The source code for the simulation can be found
#link("https://github.com/goll72/brachistochrone")[here].
You will need a browser with support for JavaScript, WebAssembly and WebGL to run
the simulation.
