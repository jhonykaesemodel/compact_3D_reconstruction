classdef ClassFFD
    properties
        %Value
    end
    methods(Static)
        %% get the FFD coordinate system (STU)
        function ffdCoord = initAxes(meshInfo)
            minimum = meshInfo.minXYZ;
            maximum = meshInfo.maxXYZ;
            
            % origin of STU is min selected vertices
            stuOrigin.x = minimum.x;
            stuOrigin.y = minimum.y;
            stuOrigin.z = minimum.z;
            %fprintf('STU origin: %f, %f, %f \n', stuOrigin.x, stuOrigin.y, stuOrigin.z)
            
            % magnitude of STU is difference between max and min selected vertices
            stuAxes.x = maximum.x - minimum.x;
            stuAxes.y = maximum.y - minimum.y;
            stuAxes.z = maximum.z - minimum.z;
            %fprintf('STU axes: %f, %f, %f \n', stuAxes.x, stuAxes.y, stuAxes.z)
            
            % set the s,t,u axis
            axisS.x = stuAxes.x;
            axisS.y = 0;
            axisS.z = 0;
            axisT.y = stuAxes.y;
            axisT.x = 0;
            axisT.z = 0;
            axisU.z = stuAxes.z;
            axisU.x = 0;
            axisU.y = 0;
            
            % get struct
            ffdCoord.stuOrigin = stuOrigin;
            ffdCoord.stuAxes = stuAxes; 
            ffdCoord.axisS = axisS;
            ffdCoord.axisT = axisT;
            ffdCoord.axisU = axisU;
        end
        
        %% create the FFD lattice - grid of control points
        % l+1 planes in the S direction
        % m+1 planes in the T direction
        % n+1 planes in the U direction
        function [lattice, P] = initControlLattice(ffdCoord, l, m, n)
            stuOrigin = ffdCoord.stuOrigin;
            stuAxes = ffdCoord.stuAxes;
            
            Px = [];
            Py = [];
            Pz = [];
            
            for i = 1:l+1
                for j = 1:m+1
                    for k = 1:n+1
                        lattice(i,j,k).x = stuOrigin.x + ((i-1)/l)*stuAxes.x;
                        lattice(i,j,k).y = stuOrigin.y + ((j-1)/m)*stuAxes.y;
                        lattice(i,j,k).z = stuOrigin.z + ((k-1)/n)*stuAxes.z;
                        %fprintf('Lattice[%d][%d][%d]: %f, %f, %f \n', i, j, k, lattice(i,j,k).x, lattice(i,j,k).y, lattice(i,j,k).z)
                        
                        % get control points as e.g. 64x3 matrix
                        Px = [Px; lattice(i,j,k).x];
                        Py = [Py; lattice(i,j,k).y];
                        Pz = [Pz; lattice(i,j,k).z];       
                    end
                end
            end
            P = [Px, Py, Pz];            
        end        
    end
end
