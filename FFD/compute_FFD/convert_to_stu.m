function vertexSTU = convert_to_stu(vert, ffdCoord)

stu_origin = ffdCoord.stuOrigin;
axisS = ffdCoord.axisS;
axisT = ffdCoord.axisT;
axisU = ffdCoord.axisU;

diff = subtraction(vert, stu_origin);

TxU = cross_product(axisT, axisU);
SxU = cross_product(axisS, axisU);
SxT = cross_product(axisS, axisT);

vertexSTU.s = dot_product(TxU,diff) / dot_product(TxU,axisS);
vertexSTU.t = dot_product(SxU,diff) / dot_product(SxU,axisT);
vertexSTU.u = dot_product(SxT,diff) / dot_product(SxT,axisU);

end

%% algebra operations (struct)
function subtract = subtraction(u,v)
subtract.x = u.x - v.x;
subtract.y = u.y - v.y;
subtract.z = u.z - v.z;
end

function crossPdt = cross_product(u,v)
crossPdt.x = u.y*v.z - u.z*v.y;
crossPdt.y = u.z*v.x - u.x*v.z;
crossPdt.z = u.x*v.y - u.y*v.x;
end

function dotPdt = dot_product(u, v)
dotPdt = u.x*v.x + u.y*v.y + u.z*v.z;
end
