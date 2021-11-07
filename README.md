# Wilson-Cowan WebApp
A simulation of the Wilson-Cowan done in Godot Engine 3.3.4, thought to be run on the web. 

## How does it work?

The app uses shaders to integrate the system efficiently. In order to be able to do it in the web, a double-buffered system is needed. The Godot project has the following architecture:

```
-- Node2D
----- SpriteRenderer
----- ViewportA
-------- ColorRect
----- ViewportB
-------- Sprite
```

The sprite at the top is receiving the texture from `ViewportA`. This Viewport has a black ColorRect with the shader that performs the computations. The shader needs to have the information from the last timestep, which is passed as an `uniform sampler2D last_frame `. Feedback loops are forbidden in WebGL, so this parameter cannot be set to the output texture from the parent Viewport. It is necessary to set up a new Viewport, `ViewportB`, which has a Sprite that renders the texture from `ViewportA`. And then, the output of this new Viewport can be sent back to `last_frame` in the shader. 

Important: the clear mode of the `ViewportA` has to be set to "Next Frame" in order to allow the feedback loop between the viewports.