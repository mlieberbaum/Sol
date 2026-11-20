function comparisonPlotRefFrame(scn1, scn2, frame1, frame2, frameComp, mode)

    % Compares simulation results using any of the physics models (pure
    % N-Body, central body w/ perturbing elements, and full solar system),
    % where the two simulations are run in different reference frames.
    % Input argument 'frame' can be SSB, ECI, or MCI.
    % 
    %      scn1: Output for simulation 1
    %      scn2: Output for simulation 2
    %    frame1: Reference frame for simulation 1
    %    frame2: Reference frame for simulation 2
    % frameComp: Reference frame to use for plot comparison (must exist in
    %            scn1 and scn2)
    %      mode: 'A', 'B', or 'C'

    % Get all celestial body names
    ephNames = fieldnames(scn1);
    ephNames = ephNames(~ismember(ephNames, {'t', 'TT', 'utc', 'JDTT', 'spacecraft'}));


    % Check time alignment
    assert(isequal(scn1.t, scn2.t), 'Simulation time vectors must match');
    

    % Initialize the figure and tiled layout
    figure
    set(gcf, 'Color', 'w')
    set(gcf, 'Position', [580 280 1250 980]);
    tl = tiledlayout(2, 2);

    if strcmp(mode, 'A')
        physMdl = 'N-Body Newtonian Mechanics';
    elseif strcmp(mode, 'B')
        physMdl = 'Central Body w/ 3rd Body Gravity Sources';
    elseif strcmp(mode, 'C')
        physMdl = 'Full Solar System Model';
    else
        error('mode must be ''A'', ''B'', or ''C''');
    end

    title(tl, [physMdl, ', ', frame1, ' vs. ', frame2, ' Frames'], ...
        'FontWeight', 'Bold', 'FontSize', 16);
    subtitle(tl, ['Plots show deltas expressed in the ', frameComp, ' Frame', 10, ...
        'Due to large numeric values of the SSB frame, slight', ...
        'differences might exist'])


    % Planet position delta plot: plotted variables depend on the input
    % argument 'frame'
    nexttile;
    hold on
    grid on
    for idx = 1 : numel(ephNames)
        if strcmp(frameComp, 'SSB')
            plot(scn1.t ./ 3600, vecnorm(scn1.(ephNames{idx}).posSSB - scn2.(ephNames{idx}).posSSB));
        elseif strcmp(frameComp, 'ECI')
            plot(scn1.t ./ 3600, vecnorm(scn1.(ephNames{idx}).posECI - scn2.(ephNames{idx}).posECI));
        end
    end
    legend(frameComp, 'Location', 'Best');
    xlabel('Time (hr)')
    ylabel('m')
    title(['Planet Position Delta, ', frame1, ' vs. ', frame2, ' Frame Sims']);


    % Planet velocity delta plot: plotted variables depend on the input
    % argument 'frame'
    nexttile;
    hold on
    grid on
    for idx = 1 : numel(ephNames)
        if strcmp(frameComp, 'SSB')
            plot(scn1.t ./ 3600, vecnorm(scn1.(ephNames{idx}).velSSB - scn2.(ephNames{idx}).velSSB));
        elseif strcmp(frameComp, 'ECI')
            plot(scn1.t ./ 3600, vecnorm(scn1.(ephNames{idx}).velECI - scn2.(ephNames{idx}).velECI));
        end
    end
    legend(frameComp, 'Location', 'Best');
    xlabel('Time (hr)')
    ylabel('m/s')
    title(['Planet Velocity Delta, ', frame1, ' vs. ', frame2, ' Frame Sims']);


    % Spacecraft position delta.  Plot all frames available.
    nexttile;
    hold on
    grid on
    if strcmp(frameComp, 'SSB')
        plot(scn1.t ./ 3600, vecnorm(scn1.spacecraft.posSSB - scn2.spacecraft.posSSB));
    elseif strcmp(frameComp, 'ECI')
        plot(scn1.t ./ 3600, vecnorm(scn1.spacecraft.posECI - scn2.spacecraft.posECI));
    end
    xlabel('Time (hr)')
    ylabel('m')
    title(['Spacecraft Position Delta, ', frame1, ' vs. ', frame2, ' Frame Sims']);
    legend(frameComp, 'Location', 'Best');


    % Spacecraft velocity delta.  Plot all frames available.
    nexttile;
    hold on
    grid on
    if strcmp(frameComp, 'SSB')
        plot(scn1.t ./ 3600, vecnorm(scn1.spacecraft.velSSB - scn2.spacecraft.velSSB));
    elseif strcmp(frameComp, 'ECI')
        plot(scn1.t ./ 3600, vecnorm(scn1.spacecraft.velECI - scn2.spacecraft.velECI));
    end
    xlabel('Time (hr)')
    ylabel('m/s')
    title(['Spacecraft Velocity Delta, ', frame1, ' vs. ', frame2, ' Frame Sims']);
    legend(frameComp, 'Location', 'Best');

end