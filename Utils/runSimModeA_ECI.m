function simOut = runSimModeA_ECI(scn, eph, ephNames)

    % Runs the n-body problem in the ECI frame.  First, ensure Earth and
    % moon are included.
    if ~any(ismember(ephNames, 'Earth')) || ~any(ismember(ephNames, 'Moon'))
        error('Earth is required to perform computations in the ECI frame');
    end

    
    %% SIM TIME PARAMETERS

    % Sim time vector
    simOut.t = 0 : scn.dt : scn.tf;
    npts = numel(simOut.t);

    % Epoch data
    simOut.utc = datevec(datetime(scn.utc0) + seconds(simOut.t)).';
    simOut.TT = datevec(datetime(simOut.utc.') + seconds(69.184)).';
    simOut.JDTT = juliandate(datetime(simOut.TT.')).';

    
    %% PREALLOCATE OUTPUT ARRAYS

    % Spacecraft
    simOut.spacecraft.posECI = zeros(3, npts);
    simOut.spacecraft.velECI = zeros(3, npts);
    simOut.spacecraft.posMCI = zeros(3, npts);
    simOut.spacecraft.velMCI = zeros(3, npts);
    

    for idx = 1 : numel(ephNames)
        simOut.(ephNames{idx}).posECI = zeros(3, npts);
        simOut.(ephNames{idx}).velECI = zeros(3, npts);
    end
    


    %% INITIAL CONDITIONS

    % Planets
    sol = calcEphem(eph, simOut.JDTT(1));

    % calcEphem returns the moon relative to the Earth, so no subtraction
    % is required.
    for idx = 1 : numel(ephNames)
        if strcmp(ephNames{idx}, 'Moon')
            simOut.Moon.posECI(:,1) = sol.Moon.pos.' * 1e3;
            simOut.Moon.velECI(:,1) = sol.Moon.vel.' * 1e3;
        else
            simOut.(ephNames{idx}).posECI(:,1) = (sol.(ephNames{idx}).pos.' - sol.Earth.pos.') * 1e3;
            simOut.(ephNames{idx}).velECI(:,1) = (sol.(ephNames{idx}).vel.' - sol.Earth.vel.') * 1e3;
        end
    end
    
    % Spacecraft initial conditions are given in ECI.
    simOut.spacecraft.posECI(:,1) = scn.r0ECI;
    simOut.spacecraft.velECI(:,1) = scn.v0ECI;
    simOut.spacecraft.posMCI(:,1) = scn.r0ECI - sol.Moon.pos.' * 1e3;
    simOut.spacecraft.velMCI(:,1) = scn.v0ECI - sol.Moon.vel.' * 1e3;
    


    %% RUN SIMULATION

    for idx = 1 : npts-1

        % Propagate state
        h = scn.dt;

        % State vector (m, m/s in ECI)
        xk = zeros(6 + 6*numel(ephNames), 1);
        iVel = numel(xk)/2 + 1;

        xk(1:3) = simOut.spacecraft.posECI(:,idx);
        xk(iVel:iVel+2) = simOut.spacecraft.velECI(:,idx);

        for idxEph = 1 : numel(ephNames)
            xk(3*idxEph + 1 : 3*idxEph + 3) = simOut.(ephNames{idxEph}).posECI(:,idx);
            xk(3*idxEph + iVel : 3*idxEph + iVel + 2  ) = simOut.(ephNames{idxEph}).velECI(:,idx);
        end

        k1 = calcDerivNbodyECI(xk,            eph.mu, ephNames);
        k2 = calcDerivNbodyECI(xk + (h/2)*k1, eph.mu, ephNames);
        k3 = calcDerivNbodyECI(xk + (h/2)*k2, eph.mu, ephNames);
        k4 = calcDerivNbodyECI(xk + h*k3,     eph.mu, ephNames);

        xkp1 = xk + (h/6)*(k1 + 2*k2 + 2*k3 + k4);

        
        % Log spacecraft position (in ECI)
        simOut.spacecraft.posECI(:,idx+1) = xkp1(1:3);
        simOut.spacecraft.velECI(:,idx+1) = xkp1(iVel : iVel+2);

        % Log solar system body position in ECI
        for idxEph = 1 : numel(ephNames)
            simOut.(ephNames{idxEph}).posECI(:,idx+1) = xkp1(3*idxEph + 1    : 3*idxEph + 3        );
            simOut.(ephNames{idxEph}).velECI(:,idx+1) = xkp1(3*idxEph + iVel : 3*idxEph + iVel + 2 );
        end

    end



    %% LOG ECI AND MCI FRAME DATA

    simOut.spacecraft.posMCI(:,2:end) = simOut.spacecraft.posECI(:,2:end) - simOut.Moon.posECI(:,2:end);
    simOut.spacecraft.velMCI(:,2:end) = simOut.spacecraft.velECI(:,2:end) - simOut.Moon.velECI(:,2:end);

    for idx = 1 : numel(ephNames)
        simOut.(ephNames{idx}).posMCI = simOut.(ephNames{idx}).posECI - simOut.Moon.posECI;
        simOut.(ephNames{idx}).velMCI = simOut.(ephNames{idx}).velECI - simOut.Moon.velECI;
    end



    %% DOWNSAMPLE OUTPUT

    simOut = downsampleData(simOut, 10);

    
end