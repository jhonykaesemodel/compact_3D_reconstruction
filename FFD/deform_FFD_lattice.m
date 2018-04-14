function [model_def, model_FFD_def] = deform_FFD_lattice(model_FFD, vec_deltaPt)

% FFD with deltaP
Pt_def = model_FFD.P + vec2mat(vec_deltaPt,3);
vertices_def = model_FFD.B * Pt_def;

model_def.vtx = vertices_def;
model_def.mesh = model_FFD.mesh;

model_FFD_def = model_FFD;
model_FFD_def.vtx = vertices_def;
model_FFD_def.Phat = Pt_def;
