function simOut = runSimModeC_SSB(scn, eph, ephNames)

    
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
    simOut.spacecraft.posSSB = zeros(3, npts);
    simOut.spacecraft.velSSB = zeros(3, npts);
    simOut.spacecraft.posECI = zeros(3, npts);
    simOut.spacecraft.velECI = zeros(3, npts);
    simOut.spacecraft.posMCI = zeros(3, npts);
    simOut.spacecraft.velMCI = zeros(3, npts);
    

    for idx = 1 : numel(ephNames)
        simOut.(ephNames{idx}).posSSB = zeros(3, npts);
        simOut.(ephNames{idx}).velSSB = zeros(3, npts);
    end
    


    %% INITIAL CONDITIONS

    % Planets
    jd0 = simOut.JDTT(1);
    sol = calcEphem(eph, jd0);

    for idx = 1 : numel(ephNames)
        simOut.(ephNames{idx}).posSSB(:,1) = sol.(ephNames{idx}).pos.' * 1e3;
        simOut.(ephNames{idx}).velSSB(:,1) = sol.(ephNames{idx}).vel.' * 1e3;
    end

    % calcEphem returns the moon relative to the Earth
    simOut.Moon.posSSB(:,1) = simOut.Moon.posSSB(:,1) + simOut.Earth.posSSB(:,1);
    simOut.Moon.velSSB(:,1) = simOut.Moon.velSSB(:,1) + simOut.Earth.velSSB(:,1);
    
    % Spacecraft initial conditions are given in ECI, so we must compute
    % the origin of the ECI frame in SSB.
    simOut.spacecraft.posSSB(:,1) = sol.Earth.pos.' * 1e3 + scn.r0ECI;
    simOut.spacecraft.velSSB(:,1) = sol.Earth.vel.' * 1e3 + scn.v0ECI;
    simOut.spacecraft.posECI(:,1) = scn.r0ECI;
    simOut.spacecraft.velECI(:,1) = scn.v0ECI;
    simOut.spacecraft.posMCI(:,1) = scn.r0ECI - sol.Moon.pos.' * 1e3;
    simOut.spacecraft.velMCI(:,1) = scn.v0ECI - sol.Moon.vel.' * 1e3;

    


    %% RUN SIMULATION

    for idx = 1 : npts-1

        % Propagate state
        tk = simOut.t(idx);
        h = scn.dt;

        xk = [simOut.spacecraft.posSSB(:,idx)
              simOut.spacecraft.velSSB(:,idx)];

        k1 = calcDerivEphSSB(eph, jd0, xk,            ephNames, tk);
        k2 = calcDerivEphSSB(eph, jd0, xk + (h/2)*k1, ephNames, tk + h/2);
        k3 = calcDerivEphSSB(eph, jd0, xk + (h/2)*k2, ephNames, tk + h/2);
        k4 = calcDerivEphSSB(eph, jd0, xk + h*k3,     ephNames, tk + h);

        xkp1 = xk + (h/6)*(k1 + 2*k2 + 2*k3 + k4);

        
        % Solar system state at step k+1
        solkp1 = calcEphem(eph, jd0, simOut.t(idx+1));


        % Log spacecraft position in SSB
        simOut.spacecraft.posSSB(:,idx+1) = xkp1(1:3);
        simOut.spacecraft.velSSB(:,idx+1) = xkp1(4:6);

        % Log solar system body position in SSB
        for idxEph = 1 : numel(ephNames)
            simOut.(ephNames{idxEph}).posSSB(:,idx+1) = 1e3 * solkp1.(ephNames{idxEph}).pos.';
            simOut.(ephNames{idxEph}).velSSB(:,idx+1) = 1e3 * solkp1.(ephNames{idxEph}).vel.';
        end

        % Moon's position is returned relative to Earth, so must add
        % Earth's position to get moon in SSB.
        simOut.Moon.posSSB(:,idx+1) = simOut.Moon.posSSB(:,idx+1) + simOut.Earth.posSSB(:,idx+1);
        simOut.Moon.velSSB(:,idx+1) = simOut.Moon.velSSB(:,idx+1) + simOut.Earth.velSSB(:,idx+1);

    end



    %% LOG ECI AND MCI FRAME DATA

    simOut.spacecraft.posECI(:,2:end) = simOut.spacecraft.posSSB(:,2:end) - simOut.Earth.posSSB(:,2:end);
    simOut.spacecraft.velECI(:,2:end) = simOut.spacecraft.velSSB(:,2:end) - simOut.Earth.velSSB(:,2:end);
    simOut.spacecraft.posMCI(:,2:end) = simOut.spacecraft.posSSB(:,2:end) - simOut.Moon.posSSB(:,2:end);
    simOut.spacecraft.velMCI(:,2:end) = simOut.spacecraft.velSSB(:,2:end) - simOut.Moon.velSSB(:,2:end);

    for idx = 1 : numel(ephNames)
        simOut.(ephNames{idx}).posECI = simOut.(ephNames{idx}).posSSB - simOut.Earth.posSSB;
        simOut.(ephNames{idx}).velECI = simOut.(ephNames{idx}).velSSB - simOut.Earth.velSSB;
        simOut.(ephNames{idx}).posMCI = simOut.(ephNames{idx}).posSSB - simOut.Moon.posSSB;
        simOut.(ephNames{idx}).velMCI = simOut.(ephNames{idx}).velSSB - simOut.Moon.velSSB;
    end



    %% DOWNSAMPLE OUTPUT

    simOut = downsampleData(simOut, 10);


end