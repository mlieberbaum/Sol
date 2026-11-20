function comparisonPlot(scnB, scnC)

    ephNames = fieldnames(scnB);
    ephNames = ephNames(~ismember(ephNames, {'t', 'TT', 'utc', 'JDTT', 'spacecraft'}));
    
    figure
    set(gcf, 'Color', 'w')
    set(gcf, 'Position', [580 280 1250 980]);
    tiledlayout(2, 2);

    nexttile;
    hold on
    grid on
    legStr = 'legend(';
    for idx = 1 : numel(ephNames)
        plot(scnB.t ./ 3600, vecnorm(scnB.(ephNames{idx}).posSSB - scnC.(ephNames{idx}).posSSB));
        legStr = [legStr, '''', ephNames{idx}, ''', '];
    end
    legStr = [legStr, '''Location'', ''Best'');'];
    eval(legStr);
    xlabel('Time (hr)')
    ylabel('m')
    title('Planet Position Delta, N-Body vs. DE440');

    nexttile;
    hold on
    grid on
    legStr = 'legend(';
    for idx = 1 : numel(ephNames)
        plot(scnB.t ./ 3600, vecnorm(scnB.(ephNames{idx}).velSSB - scnC.(ephNames{idx}).velSSB));
        legStr = [legStr, '''', ephNames{idx}, ''', '];
    end
    legStr = [legStr, '''Location'', ''Best'');'];
    eval(legStr);
    xlabel('Time (hr)')
    ylabel('m/s')
    title('Planet Velocity Delta, N-Body vs. DE440');

    nexttile;
    hold on
    grid on
    plot(scnB.t ./ 3600, vecnorm(scnB.spacecraft.posSSB - scnC.spacecraft.posSSB));
    plot(scnB.t ./ 3600, vecnorm(scnB.spacecraft.posECI - scnC.spacecraft.posECI));
    xlabel('Time (hr)')
    ylabel('m')
    title('Spacecraft Position Delta, N-Body vs. DE440')
    legend('SSB', 'ECI', 'Location', 'Best');

    nexttile;
    hold on
    grid on
    plot(scnB.t ./ 3600, vecnorm(scnB.spacecraft.velSSB - scnC.spacecraft.velSSB));
    plot(scnB.t ./ 3600, vecnorm(scnB.spacecraft.velECI - scnC.spacecraft.velECI));
    xlabel('Time (hr)')
    ylabel('m/s')
    title('Spacecraft Velocity Delta, N-Body vs. DE440')
    legend('SSB', 'ECI', 'Location', 'Best');

end