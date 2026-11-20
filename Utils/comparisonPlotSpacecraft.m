function comparisonPlotSpacecraft(scnA, scnB, frame)

    % Compares simulation results of spacecraft position and velocity
    % between modes A (pure N-body propagation) and mode B (central body
    % propagation with third body gravity perturbations).

    % Check time alignment
    assert(isequal(scnA.t, scnB.t), 'Simulation time vectors must match');
    

    % Initialize the figure and tiled layout
    figure
    set(gcf, 'Color', 'w')
    set(gcf, 'Position', [580 770 1250 490]);
    tl = tiledlayout(1, 2);
    title(tl, ['Spacecraft Trajectory Simulation Comparison: ', frame, ' Frame'], ...
        'FontWeight', 'Bold', 'FontSize', 16);


    % Spacecraft position delta.  Plot all frames available.
    nexttile;
    hold on
    grid on
    if strcmp(frame, 'ECI')
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.posECI - scnB.spacecraft.posCBI));
    end
    xlabel('Time (hr)')
    ylabel('m')
    title('Spacecraft Position Delta')
    legend(frame, 'Location', 'Best');


    % Spacecraft velocity delta.  Plot all frames available.
    nexttile;
    hold on
    grid on
    if strcmp(frame, 'ECI')
        plot(scnA.t ./ 3600, vecnorm(scnA.spacecraft.velECI - scnB.spacecraft.velCBI));
    end
    xlabel('Time (hr)')
    ylabel('m/s')
    title('Spacecraft Velocity Delta')
    legend(frame, 'Location', 'Best');

end