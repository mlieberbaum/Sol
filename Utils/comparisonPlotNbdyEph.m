function comparisonPlotNbdyEph(scnA, scnC, frame)

    % Compares simulation results using the N-body formulation (scnA) and
    % DE 440 ephemeris (scnC) sharing a common propagation frame.  Input
    % argument 'frame' can be SSB, ECI, or MCI.

    % Get all celestial body names
    ephNames = fieldnames(scnA);
    ephNames = ephNames(~ismember(ephNames, {'t', 'TT', 'utc', 'JDTT', 'spacecraft'}));


    % Check time alignment
    assert(isequal(scnA.t, scnC.t), 'Simulation time vectors must match');
    

    % Initialize the figure and tiled layout
    figure
    set(gcf, 'Color', 'w')
    set(gcf, 'Position', [580 280 1250 980]);
    tl = tiledlayout(2, 2);
    title(tl, ['N-Body vs. DE440 Simulation Comparison: ', frame, ' Frame'], ...
        'FontWeight', 'Bold', 'FontSize', 16);
    subtitle(tl, ['Newtonian point-mass propagation versus DE440-driven propagation;', ...
        'force-model and numerical differences are expected.'])


    % Planet position delta plot: plotted variables depend on the input
    % argument 'frame'
    nexttile;
    hold on
    grid on
    for idx = 1 : numel(ephNames)
        if strcmp(frame, 'SSB')
            plot(scnA.t ./ 3600, vecnorm(scnA.(ephNames{idx}).posSSB - scnC.(ephNames{idx}).posSSB));
        elseif strcmp(frame, 'ECI')
            plot(scnA.t ./ 3600, vecnorm(scnA.(ephNames{idx}).posECI - scnC.(ephNames{idx}).posECI));
        end
    end
    legend(frame, 'Location', 'Best');
    xlabel('Time (hr)')
    ylabel('m')
    title(['Planet Position Delta, ', frame, ', N-Body vs. DE440']);


    % Planet velocity delta plot: plotted variables depend on the input
    % argument 'frame'
    nexttile;
    hold on
    grid on
    for idx = 1 : numel(ephNames)
        if strcmp(frame, 'SSB')
            plot(scnA.t ./ 3600, vecnorm(scnA.(ephNames{idx}).velSSB - scnC.(ephNames{idx}).velSSB));
        elseif strcmp(frame, 'ECI')
            plot(scnA.t ./ 3600, vecnorm(scnA.(ephNames{idx}).velECI - scnC.(ephNames{idx}).velECI));
        end
    end
    legend(frame, 'Location', 'Best');
    xlabel('Time (hr)')
    ylabel('m/s')
    title(['Planet Velocity Delta, ', frame, ', N-Body vs. DE440']);


    % Spacecraft position delta.  Plot all frames available.
    nexttile;
    hold on
    grid on
    if strcmp(frame, 'SSB')
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.posSSB - scnC.spacecraft.posSSB));
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.posECI - scnC.spacecraft.posECI));
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.posMCI - scnC.spacecraft.posMCI));
    elseif strcmp(frame, 'ECI')
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.posECI - scnC.spacecraft.posECI));
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.posMCI - scnC.spacecraft.posMCI));
    end
    xlabel('Time (hr)')
    ylabel('m')
    title('Spacecraft Position Delta, N-Body vs. DE440')
    legend(frame, 'Location', 'Best');


    % Spacecraft velocity delta.  Plot all frames available.
    nexttile;
    hold on
    grid on
    if strcmp(frame, 'SSB')
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.velSSB - scnC.spacecraft.velSSB));
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.velECI - scnC.spacecraft.velECI));
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.velMCI - scnC.spacecraft.velMCI));
    elseif strcmp(frame, 'ECI')
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.velECI - scnC.spacecraft.velECI));
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.velMCI - scnC.spacecraft.velMCI));
    end
    xlabel('Time (hr)')
    ylabel('m/s')
    title('Spacecraft Velocity Delta, N-Body vs. DE440')
    legend(frame, 'Location', 'Best');

end