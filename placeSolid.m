function [geo, particleInds, particleList, area, minFeret] = placeSolid(domainSize, ...
    psdInput, particleInput, aimPor)

    tStart = tic;
    
    % domain size
    n = domainSize;
    geo = zeros(n);
    geo = reshape(geo, [n*n 1]); 
    particleInds = geo;
   
    numCells = n*n;

    % data for particle size distribution (psd)
    intData = readmatrix(psdInput);
    intLowBound = intData(:,1);
    intUpBound = intData(:,2);   
    intSize = intData(:,3);
    numIntervals = length(intSize);

    % load particle shapes
    load(particleInput, 'fullParticleAreas', 'fullParticleList', 'fullParticleMinFeretDiameters');
    particleAreas = fullParticleAreas;
    particleList = fullParticleList;
    minFeretDiam = fullParticleMinFeretDiameters;

    % undershoot intervals in psd at most by maxUndershoot
    maxUndershoot = 0.005;
    porAfterInt = zeros(1,numIntervals);

    % save indices of added particles
    addedParticles = [];
    numAddedParticle = 1;

    % indicates if particles could ce placed
    newPositionFound = 0;

    % start with largest particles
    int = numIntervals;

    % particleCandidatesInt gives candidates of current interval of psd
    particleCandidatesInt = find(minFeretDiam >= intLowBound(int) & minFeretDiam < intUpBound(int));

    % calculate porosity
    currPor =  size(find(geo==0),1) / numCells;

    Tloop = 0;
    Tstencil = 0;
    countPlacingLoop = 0;
    % while not enough solid is placed
    
    fprintf('Start placing particles of size >= %5.2f and < %5.2f .\n',intLowBound(int), intUpBound(int));

    while currPor > aimPor

           % find max. particle Size s.t. interval is only undershot by maxUndershoot
           maxParticleSize = (sum(intSize(int:numIntervals)) + maxUndershoot) * (1-aimPor) * numCells - ...
               (1-currPor) * numCells;

           % helper to find candidates that don't undershoot too much
           particleCandidatesHelper = find(particleAreas  <= maxParticleSize);
           particleCandidatesInds = particleCandidatesInt(ismember(particleCandidatesInt, particleCandidatesHelper));
           numCandidates = length(particleCandidatesInds);
           % continue if no candidate found
           if numCandidates == 0 || ( sum(intSize(int:numIntervals)) * (1-aimPor) < (1-currPor) )
              int = int - 1;
                fprintf('Start placing particles of size >= %5.2f and < %5.2f .\n',intLowBound(int), intUpBound(int));
              particleCandidatesInt = find(minFeretDiam >= intLowBound(int) & minFeretDiam <= intUpBound(int));
              geoPlot = reshape(geo,[n n]);
              geoPlot = rot90(geoPlot,3);
%               writePng(geoPlot, strcat('geoInt', num2str(int, '%.2i'), '.png'));

           else
               % choose candidate
               randInd = randi(numCandidates);
               candInd = particleCandidatesInds(randInd);

               % place candidate
               [row, col] = ind2sub([n n], particleList{candInd});
               particleExtension = max(max(row),max(col));
               stencilLayers = min(max(2*(particleExtension-1),1),n);
               stencilParticle = stencil(n, n, particleList{candInd}(1),stencilLayers);
               indHelper= ismember(stencilParticle, particleList{candInd});
               
               
               freeFluidSpots = find(geo == 0);
               freeFluidSpots = freeFluidSpots(freeFluidSpots~=1);%nicht an 1 platzieren 
              
               while ~newPositionFound
                   countPlacingLoop = countPlacingLoop + 1;
                   TloopStart = tic;
                   randSpot = freeFluidSpots(randi(length(freeFluidSpots)));
                   tStencil = tic;
                   stencilNewPosition = stencil(n, n, randSpot, stencilLayers);
                   Tstencil = Tstencil + toc(tStencil);
                   globalIndNewParticle = stencilNewPosition(indHelper);
                   if sum(geo(globalIndNewParticle))   == 0 && ~(sum(ismember(globalIndNewParticle,1)==1)) % 
                       newPositionFound = 1;
                   end
                   Tloop = Tloop + toc(TloopStart);
               end
               geo(globalIndNewParticle) = 1;
               addedParticles = [addedParticles candInd];
               particleInds(globalIndNewParticle) = numAddedParticle;
               numAddedParticle = numAddedParticle + 1;
               newPositionFound = 0;
           end

     currPor =  size(find(geo==0),1) / numCells;
    end
    if(geo(1) == 1)
               fprintf("ahhh")
    end
    geo=reshape(geo,[n n]);
    particleInds=reshape(particleInds,[n n]);

    minFeret = minFeretDiam(addedParticles);
    area = particleAreas(addedParticles);
    particleList = fullParticleList(addedParticles);

    tEnd = toc(tStart);

end