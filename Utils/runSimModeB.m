function simOut = runSimModeB(scn, eph, ephNames, centralBody)

    % Runs the n-body problem in the ECI frame.  First, ensure Earth is
    % included.
    if ~any(ismember(ephNames, centralBody))
        error([centralBody, ' is required to perform computations in the ECI frame']);
    end

    
    %% SIM TIME PARAMETERS

    % Sim time vector
    simOut.t = 0 : scn.dt : scn.tf;
    npts = numel(simOut.t);

    % Epoch data
    simOut.utc = datevec(datetime(scn.utc0) + seconds(simOut.t)).';
    simOut.TT = datevec(datetime(simOut.utc.') + seconds(69.184)).';
    simOut.JDTT = juliandate(datetime(simOut.TT.')).';

    % Initial Julian date (used later)
    jd0 = simOut.JDTT(1);

    
    %% PREALLOCATE OUTPUT ARRAYS

    % Spacecraft
    simOut.spacecraft.posCBI = zeros(3, npts);
    simOut.spacecraft.velCBI = zeros(3, npts);
    


    %% INITIAL CONDITIONS
    
    % Spacecraft initial conditions are given in central body inertial
    % coordinates.
    simOut.spacecraft.posCBI(:,1) = scn.r0ECI;
    simOut.spacecraft.velCBI(:,1) = scn.v0ECI;
    


    %% RUN SIMULATION

    for idx = 1 : npts-1

        % Propagate state
        tk = simOut.t(idx);
        h = scn.dt;

        % State vector (m, m/s in ECI)
        xk = [simOut.spacecraft.posCBI(:,idx)
              simOut.spacecraft.velCBI(:,idx)];

        k1 = calcDerivCentralBody(eph, jd0, xk,            ephNames, tk,       centralBody);
        k2 = calcDerivCentralBody(eph, jd0, xk + (h/2)*k1, ephNames, tk + h/2, centralBody);
        k3 = calcDerivCentralBody(eph, jd0, xk + (h/2)*k2, ephNames, tk + h/2, centralBody);
        k4 = calcDerivCentralBody(eph, jd0, xk + h*k3,     ephNames, tk + h,   centralBody);

        xkp1 = xk + (h/6)*(k1 + 2*k2 + 2*k3 + k4);

        
        % Log spacecraft position (in ECI)
        simOut.spacecraft.posCBI(:,idx+1) = xkp1(1:3);
        simOut.spacecraft.velCBI(:,idx+1) = xkp1(4:6);

    end



    %% DOWNSAMPLE OUTPUT

    simOut = downsampleData(simOut, 10);

    
end