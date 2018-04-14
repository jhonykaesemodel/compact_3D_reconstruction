import argparse
parser = argparse.ArgumentParser()
parser.add_argument('-c', default='03001627', help='Class UID')
parser.add_argument('-r', type=int, default=32, help='Volumetric resolution')
params = parser.parse_args()
clsuid = params.c
g = params.r

import binvox_rw
import scipy.io as sio
import os
import numpy as np
def write_obj(fdir, name, vertices, faces):
    objname = os.path.join(fdir, name+'.obj')
    with open(objname, 'w') as fid:
        for v in vertices:
            fid.write('v {:.4f} {:.4f} {:.4f}\n'.format(*v))
        for f in faces:
            fid.write('f {:d} {:d} {:d}\n'.format(*f))

def convert_voxel(fdir, name):
    bvfile = os.path.join(fdir, name+'.binvox')
    if os.path.isfile(bvfile):
        os.system('rm -rf {}'.format(bvfile))
    objfile = os.path.join(fdir, name+'.obj')
    cmd = './binvox -d {} -bb -0.5 -0.5 -0.5 0.5 0.5 0.5 -cb -e '.format(g)+\
            '-t binvox -ri {}'.format(objfile) # unix
    #cmd = 'binvox.exe -d {} -bb -0.5 -0.5 -0.5 0.5 0.5 0.5 -cb -e '.format(g) + \
    #      '-t binvox -ri {}'.format(objfile) # windows
    os.system(cmd)

    # generate matlab
    vmatfile = os.path.join(fdir, '{}_vxl.mat'.format(name))
    with open(bvfile, 'rb') as f:
        voxel = binvox_rw.read_as_3d_array(f)
        sio.savemat(vmatfile, {'voxel':voxel})

#filedir = os.path.join('C:/dataset/ShapeNetMat.v1/', clsuid) # windows
filedir = os.path.join('/dataset/ShapeNetMat.v1/', clsuid)

arange = np.arange(g)*2/g-1+1/g
X, Y, Z = np.meshgrid(arange, arange, arange)
x = X.reshape([-1])
y = Y.reshape([-1])
z = Z.reshape([-1])
files = os.listdir(filedir)
for f in files:
    pre, ext = os.path.splitext(f)
    if ext == '.mat':
        if f.endswith('_vxl.mat'):
            continue
        matcontent = sio.loadmat(os.path.join(filedir, f))
        vertices = matcontent['model'][0][0][5]
        faces = matcontent['model'][0][0][6]
        write_obj(filedir, pre, vertices, faces);
        convert_voxel(filedir, pre);
