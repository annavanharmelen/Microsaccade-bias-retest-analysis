%% Step3b--grand averages of saccades from fixation and bias periods

%% start clean
clear; clc; close all;
    
%% parameters
oneOrTwoD       = 1;
oneOrTwoD_options = {'_1D','_2D'};

pp2do = [12, 13, 17, 19, 25, 29, 30, 36, 40, 49, 57, 66, 75, 77, 95, 97];

subplot_size = ceil(sqrt(size(pp2do, 2)*2));

nsmooth         = 200;
plotSinglePps   = 1;
plotGAs         = 1;
xlimtoplot      = [-100 1500];

%% load and aggregate the data from all pp
for s = 1:size(pp2do, 2)
    % loop over sessions within participant
    for session = [1, 2]

        % get participant data of this session
        param = getSubjParam(pp2do(s), session);
    
        % load fixation data
        try
            load([param.savedir, '\saved_data\fixationSaccades', oneOrTwoD_options{oneOrTwoD} '__', param.subjName, '_', param.session], 'saccades');
            disp(['getting data from ', param.subjName, ' session ', param.session, ': fixation period']);
        catch
            continue
        end

        % put into matrix, with pp as first dimension and session as second
        fix_sizes{s,session,:} = saccades.sizes;
        fix_velocities{s,session,:} = saccades.velocities;
        fix_directions_1d{s,session,:} = saccades.directions_1d;
        fix_directions_2d{s,session,:} = saccades.directions_2d;

        % load bias data
        try
            load([param.savedir, '\saved_data\biasSaccades', oneOrTwoD_options{oneOrTwoD} '__', param.subjName, '_', param.session], 'saccades');
            disp(['getting data from ', param.subjName, ' session ', param.session, ': bias period']);
        catch
            continue
        end

        % put into matrix, with pp as first dimension and session as second
        bias_sizes{s,session,:} = saccades.sizes;
        bias_velocities{s,session,:} = saccades.velocities;
        bias_directions_1d{s,session,:} = saccades.directions_1d;
        bias_directions_2d{s,session,:} = saccades.directions_2d;
    end
end

%% create mean data per participant (row = pp, column = session)
average_fix_size = cellfun(@(x) mean(x, "omitnan"), fix_sizes);
average_bias_size = cellfun(@(x) mean(x, "omitnan"), bias_sizes);

average_fix_velocity = cellfun(@(x) mean(x, "omitnan"), fix_velocities);
%etc

fix_size = mean(average_fix_size, 2, "omitnan"); %create mean over two sessions
bias_size = mean(average_bias_size, 2, "omitnan"); %create mean over two sessions

%% create GA figures
figure;
hold on
bar([1,2], [mean(fix_size), mean(bias_size)]);
errorbar([1,2], [mean(fix_size), mean(bias_size)], [std(fix_size) / sqrt(size(fix_size,1)), std(bias_size) / sqrt(size(bias_size,1))], 'LineStyle', 'None');
xticks([1,2]);
xticklabels({"Fixation saccades", "Bias saccades"});
ylabel('Saccade size (deg)');