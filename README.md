# 3D-Reconstruction
### Application using NaRPA - a ray-tracing based image rendering engine
Navigation and Rendering Pipeline for Astronautics (NaRPA) ray tracing engine. 

Estimation of 3D points on a terrain using synthetic images generated via NaRPA - the graphics rendering tool. 
The rendered sample images are available in the [images](/images) directory. Respective ground truth data is extracted from [point cloud maps](/3D_data) rendered from NaRPA.

## Note 

This project is only aimed at demonstration and validation of stereo reconstruction / structure from motion (SfM) idea. 
This is a very sparse 2D to 3D correspondence and not full 3D reconstruction. However, the same principle can be deployed for dense 3D reconstruction.


NaRPA repo: https://github.tamu.edu/LASR-New/ScORE-Renderer (not public, individual requests may be entertained)
Paper: Upcoming


## Use
[sfm_main](sfm_main.m) is the main function to be run. Currently, the program only takes in two images from the [images](\images) directory. Using bruteforce feature correspondence using calibrated camera intrinsics, the main function returns 3D coordinates of the matched features. The 2D to 3D correspondence may be established via two methods: (a) [least squares](compute_point.m), (b) [substitution](compute_point2.m). The substitution method is detailed in the NaRPA paper. 

## Citation
Upcoming
