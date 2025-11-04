% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::                                                                                                                         :::
% :::                                 ADAPTnGUIDE Analysis Script                                      :::
% :::                                                                                                                         :::
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% This Python script corresponds to the third phase of the ADAPTnGUIDE: Analysis phase.
% This script is an alternative to aid users not familiar with Root to analyze simulation results.
% This script does the following:
%       - Opens the Geant4-generated output .csv files: ADAPT_Results_h1_Energy_Deposit.csv and ADAPT_Results_nt_Photons.csv
%       - Extracts the energy histogram information from ADAPT_Results_h1_Energy_Deposit.csv and plots the energy spectrum
%       - Extracts the energy deposited information from ADAPT_Results_nt_Photons.csv for each hit inside the detector generating
%         a 3D-hits map
%       - Generates a 2D image from the radioactive source seen from the detector using the GammaEnergyDep.csv file. This file may 
%         contain energy deposited or absorbed dose (depending on the user's choice)
%            
% Author: Víctor Daniel Díaz Martínez
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

clc; close all; clear;                                                                                      % Cleaning commands
addpath('/Users/victor/Documents/MATLAB/Functions')                        % We add the path to the folder containing all the functions. Make sure to add yours!


% The following are visualization flags to enable the hits map inside the detector and the reconstructed image
% 1: enables visualization
% 0: disbales visualization
%   The more runs in the macro file, the larger the size of the file --> the longer it will take to generate the maps

visFlag1 = 0;  % Hits map
visFlag2 = 0;  % Reconstructed image



% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% ::::::                        WELCOMING MESSAGE                         ::::::
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

disp('::::::::::::::::::::::::::::::::::::::::::::::: ADAPTnGUIDE :::::::::::::::::::::::::::::::::::::::::::::::');
fprintf('\n');
fprintf('                             Welcome to ADAPTnGUIDE Analysis phase!\n');
fprintf('\n');
fprintf('  I am analyzing your output files. Give me a moment...\n'); 
fprintf('\n');


% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::                                 ENERGY SPECTRUM                           :::
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

[EnergySpectrumNtuple, EnergySpectrumHisto, bin_centers, num_bins, x_min, x_max] = Histograms;                                        % We call the function Histograms to plot the energy spectrum

EnergySpectrumHisto(1) = 0;                                                                                                                    % Set the first bin count to 0 since it represents events that did not interact isnide the crystal
maxLim = max(EnergySpectrumHisto) + 1000;                                                                                        % Set the max Y-axis value for better visualization
X = linspace(x_min, x_max, num_bins);                                                                                                     % Energy array for the energy spectrum
Error = sqrt(EnergySpectrumHisto);                                                                                                          % Uncertainty for each cpunt per bin


% ::: N T U P L E    H I S T O G R A M :::
figure(1)
histogram(EnergySpectrumNtuple, 300, 'FaceColor','r', 'EdgeColor', 'none');
title('Energy Deposited Ntuples', 'Interpreter', 'latex', 'FontSize', 13);
xlabel('Energy (MeV)', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('No. of counts', 'Interpreter', 'latex', 'FontSize', 13);
axis square


% ::: E N E R G Y    H I S T O G R A M :::
figure(2)
%bar(bin_centers, EnergySpectrumHisto, 'BarWidth', 1, 'FaceColor', 'b', 'EdgeColor', 'none'); % if you want the energy spectrum in bar format
%plot(X,EnergySpectrumHisto, 'b', 'LineWidth',1);
errorbar(X, EnergySpectrumHisto, Error, '.-b', 'LineWidth', 1, 'CapSize', 0, 'MarkerSize', 10);
title('Energy Spectrum Histogram', 'Interpreter', 'latex', 'FontSize', 13);
xlabel('Energy (MeV)', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('No. of counts', 'Interpreter', 'latex', 'FontSize', 13);
set(gca,'TickDir','out');
ylim([0 maxLim])
xlim([0 0.6])
grid on
axis square



% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::       DETECTOR  EFFICIENCY   AND  VISUALIZATION          :::
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

DataTable = readtable('ADAPT_Results_nt_Photons.csv', 'PreserveVariableNames', true );                    % We import the name of the file containing the photon information in Ntuples
Data = table2array(DataTable);                                                                                                                 % Conversion to arrays

Events  = Data(:,1);                                                                                                                                     % Extraction of data
X           = Data(:,2);                                                                
Y           = Data(:,3);
Z           = Data(:,4);
Energy = Data(:,5);


% :::::: E R R O R    C A L C U L A T I O N ::::::
Unique_Events = unique(Events);                                                                                                              % Events that had an interaction in the detector
AllEvents = length(Unique_Events);                                                                                                           % All events scored in the detector
TotEnergyperEvent = zeros(AllEvents,1);                                                                                                  % Empty array for the Total Energy Deposited per Event

for i = 1:AllEvents
    EventID = Unique_Events(i);
    TotEnergyperEvent(i) = sum(Energy(Events == EventID));                                                                   % Iteration over each event to get the total energy deposited per event
end

macroFile     = 'ADAPT.mac';                                                                                                                       % Read the macro file to extract data for the efficiency 
fid                 = fopen(macroFile, 'r');

lines = textscan(fid, '%s', 'Delimiter', '\n');       
fclose(fid);
lines = lines{1};     
    

% ::: N U M B E R    O F    R U N S :::
NoOfRuns = lines{83};                                                                                                                                % Number of runs located in line 83 of the macrofile
tokens = regexp(NoOfRuns, '([\d.]+)', 'tokens');                                                                                         % Extracting the x y z no. of voxels
N_simulated = str2double(tokens{1});                                                                                                       % Converting string to doubles
N_detected = find(TotEnergyperEvent > 0.0);                                                                                          % Events that actually deposited 
N_detected = length(N_detected);
E_mean = mean(TotEnergyperEvent);                                                                                                       % Mean energy deposited


% ::: H I S T O R Y  -  B Y  -  H I S T O R Y :::
sum_x2 = sum(TotEnergyperEvent.^2)/N_detected;                                                                                % First term 
sum_x   = (sum(TotEnergyperEvent)/N_detected)^2;                                                                               % Second term
sigma_Edep = sqrt((sum_x2 - sum_x) / (N_detected - 1));                                                                        % Uncertainty


% ::::::  D E T E C T O R    E F F I C I E N C Y ::::::
Det_e = N_detected/N_simulated;
DetEff = Det_e*100;                                                


% ::: E  F F I C I E N C Y    U N C E R T A I N T Y :::
sigma_eff = Det_e * sqrt( (1/N_detected) + (1/N_simulated) ) * 100; 


% :::::: 3D   E N E R G Y    D E P O S I T I O N    M A P ::::::
if visFlag1 == 1
    figure(3)                                                                        % 3D Plot
    scatter3(X, Y, Z, 5, Energy, 'filled');
    title('3D Energy Deposition Hits');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)'); 
    colormap jet; colorbar;
    %view (180,0);  % 2D visualization
end



% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% :::                 COMMAND-BASED FILES ANALYSIS                  :::
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

% :::::: M A C R O    F I L E ::::::
if visFlag2 == 1
    macroFile     = 'ADAPT.mac';                                                              % Read the macro file to extract data 
    fid                 = fopen(macroFile, 'r');

    if fid == -1                                                                                            % If statement if the file cannot be opened
        error('Could not open the .mac file.');
    end

    lines = textscan(fid, '%s', 'Delimiter', '\n');       
    fclose(fid);
    lines = lines{1};                                                                                    % Convert cell to array of strings


    % ::: D E T E C T O R    S I Z E :::
    cylinderSizeLine = lines{22};                                                               % Size of the scoring volume located in line 22 of the macrofile
    tokens = regexp(cylinderSizeLine, '([\d.]+) ([\d.]+)', 'tokens');            % Extracting the R and Z size values
    CylSize = str2double(tokens{1});                                                         % Converting string into doubles


    % ::: V O X E L S :::
    nBinLine = lines{23};                                                                            % Number of voxels located in line 23 of the macrofile 
    tokens = regexp(nBinLine, '([\d.]+) ([\d.]+) ([\d.]+)', 'tokens');            % Extracting the  R, Z, Phi no. of voxels
    nBin = str2double(tokens{1});                                                             % Converting string to doubles

    NoVoxR    = nBin(1);
    NoVoxZ    = nBin(2);
    NoVoxPhi = nBin(3);

    DetRad = CylSize(1);
    DetLen = 2*CylSize(2);


    % ::::::::: C S V    F I L E :::::::::

    GammaData = readmatrix('CylinderGammaEnergyDep.csv');         % We read the csv file 

    % ::: V O X E L S    I N F O R M A T I O N :::
    iZ          = GammaData(:, 1);                                                               % Z (layer)
    iPhi       = GammaData(:, 2);                                                               % Phi (angle)
    iR          = GammaData(:, 3);                                                               % R (radius)
    Energy = GammaData(:, 4);                                                               % Energy deposition

    % ::: Getting unique values of each vector  :::
    uniqueZ    = unique(iZ);                                                                      % Unique Z values (layers)
    uniquePhi = unique(iPhi);                                                                   % Unique Phi values (angles)
    uniqueR    = unique(iR);                                                                      % Unique R values (radii)

    EnergyMatrices = cell(NoVoxZ, 1);                                                     % Initialize a cell array to store the matrices for each Z layer

    % ::: Loop through each Z layer :::
    for zIdx = 1:NoVoxZ

        currentZ = uniqueZ(zIdx);  
        layerData = GammaData(iZ == currentZ, :);                    % Filter data for the current Z layer
        EnergyMatrix = zeros(NoVoxR, NoVoxPhi);                     % Initialize energy matrix for this layer (R x Phi)

        % ::: Fill the matrix with energy values :::
        for row = 1:size(layerData, 1)
            rIdx     = find(uniqueR == layerData(row, 3));              % Get R index (row)
            phiIdx = find(uniquePhi == layerData(row, 2));           % Get Phi index (column)
            EnergyMatrix(rIdx, phiIdx) = layerData(row, 4);          % Store Energy
        end

    
        EnergyMatrices{zIdx} = EnergyMatrix;                            % Store the matrices
    end


    % ::::::::: P L O T :::::::::

    %intensity_matrix = repmat(linspace(100, 0, NoVoxR)', 1, NoVoxPhi);        % Intensity matrix for testing purposes (100 - 0)
    %intensity_matrix(1:20,:) = 0;

    % ::: Radial and Angular Dimensions :::
    r = linspace(0, DetRad, NoVoxR)';                                                                   % Radii range (0 - scoring volume max radius)
    theta = linspace(0, 2*pi, NoVoxPhi);                                                              % Angular dimension (0°- 360°)

    [R, Theta] = meshgrid(r, theta);                                                                      % Polar coordinates mesh
    [X, Y] = pol2cart(Theta, R);                                                                             % Converting polar coordinates to cartesian 

    ArrayEnergyMatrices = cat(3,EnergyMatrices{:});                                         % Converting the cell arrays into a 3D array (R, Phi, Layers)
    LayerEnMatrix = ArrayEnergyMatrices(:, :, 50);                                             % 50 is the 50th layer. Choose the layer you would like to visualize
    LayerEnMatrix(1:2, :) = 0;                                                                             % Set the inside of the cylindrical scoring volume to 0 to correctly vizualize the detector


    figure(4)
    surf(X, Y, LayerEnMatrix');
    %surf(X, Y, intensity_matrix');
    title('Gráfica Polar con Intensidad desde Matriz (Dimensiones Corregidas)');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    shading flat; 
    colormap dosemap; 
    colorbar;
    axis equal;
    view(2)
end


% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% ::::::                           DISPLAYING RESULTS                         ::::::
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

disp('  I finished! Your results are listed below.');
fprintf('\n');
disp(':::::::::::::::::::::::::::::::::::::::::::::::      RESULTS      ::::::::::::::::::::::::::::::::::::::::::::::');
fprintf('\n');
fprintf('  Events in the detector:    %d\n', N_detected);
fprintf('  Mean energy deposited:  %.4f MeV\n', E_mean);
fprintf('  Statistical uncertainty:    %.4f MeV\n', sigma_Edep);
fprintf('\n');
fprintf('  Detector efficiency: %.4f %%', DetEff);
fprintf(' ± %.4f  %%\n', sigma_eff);
fprintf('\n');
disp(':::::::::::::::::::::::::::::::::::::::::::::::          END          :::::::::::::::::::::::::::::::::::::::::::::');

% :::::::::: MOVING FILES TO A SPECIFIC LOCATION ::::::::::

% SpectraPath = (pwd +"/Results/");     % We 'cd' to the folder in which we want to send the files
% addpath(SpectraPath);                      % We add the path for the Results folder
% movefile *.csv  Results                       % We move all the .csv files to the Results folder

% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: END ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

