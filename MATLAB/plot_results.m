%% Speech separation and recognition from an HMM Trained on TIMIT copurs by HTK
% 
%   Plotting HTK training intermediate and final test results 
%
% University of Patras - Anastasia Grigoropoulou 2016

clear;
clc;

% Set up directories
HOME = '../';
RESULTSDIR = strcat(HOME,'logs/');

% Plotting until end of initial training
file_handle = 'log.results_';
file_exts = {'mono','mono_sp','mono_al','tied'};

for i=1:size(file_exts,2)
    filename = strcat(file_handle,file_exts{i});
    % Plotting monophone results
    buffer = fileread(strcat(RESULTSDIR, filename));

    results = regexp(buffer,'(?:\%Correct*\=)(?<h>[0-9.]*)','tokens');
    sent = str2double([results{:}]);
    results = regexp(buffer,'(?:\%Corr*\=)(?<h>[0-9.]*)','tokens');
    word = str2double([results{:}]);

    phn = word(1:3:33);
    wrd_net = word(2:3:33);
    wrd_lm = word(3:3:33);
    sent_net = sent(2:3:33);
    sent_lm = sent(3:3:33);

    DATA = [phn; wrd_net; wrd_lm; sent_net; sent_lm]';

    results_figure_20(DATA, strcat('Figures/',filename,'.fig'));
end

% Plotting subsequent mizing

% Plotting tuning of parameters

