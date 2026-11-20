function xdot = calcDerivCentralBody(eph, jdTT, x, ephNames, tSec, centralBody)
    
    % Compute the velocity and acceleration of a spacecraft relative to a
    % central body with third-body perturbing gravity sources.  Reference
    % frame is the ICRF-aligned frame with its center at the central body.

    % State: x = [posSC ; velSC];

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

    % Index of the central body in ephNames
    iCB = find(ismember(ephNames, centralBody));

    % Compute acceleration of the spacecraft from each body.
    for idx = 1 : numel(ephNames)

        % Position of spacecraft relative to the body
        drCB = (sol.(ephNames{idx}).pos - sol.(centralBody).pos).' * 1e3;
        drSC = x(1:3) - drCB;

        % Gravitational parameter for this body [m^3/s^2]
        mu = 1e9 * eph.mu.(ephNames{idx});

        % Gravitational acceleration
        if idx == iCB
            xdot(4:6) = xdot(4:6) - mu * drSC / (norm(drSC)^3);
        else
            xdot(4:6) = xdot(4:6) - mu * ...
                (drSC / (norm(drSC)^3) + drCB / (norm(drCB)^3));
        end
    end

end