% aim size of domain and porosity
domainSize = 250;
aimPor = 0.45;%0.8

% particle size distribution
psdInput = 'particleSizeDistribution/loam_bayreuth.csv';
%psdInput = 'particleSizeDistribution/clay34_geoderma_waterStable_200.csv';
% files with shapes for solid + POM particles
particleShapesInput = 'particleShapeLibrary/particleShapes250rotations.mat';
POMshapesInput = 'particleShapeLibrary/POMshapes250.mat';

% POM input
amountPOM = 0.05;%0.01
POMsizeDistr = [10 0.2; 15 0.3; 20 0.5];

% output file
outputFileCAM = 'output/loam_bayreuth_45_005.mat';

% place solid and POM particles and create output file that serves as an
% input file in the CAM code
geo = createInitialState(domainSize, aimPor, psdInput, particleShapesInput, POMshapesInput,...
    amountPOM, POMsizeDistr, outputFileCAM);

% % visualize initial state
writePng(geo, 'output/loam_bayreuth_45_005.png');
