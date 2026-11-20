function xdot = calcDerivNbodyECI(x, ephMu, ephNames)
    
    % Compute the velocity and acceleration of the Sun, Earth, Moon, and
    % spacecraft via the N-body problem.  The spacecraft is assumed
    % massless because its mass is so much smaller than the planets'
    % masses.  The reference frame is ECI.  So, one of the bodies must be
    % Earth.

    % State: x = [posSC       3x1
    %             posBody1    3x1
    %               ...       3x1
    %             posBodyN    3x1
    %             velSC       3x1
    %             velBody1    3x1
    %               ...       3x1
    %             velBodyN    3x1]
    %             
    %
    %     xdot = [velSC       3x1
    %             velBody1    3x1
    %               ...       3x1
    %             velBodyN    3x1
    %             accSC       3x1
    %             accBody1    3x1
    %               ...       3x1
    %             velBodyN    3x1]

    % Preliminary variables (number of bodies, etc.).  Note the spacecraft
    % is always the first "body".
    nBodies = numel(ephNames) + 1;
    iVel = 3*nBodies + 1;
    iEarth = find(ismember(ephNames, 'Earth')) + 1;

    pos = reshape(x(1:iVel-1), 3, nBodies);
    mu = zeros(nBodies, 1);

    for idx = 1 : nBodies
        if idx == 1
            mu(idx) = 0;
        else
            mu(idx) = 1e9 * ephMu.(ephNames{idx-1});
        end
    end


    % Compute acceleration of Earth
    accEarth = zeros(3,1);
    
    for idx = 1 : nBodies
        if idx == 1 || idx == iEarth
            continue;
        end
        dr = -pos(:,idx);
        accEarth = accEarth - mu(idx) * dr / (norm(dr)^3);
    end


    % N-Body Acceleration.  Compute the acceleration of body i towards
    % body j.  dr is therefore formed as the relative position vector from
    % the center of body j to the center of body i.  The j loop index 
    % begins at 2, because the spacecraft's mass is assumed to be so small 
    % that it does not affect the planets.
    acc = zeros(3, nBodies);

    for i = 1 : nBodies
        for j = 2 : nBodies
            if i == j || i == iEarth
                continue;
            end
            dr = pos(:,i) - pos(:,j);
            acc(:,i) = acc(:,i) - mu(j) * dr / (norm(dr)^3);
        end
    end

    
    % Form state derivative vector
    acc = acc - accEarth;
    acc(:,iEarth) = 0;
    xdot = [x(iVel : end) ; acc(:)];

end