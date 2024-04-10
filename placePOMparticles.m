function [geo, POMparticleInds, particleList] = placePOMparticles(geo, POMparticleShapesList, POMparticleAreas, amount, POMsizeDistr)

%     tStart = tic;
    % domain size
    
    [n, m] = size(geo);
    geo = reshape(geo, [n*n 1]);
    POMparticleInds = zeros(n,m);
    
    % calculate number of POM cells that should be placed
    numSolidCells = size(find(geo==1),1);
    numPOMCells = round(amount*numSolidCells);
    numPOMparticles = zeros(size(POMsizeDistr,1),1);
    for i = 1 : length(numPOMparticles)
        numPOMparticles(i) = round(numPOMCells * POMsizeDistr(i,2) / POMsizeDistr(i,1));
    end
    
    % save indices of added particles
    addedParticles = [];
    numAddedParticle = 1;
    
    particleList = {};

    % indicates if particles could ce placed
    newPositionFound = 0;
    
    % loop over all POM particle sizes, from large to small
    for int = length(numPOMparticles) : -1 : 1
        particleCandidatesInds = find(POMparticleAreas == POMsizeDistr(int,1));
        for j = 1 :  numPOMparticles(int)
            
           numCandidates = length(particleCandidatesInds);
           % choose candidate
           randInd = randi(numCandidates);
           candInd = particleCandidatesInds(randInd);
           
           % place candidate
           [row, col] = ind2sub([n n], POMparticleShapesList{candInd});
           particleExtension = max(max(row),max(col));
           stencilLayers = min(max(2*(particleExtension-1),1),n);
           stencilParticle = stencil(n, n, POMparticleShapesList{candInd}(1),stencilLayers);
           indHelper= ismember(stencilParticle, POMparticleShapesList{candInd});

           freeFluidSpots = find(geo == 0);
           freeFluidSpots = freeFluidSpots(freeFluidSpots~=1);%nicht an 1 platzieren 

           while ~newPositionFound
%                TloopStart = tic;
               randSpot = freeFluidSpots(randi(length(freeFluidSpots)));
               tStencil = tic;
               stencilNewPosition = stencil(n, n, randSpot, stencilLayers);
%                Tstencil = Tstencil + toc(tStencil);
               globalIndNewParticle = stencilNewPosition(indHelper);
               if sum(geo(globalIndNewParticle)) == 0 && ~(sum(ismember(globalIndNewParticle,1)==1))
                   newPositionFound = 1;
               end
%                Tloop = Tloop + toc(TloopStart);
           end
           if(geo(1) == 1)
               fprintf("ahhh")
           end
           geo(globalIndNewParticle) = 2;
           addedParticles = [addedParticles candInd];
           POMparticleInds(globalIndNewParticle) = numAddedParticle;
           numAddedParticle = numAddedParticle + 1;
           newPositionFound = 0;
           particleList = [particleList globalIndNewParticle];

            
        end
    end


    geo=reshape(geo,[n n]);
    POMparticleInds=reshape(POMparticleInds,[n n]);
%     geo = rot90(geo,3);
%     POMparticleInds = rot90(POMparticleInds,3);
    
%     particleList = POMparticleShapesList(addedParticles);

%     minFeret = minFeretDiam(addedParticles);
%     area = particleAreas(addedParticles);

%     save('domain100/data.mat','geo','particleInds','addedParticles','porAfterInt','area','minFeret');

%     tEnd = toc(tStart);

end