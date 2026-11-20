function xdot = calcDerivEphECI(eph, jdTT, x, ephNames, tSec)
    
    % Compute the velocity and acceleration of the spacecraft using the JPL
    % DE 440 ephemeris solution, using the ECI frame.

    if nargin < 5
        tSec = 0;
    end

    % Derivative of position is velocity
    xdot = [x(4:6) ; zeros(3,1)];

    % Compute position of solar system bodies.  calcEphem returns moon
    % relative to Earth.  All other planets' positions must be computed
    % relative to the Earth.
    sol = calcEphem(eph, jdTT, tSec);
    solEci = struct();
    for idx = 1 : numel(ephNames)
        if strcmp(ephNames{idx}, 'Moon')
            solEci.Moon.pos = sol.Moon.pos;
        else
            solEci.(ephNames{idx}).pos = sol.(ephNames{idx}).pos - sol.Earth.pos;
        end
    end

    % Accumulate spacecraft acceleration
    for idx = 1 : numel(ephNames)
        r = x(1:3) - solEci.(ephNames{idx}).pos.' * 1e3;
        mu = 1e9 * eph.mu.(ephNames{idx});
        xdot(4:6) = xdot(4:6) - mu .* r / (norm(r)^3);
    end
    
    % Subtract Earth acceleration
    xdot(4:6) = xdot(4:6) - sol.Earth.acc' * 1e3;

end