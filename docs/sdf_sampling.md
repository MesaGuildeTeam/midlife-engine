# A Re-evaluation of Implicit Mesh Sampling Algorithms by using Vertex Projection

Roberto Selles

## Introduction

There are a variety of approaches to render SDFs from ray marching approaches,
from Marching Cubes to even Ray Marching. However, the usage of
Explicitly-defined mesh rasterization has been the standard for real-time
rendering in videogames so this document assumes we are taking existing SDFs
and sampling them in such a way that we can produce explicitly defined meshes.
Therefore this research document is a re-evaluation of methods of producing
explicitly defined meshes from implicitly defined meshes.

## Background

Signed Distance Functions, or SDFs are implicitly defined functions used to
represent the distance to a surface. These can take in both a 3D and 2D input,
but for the sake of this document, this will have a focus on 3D SDFs. When the
point used as an input is outside the surface, the function will return a
positive number and if the point used as input is inside the surface, the
function will return a negative. A very simple example of an SDF is the distance
from a sphere with a radius $r$.

Similarily, with the use of SDFs, there are functions to determine the gradient
of these shapes, which become used to represent the normal of the SDF. We can
approximate it as usual, however, there are also predefined function that can
be used to represent these functions.

$$
let\space P \in \mathbb{R}^3,r\in\mathbb{R} \\
f(P)=||P|| - r \\
\nabla f(P) = \frac{P}{||P||}
$$
Figure 1. Mathematical definition of the SDF and gradient of a sphere (Quilez 2025)

### Implicit Mesh Sampling and Rendering

There are a collection of well known mesh generation methods that use quads as
surfaces. The most recognized ones are:
- Marching Cubes
- Surface Nets
- Voxelization
- Octrees
- Greedy Meshing

All of these methods render volumes very well, but none of them take into
consideration of applying its gradient to correct the error from the defined
surface.

## Setup

This document proposes the use of projection to refine the accuracy of the
vertices of a mesh. to do so, we will modify the mesh generation process of
voxel sampling to position each vertex as close as possible to the surface.

$$
P_1 = P + \nabla f(P) \cdot f(P)
$$
Figure 2. Formula used to project the mesh assuming the gradient faces outward

We run the test on the following algorithms:
- Symmetrically Distributed Sampling
- Sparse Voxel Octrees
- Naive Greedy Meshing

## Results

Symmetrically Distributed Sampling:

- This is the best option due to its simplicity and effectiveness. There is 
little error in the mesh generation and it is easy to implement.

Sparse Voxel Octrees:

- More complex to implement, but can faster results with less memory usage.
- Sometimes there is a little bit of triangle overlap, but that could be
due to the implementation of the mesh generation algorithm not implementing
the sampled data properly.
- This method works better with simpler models, complex models can render more
errors

Naive Greedy Meshing:

- Although it is ironically the fastest, it produces the worst meshes due to
its assumptions of the model being a grid of boxes.

## Resources
