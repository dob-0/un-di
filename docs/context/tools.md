# Tools

Physical and visual tools used in the practice alongside di.iiii.

Understanding these matters when building di.iiii features — asset pipelines, XR export, live sync, and real-time integrations all need to know what's on the other end.

## TouchDesigner

Real-time AV programming environment. Used for:
- Generative visuals and live visual performance
- Audio-reactive systems (synchronized light shows, installations)
- Interactive installations (body tracking, depth sensors, computer vision input)
- Bridging physical sensors to visual output

In the practice: central to most live A/V work (hayfilm cluster, hosq.co sessions, WIDS, Engineering City). The tool that makes physical systems speak to digital environments in real time.

## Blender

3D modeling, animation, and rendering. Used for:
- 3D modeling and scene design
- 3D printing preparation (Yokozo sculptures, fabricated stage elements)
- Spatial visualization (zoo.3d master plan)
- Asset creation for XR environments

In the practice: the authoring tool for 3D assets that eventually live inside di.iiii spaces or get fabricated physically.

## Resolume

VJ software for live video performance and projection mapping. Used for:
- Building mapping (video projection onto architecture — Engineering City, hayfilm cluster)
- Stage projection and visual design for performances
- Live mixing of generative video content
- Multi-output projection setups

In the practice: the live playback layer. TouchDesigner generates; Resolume deploys to projectors and screens.

## How these relate to di.iiii

```
TouchDesigner / Blender → create content → di.iiii hosts/connects it → XR / web / live output
                                               ↕
                                          Resolume (live projection)
```

di.iiii is the connective layer — it provides the web-accessible, XR-ready environment that content from these tools flows into. Features like asset import, real-time sync, and live performance modes in di.iiii exist because of this pipeline.
