clear
close all
clc


% Run all regression scenarios


addpath('Ephemeris');
addpath('Scenarios');
addpath('Regression');
addpath('Utils');



%% INPUTS

nCase = 11;

% Scenario to use, 1 or 2.  1 is a closed Earth orbit, and 2 is a
% hyperbolic Earth flyby.
scn = repmat(loadScenario(1), nCase, 1);

% Central body: 'SSB' = Solar System Barycenter, 'Sun', 'Moon', 'Earth', or
% 'Auto'
centralBody = {'SSB', 'SSB', 'SSB', 'ECI', 'ECI', 'ECI', 'ECI', 'ECI', 'ECI', 'SSB', 'ECI'};

% Bodies for the simulation
ephNames = ...
    {...
        {'Sun', 'Earth', 'Moon'}
        {'Sun', 'Venus', 'Earth', 'Moon', 'Jupiter'}
        {'Sun', 'Mercury', 'Venus', 'Earth', 'Moon', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune'}
        {'Sun', 'Earth', 'Moon'}
        {'Sun', 'Venus', 'Earth', 'Moon', 'Jupiter'}
        {'Sun', 'Mercury', 'Venus', 'Earth', 'Moon', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune'}
        {'Sun', 'Earth', 'Moon'}
        {'Sun', 'Venus', 'Earth', 'Moon', 'Jupiter'}
        {'Sun', 'Mercury', 'Venus', 'Earth', 'Moon', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune'}
        {'Sun', 'Mercury', 'Venus', 'Earth', 'Moon', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune'}
        {'Sun', 'Mercury', 'Venus', 'Earth', 'Moon', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune'}
    };

% Mode ('A' = Pure N-Body, 'B' = DE440 Ephemeris, Select 3rd Bodies, 
% 'C' = DE440 Ephemeris Full Solar System Simulation)
modes = {'A', 'A', 'A', 'A', 'A', 'A', 'B', 'B', 'B', 'C', 'C'};

% Regression files
regressionFiles = ...
    {...
        'Scn1A-SSB.mat', 'Scn1A-SSB-VenJup.mat', 'Scn1A-SSB-FullSol.mat', ...
        'Scn1A-ECI.mat', 'Scn1A-ECI-VenJup.mat', 'Scn1A-ECI-FullSol.mat', ...
        'Scn1B-ECI.mat', 'Scn1B-ECI-VenJup.mat', 'Scn1B-ECI-FullSol.mat', ...
        'Scn1C-SSB-FullSol.mat', 'Scn1C-ECI-FullSol.mat'
    };



%% LOAD SOLAR SYSTEM

% Load DE440 solution
load("Ephemeris\DE440.mat", "eph");

% Update Earth and Moon mu parameters using EGM-2008 and GGGRX-1200 gravity
% model values
eph.mu.Earth = 398600.4415;
eph.mu.Moon = 4902.8001224453;



%% RUN SIMULATION

simOut = cell(1, nCase);

tic;

parfor i = 1 : nCase
    if strcmp(modes{i}, 'A')
        if strcmp(centralBody{i}, 'SSB')
            simOut{i} = runSimModeA_SSB(scn(i), eph, ephNames{i});
        elseif strcmp(centralBody{i}, 'ECI')
            simOut{i} = runSimModeA_ECI(scn(i), eph, ephNames{i});
        end
    elseif strcmp(modes{i}, 'B')
        simOut{i} = runSimModeB(scn(i), eph, ephNames{i}, 'Earth');
    elseif strcmp(modes{i}, 'C')
        if strcmp(centralBody{i}, 'SSB')
            simOut{i} = runSimModeC_SSB(scn(i), eph, ephNames{i});
        elseif strcmp(centralBody{i}, 'ECI')
            simOut{i} = runSimModeC_ECI(scn(i), eph, ephNames{i});
        end
    end
    
    chk = load(regressionFiles{i});
    if isequal(chk.simOut, simOut{i})
        fprintf([regressionFiles{i}, ' case passed!\n'])
    else
        error('Error: Regression failed');
    end
end

toc;
