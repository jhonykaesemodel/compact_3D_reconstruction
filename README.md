<img src="https://jhonykaesemodel.com/img/headers/overview.png" width="800">

# Compact Model Representation for 3D Reconstruction
Here you'll find the codes for the paper **[Compact Model Representation for 3D Reconstruction](https://jhonykaesemodel.com/publication/3dv2017)** presented at 3DV 2017.

## Datasets Used
In this work we used the **[ShapeNetCore.v1](https://www.shapenet.org/)** and **[PASCAL3D+\_release1.1](http://cvgl.stanford.edu/projects/pascal3d.html)** datasets.

## Requirements
To create the embedding graphs you'll need the **[CVX](http://cvxr.com/cvx/)** library.

## Getting Started with a Demo
Running a demo for the aeroplane category:
1. Clone the repo:
```
git clone https://github.com/jhonykaesemodel/compact_3D_reconstruction.git
```
2. Download Pascal3D+ dataset
3. Open `add_paths.m` and change the path `root` with the path of the directory you placed the datasets (*e.g.* `root = 'C:\datasets'`)
4. Download the precomputed data (*i.e.* aeroplane embedding graph files, ShapeNetCore 3D model IDs for all 3D models used and its manually annotated 3D anchors) **[here](https://www.dropbox.com/s/f2895gpuclqvvpt/data_demo.zip?dl=0)**:
5. Unzip it and place the directories `ShapeNetAnchors`, `ShapeNetGraph` and `ShapeNetMat.v1` into the `compact_3d_reconstruction\data\` folder
6. Run `get_started.m` and have fun :)

## Free-Form Deformation (FFD) Demo
To get some intuition about FFD, in the `FFD` directory you'll find `demo_FFD.m`, a tutorial `FFD_tutorial.mlx`, and also a simple FFD UI tool where you can select a control point and play with cursors to deform a 3D mesh model.

To run the FFD UI run `FFD.mat` and click `Init` to load the Standford bunny. Wait until the bunny and the FFD grid of control points are loaded before selecting the control points and playing with the cursors.

## Reference
If you find this code useful in your research, please cite the [**paper**](https://128.84.21.199/pdf/1707.07360.pdf):
```
@article{pontes2017compact3d,
  title={Compact Model Representation for 3D Reconstruction},
  author={Jhony K. Pontes and Chen Kong and Anders Eriksson and Clinton Fookes and Sridha Sridharan and Simon Lucey},
  journal={International Conference on 3D Vision (3DV)},
  year={2017}
}
```
