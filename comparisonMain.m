clear
close all
clc


addpath(genpath(pwd));


% Scripts to create comparison plots.  This script loads regression files,
% rather than running computations, since running the scenarios takes a
% long time.
%
% Modes:
%   A: Pure N-Body formulation with Newtonian mechanics
%   B: Defined planet remains at the origin, with select third-body gravity
%      perturbations, using DE440 ephemeris
%   C: Full solar system simulation with DE440 ephemeris

%% MODE A TO MODE C

% Compare the SSB-centric full solar system simulation for mode A and mode
% C, using the SSB reference frame.
scn1 = load('.\Regression\Scn1A-SSB-FullSol.mat');
scn2 = load('.\Regression\Scn1C-SSB-FullSol.mat');
comparisonPlotNbdyEph(scn1.simOut, scn2.simOut, 'SSB');

% Compare the SSB-centric full solar system simulation for mode A and mode
% C, using the ECI reference frame.
scn1 = load('.\Regression\Scn1A-ECI-FullSol.mat');
scn2 = load('.\Regression\Scn1C-ECI-FullSol.mat');
comparisonPlotNbdyEph(scn1.simOut, scn2.simOut, 'ECI');


%% MODE A TO MODE B COMPARISONS

% Compare the mode A (pure N-body) simulations, in the SSB frame, to the
% mode B simulations (which here, are Earth-centric with selected
% perturbing bodies).
scn1 = load('.\Regression\Scn1A-SSB.mat');
scn2 = load('.\Regression\Scn1B-ECI.mat');
comparisonPlotSpacecraft(scn1.simOut, scn2.simOut, 'ECI');

scn1 = load('.\Regression\Scn1A-SSB-VenJup.mat');
scn2 = load('.\Regression\Scn1B-ECI-VenJup.mat');
comparisonPlotSpacecraft(scn1.simOut, scn2.simOut, 'ECI');

scn1 = load('.\Regression\Scn1A-SSB-FullSol.mat');
scn2 = load('.\Regression\Scn1B-ECI-FullSol.mat');
comparisonPlotSpacecraft(scn1.simOut, scn2.simOut, 'ECI');

scn1 = load('.\Regression\Scn1A-ECI.mat');
scn2 = load('.\Regression\Scn1B-ECI.mat');
comparisonPlotSpacecraft(scn1.simOut, scn2.simOut, 'ECI');

scn1 = load('.\Regression\Scn1A-ECI-VenJup.mat');
scn2 = load('.\Regression\Scn1B-ECI-VenJup.mat');
comparisonPlotSpacecraft(scn1.simOut, scn2.simOut, 'ECI');

scn1 = load('.\Regression\Scn1A-ECI-FullSol.mat');
scn2 = load('.\Regression\Scn1B-ECI-FullSol.mat');
comparisonPlotSpacecraft(scn1.simOut, scn2.simOut, 'ECI');


%% MODE B TO MODE C COMPARISON

% Compares mode B (STK mode) to mode C (full solar system acceleration
% model).  Spacecraft only, since mode B does not compute Earth position
% wrt. solar system barycenter.

scn1 = load('.\Regression\Scn1B-ECI-FullSol.mat');
scn2 = load('.\Regression\Scn1C-SSB-FullSol.mat');
comparisonPlotSpacecraft(scn2.simOut, scn1.simOut, 'ECI');



%% MODE A REFERENCE FRAME COMPARISONS

% Compare pure N-Body simulations using Sun, Earth, Moon, and Spacecraft,
% using SSB and ECI reference frames
scn1 = load('.\Regression\Scn1A-SSB.mat');
scn2 = load('.\Regression\Scn1A-ECI.mat');
comparisonPlotRefFrame(scn1.simOut, scn2.simOut, 'SSB', 'ECI', 'ECI', 'A')

% Compare pure N-Body simulations using Sun, Earth, Moon, and Spacecraft,
% using SSB and ECI reference frames
scn1 = load('.\Regression\Scn1A-SSB-VenJup.mat');
scn2 = load('.\Regression\Scn1A-ECI-VenJup.mat');
comparisonPlotRefFrame(scn1.simOut, scn2.simOut, 'SSB', 'ECI', 'ECI', 'A')

% Compare pure N-Body simulations using Sun, Earth, Moon, and Spacecraft,
% using SSB and ECI reference frames
scn1 = load('.\Regression\Scn1A-SSB-FullSol.mat');
scn2 = load('.\Regression\Scn1A-ECI-FullSol.mat');
comparisonPlotRefFrame(scn1.simOut, scn2.simOut, 'SSB', 'ECI', 'ECI', 'A')


%% MODE C REFERENCE FRAME COMPARISONS

% Compare full solar system simulations using SSB and ECI reference frames
scn1 = load('.\Regression\Scn1C-SSB-FullSol.mat');
scn2 = load('.\Regression\Scn1C-ECI-FullSol.mat');
comparisonPlotRefFrame(scn1.simOut, scn2.simOut, 'SSB', 'ECI', 'ECI', 'C')