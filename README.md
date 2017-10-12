# arkit-demo

The art assets come from:

https://opengameart.org/node/11950 — hardwood

https://opengameart.org/content/tiling-cardboard-texture - cardboard

## face detection

the following comment is in regards to using the Vision Framework + ARKit (for the video frames) on an iPhone 6s running iOS 11.1 Public Beta 1

this feature is *super* experimental, and at this time it doesn't work as you would think due to the limited capabilities of the Vision Framework. Currenlty, the Vision Framework doesn't support tracking detected faces and face landmarks between video frames
(i'm happy to be proven wrong, tho!). At best, Vision can track "detected objects" (aka, the base class, aka rectangles) between vido frames. So, this code doesn't use "tracking" of the detected face, but rather asks for a new face for each frame, which is really expensive as you can tell by the complete drop in frame rate.

tbd if limiting the number of sampled frames increases performance
