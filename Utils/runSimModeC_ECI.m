function simOut = runSimModeC_ECI(scn, eph, ephNames)

    
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
    jd0 = simOut.JDTT(1);
    sol = calcEphem(eph, jd0);

    for idx = 1 : numel(ephNames)
        if strcmp(ephNames{idx}, 'Moon')
            simOut.Moon.posECI(:,1) = sol.Moon.pos.' * 1e3;
            simOut.Moon.velECI(:,1) = sol.Moon.vel.' * 1e3;
        else
            simOut.(ephNames{idx}).posECI(:,1) = (sol.(ephNames{idx}).pos - sol.Earth.pos).' * 1e3;
            simOut.(ephNames{idx}).velECI(:,1) = (sol.(ephNames{idx}).vel - sol.Earth.vel).' * 1e3;
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
        tk = simOut.t(idx);
        h = scn.dt;

        xk = [simOut.spacecraft.posECI(:,idx)
              simOut.spacecraft.velECI(:,idx)];

        k1 = calcDerivEphECI(eph, jd0, xk,            ephNames, tk);
        k2 = calcDerivEphECI(eph, jd0, xk + (h/2)*k1, ephNames, tk + h/2);
        k3 = calcDerivEphECI(eph, jd0, xk + (h/2)*k2, ephNames, tk + h/2);
        k4 = calcDerivEphECI(eph, jd0, xk + h*k3,     ephNames, tk + h);

        xkp1 = xk + (h/6)*(k1 + 2*k2 + 2*k3 + k4);

        
        % Solar system state at step k+1
        solkp1 = calcEphem(eph, jd0, simOut.t(idx+1));


        % Log spacecraft position in ECI
        simOut.spacecraft.posECI(:,idx+1) = xkp1(1:3);
        simOut.spacecraft.velECI(:,idx+1) = xkp1(4:6);

        % Log solar system body position in ECI
        for idxEph = 1 : numel(ephNames)
            if strcmp(ephNames{idxEph}, 'Moon')
                simOut.Moon.posECI(:,idx+1) = solkp1.Moon.pos.' * 1e3;
                simOut.Moon.velECI(:,idx+1) = solkp1.Moon.vel.' * 1e3;
            else
                simOut.(ephNames{idxEph}).posECI(:,idx+1) = 1e3 * (solkp1.(ephNames{idxEph}).pos - solkp1.Earth.pos).';
                simOut.(ephNames{idxEph}).velECI(:,idx+1) = 1e3 * (solkp1.(ephNames{idxEph}).vel - solkp1.Earth.vel).';
            end
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