function [pos,vel,acc] = chebyPoly(x, coeff, nSubInt, daysPerBlock)
    
    % Compute the Chebyshev polynomial for Position
    T = nan(numel(coeff), 1);
    T(1) = 1;
    T(2) = x;

    for idx = 2:numel(coeff) - 1
        T(idx+1) = 2*x*T(idx) - T(idx-1);
    end

    % Compute the Chebyshev polynomial for Velocity
    V(1) = 0;
    V(2) = 1;

    for idx = 2:numel(coeff) - 1
        V(idx+1) = 2*x*V(idx) + 2*T(idx) - V(idx-1);
    end

    % Second derivatives with respect to normalized time
    A = zeros(numel(coeff), 1);
    for idx = 2:numel(coeff) - 1
        A(idx+1) = 4*V(idx) + 2*x*A(idx) - A(idx-1);
    end

    pos = 0;
    vel = 0;
    acc = 0;

    for idx = 1:numel(coeff)
        pos = pos + T(idx)*coeff(idx);
        vel = vel + V(idx)*coeff(idx);
        acc = acc + A(idx)*coeff(idx);
    end

    % Scale velocity: vel = vel * SF where
    % SF = 2 * num_sub_int / interval_length * DAY_2_SEC
    vel = vel .* (2 * nSubInt / daysPerBlock) / 86400;

    % Scale acceleration to km/s^2 using the squared time scale
    SF = (2 * nSubInt / daysPerBlock) / 86400;
    acc = acc .* SF^2;

end

