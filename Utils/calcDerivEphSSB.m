function xdot = calcDerivEphSSB(eph, jdTT, x, ephNames, tSec)
    
    % Compute the velocity and acceleration of the spacecraft using the JPL
    % DE 440 ephemeris solution, using the solar system barycenter as
    % the inertial frame

    if nargin < 5
        tSec = 0;
    end

    % Derivative of position is velocity
    xdot = [x(4:6) ; zeros(3,1)];

    % Compute position of solar system bodies.  calcEphem returns moon
    % relative to Earth, so we must add Earth's position to get the moon's
    % position in SSB.
    sol = calcEphem(eph, jdTT, tSec);
    sol.Moon.pos = sol.Earth.pos + sol.Moon.pos;

    % Accumulate accelerations
    for idx = 1 : numel(ephNames)
        r = x(1:3) - sol.(ephNames{idx}).pos.' * 1e3;
        mu = 1e9 * eph.mu.(ephNames{idx});
        xdot(4:6) = xdot(4:6) - mu .* r / (norm(r)^3);
    end

end