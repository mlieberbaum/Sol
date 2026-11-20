function data = calcEphem(eph, jdTDB, tSec)
    
    % Computes position (km), velocity (km/s), and acceleration (km/s^2)
    % using the ephemeris data and TDB Julian date.
    % jdTDB is the fixed epoch; tSec is optional elapsed time in seconds.
    if nargin < 3
        tSec = 0;
    end
    tDays = tSec / 86400;
    ephHdr = eph.ephHdr;
    ephData = eph.ephData;


    % Data structure strings
    fields = {'Mercury', 'Venus', 'EarthMoonBary', 'Mars', 'Jupiter', ...
        'Saturn', 'Uranus', 'Neptune', 'Pluto', 'Moon', 'Sun', 'Earth'};

    data = struct();

    for idx = 1:numel(fields)
        data.(fields{idx}).pos = nan(1,3);
        data.(fields{idx}).vel = nan(1,3);
        data.(fields{idx}).acc = nan(1,3);
    end
    
    
    %% BLOCK DETERMINATION

    % Determine the file and block for this MJD
    for idxFile = 1:numel(ephData)
        found = false;

        for idxBlk = 1:numel(ephData(idxFile).blocks)
            dates = ephData(idxFile).blocks(idxBlk).blockDates;
            daysIntoBlock = (jdTDB - dates(1)) + tDays;
            if daysIntoBlock >= 0 && daysIntoBlock < dates(2) - dates(1)
                found = true;
                break;
            end
        end

        if found == true
            break;
        end
    end

    % For readability...
    block = ephData(idxFile).blocks(idxBlk);


    %% EPHEMERIS COMPUTATION
    
    % Compute each ephemeris data point
    for idx = 1:11

        % Get number of subintervals
        nSubInt = ephHdr.numSubInt(idx);

        % Determine which subinterval we're on
        subIntLen = ephHdr.daysPerBlock / nSubInt;
        subInt = floor(daysIntoBlock / subIntLen);

        % Pull X, Y, and Z coefficients
        idxStart = subInt * ephHdr.numCoeff(idx) * 3 + ephHdr.startNum(idx);
        coeff = block.blockData(idxStart : idxStart + 3*ephHdr.numCoeff(idx) - 1).';
        coeff = reshape(coeff, ephHdr.numCoeff(idx), 3).';

        % Normalize Time
        subIntTime = daysIntoBlock - subInt * subIntLen;
        tdbNorm = subIntTime / subIntLen * 2.0 - 1.0;

        % Compute position, velocity, and analytical acceleration
        for idx2 = 1:3
            [data.(fields{idx}).pos(idx2), data.(fields{idx}).vel(idx2), ...
             data.(fields{idx}).acc(idx2)] = ...
                chebyPoly(tdbNorm, coeff(idx2,:), nSubInt, ephHdr.daysPerBlock);
        end

    end


    %% EARTH & MOON CALCULATIONS

    % Earth state relative to SSB; Moon remains relative to Earth
    data.Earth.pos = data.EarthMoonBary.pos - data.Moon.pos / (1 + ephHdr.EMRAT);
    data.Earth.vel = data.EarthMoonBary.vel - data.Moon.vel / (1 + ephHdr.EMRAT);
    data.Earth.acc = data.EarthMoonBary.acc - data.Moon.acc / (1 + ephHdr.EMRAT);


end