function [geo] = createInitialState(domainSize, aimPor, psdInput, particleShapesInput, POMshapesInput,...
    amountPOM, POMsizeDistr, outputFileCAM)
   
    fprintf('Placing solid particles in domain of size %3ix%3i with porosity %3.2f.\n',domainSize,domainSize,aimPor);
    fprintf('Start...\n');
    T_solid = tic;
    % distribute solid
    [geo, particleInds, ~, ~, minFeret] = placeSolid(domainSize, ...
        psdInput, particleShapesInput, aimPor);
    fprintf('Finish... after %d seconds.\n', toc(T_solid));
    
    fprintf('Placing POM particles.\n');
    T_POM = tic;
    load(POMshapesInput, 'POMparticleShapesList', 'POMparticleAreas', 'POMminFeret');

    % distribute POM
    [geo, ~, POMParticleList] = placePOMparticles(geo, POMparticleShapesList,...
        POMparticleAreas, amountPOM, POMsizeDistr);
    fprintf('Finish... after %d seconds.\n', toc(T_POM));
    
    fprintf('Creating strutures for initial state.\n');
    T_init = tic;
    % create structures needed as input in Code for CAM
    % reshape everything in Vectors
    geo = rot90(geo,3);
    particleInds = rot90(particleInds,3);

    for i = 1 : length(POMParticleList)
       geoHelp = zeros(domainSize);
       geoHelp(POMParticleList{i}) = 1;
       geoHelp = rot90(geoHelp,3);
       POMParticleList{i} = find(geoHelp == 1)';
    end

    particleTypeVector = reshape(particleInds, [domainSize*domainSize,1]);

    bulkVector = reshape(geo, [domainSize*domainSize,1]);
    bulkVector(bulkVector>0)=1;

    bulkTypeVector = -1 * bulkVector;

    POMVector = reshape(geo, [domainSize*domainSize,1]);
    POMVector(POMVector ~= 2) = 0;
    POMVector(POMVector > 0) = 1;
    POMconcVector = POMVector;

    % create domain
    intBound    = domainSize * ones(domainSize+1,1);
    upBound     = intBound;

    g = createDomainFolded(domainSize, domainSize, domainSize, 0, intBound, upBound);

    edgeChargeVector = 0*ones( g.numCE , 1); 
    reactiveSurfaceVector = 0*ones( g.numCE , 1);
    particleList = createSolidParticleList(particleTypeVector);

    % Distribute reactive edges randomly, with share of reactive surface
    % depending on particle size
    [particleSurfaceEdgeList] = getSolidSurfaceEdges(g, particleList, particleTypeVector);

    for i = 1 : length(particleList)
        if (minFeret(i) < 6.3)
            reactiveSurfaceVector(particleSurfaceEdgeList{i}) = 1;
        elseif (minFeret(i) < 20)
            numEdges = length(particleSurfaceEdgeList{i});
            edgeInds = randperm(numEdges, round(0.5 * numEdges));
            reactiveSurfaceVector(particleSurfaceEdgeList{i}(edgeInds)) = 1;
        elseif (minFeret(i) < 63)
            numEdges = length(particleSurfaceEdgeList{i});
            edgeInds = randperm(numEdges, round(0.25 * numEdges));
            reactiveSurfaceVector(particleSurfaceEdgeList{i}(edgeInds)) = 1;
        else
            numEdges = length(particleSurfaceEdgeList{i});
            edgeInds = randperm(numEdges, round(0.1 * numEdges));
            reactiveSurfaceVector(particleSurfaceEdgeList{i}(edgeInds)) = 1;    
        end
    end

%     numSurfaceEdges = 0;
%     for i = 1 : length(particleList)
%         numSurfaceEdges = numSurfaceEdges + length(particleSurfaceEdgeList{i});
%     end

%     visualizeDataSub(g, bulkVector, 'bulk', 'test', 0);
%     visualizeDataEdges(g, reactiveSurfaceVector, 'conc', 'test2', 0, 2);
%     visualizeDataSub(g, POMVector, 'POM', 'test3', 0);

    % Save created geometry for input to full CAM code
    save(outputFileCAM,'g','bulkVector','bulkTypeVector','edgeChargeVector',...
        'reactiveSurfaceVector','particleList','particleTypeVector','POMconcVector',...
        'POMParticleList','POMVector');
    geo( POMVector == 1 ) = 2;
    geo = rot90(geo, 1); 
    fprintf('Finish... after %d seconds.\n', toc(T_init));
end