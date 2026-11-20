function scn = loadScenario(scnId)

    % Initial sim time
    scn.utc0 = [2025 3 16 12 0 0];
    
    % Spacecraft initial state (ECI frame)
    if scnId == 1

        % Spacecraft initial state
        scn.r0ECI = [ 6958.375530
                      4083.806800
                      2257.587178 ] * 1e3;
        scn.v0ECI = [ -5.05758990
                       6.05637810
                       4.63305774] * 1e3;

        % Simulation time parameters
        scn.dt = 1.0;
        scn.tf = 172800;

    elseif scnId == 2

        % TO DO

    else

        error('scnId must be 1 or 2');

    end

end