%% Step3-- find saccades from fixation periods

%% start clea
clear; clc; close all;

%% parameter
oneOrTwoD  = 1;
oneOrTwoD_options = {'_1D','_2D'};

plotResults = 0;

%% participants
pp = [12, 13, 17, 19, 25, 29, 30, 36, 40, 49, 57, 66, 75, 77, 95, 97];

%% loop over participants
for p = 1:size(pp, 2)
    % loop over sessions within participant
    for session = [1, 2]

        %% load epoched data of this participant's fixation data
        param = getSubjParam(pp(p), session);
        try
            load([param.savedir, '\epoched_data\fixationdata_m7', '__', param.subjName, '_', param.session], 'eyedata');
            disp(['getting data from ', param.subjName, ' session ', param.session, ': fixation period']);
        catch
            continue
        end
    
        %% only keep channels of interest
        cfg = [];
        cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
        eyedata = ft_selectdata(cfg, eyedata); % select x & y channels
    
        %% reformat all data to a single matrix of trial x channel x time
        cfg = [];
        cfg.keeptrials = 'yes';
        tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?
        tl.time = tl.time * 1000;
    
        %% pixel to degree
        [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
        tl.trial(:,1,:) = dva_x;
        tl.trial(:,2,:) = dva_y;
    
        % channels
        chX = ismember(tl.label, 'eyeX');
        chY = ismember(tl.label, 'eyeY');
    
        %% get gaze shifts using our custom function
        cfg = [];
        data_input = squeeze(tl.trial);
        time_input = tl.time;
        
        dimensions = ndims(data_input);

        if dimensions == 2
            [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(chX,:), data_input(chY,:), time_input);
        elseif dimensions == 3
            [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
        end
    
        %% select usable gaze shifts
        minDisplacement = 0;
        maxDisplacement = 1000;
    
        if oneOrTwoD == 1
            saccadesize = abs(shiftsX);
        elseif oneOrTwoD == 2
            saccadesize = abs(shiftsX+shiftsY*1i);
        end
    
        %% save relevant data
        saccades.sizes = nonzeros(saccadesize)';
        saccades.velocities = nonzeros(peakvelocity)';
        saccades.directions_1d = nonzeros(shiftsX)';
        saccades.directions_2d = nonzeros(shiftsX+shiftsY*1i)';
        
        %% save
        save([param.savedir, '\saved_data\fixationSaccades', oneOrTwoD_options{oneOrTwoD} '__', param.subjName, '_', param.session], 'saccades');


        %% load epoched data of this participant's bias data
        param = getSubjParam(pp(p), session);
        try
            load([param.savedir, '\epoched_data\eyedata_m7', '__', param.subjName, '_', param.session], 'eyedata');
            disp(['getting data from ', param.subjName, ' session ', param.session, ': bias period']);
        catch
            continue
        end
    
        %% only keep channels of interest
        cfg = [];
        cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
        eyedata = ft_selectdata(cfg, eyedata); % select x & y channels
    
        %% reformat all data to a single matrix of trial x channel x time
        cfg = [];
        cfg.keeptrials = 'yes';
        tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?
        tl.time = tl.time * 1000;
    
        %% pixel to degree
        [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
        tl.trial(:,1,:) = dva_x;
        tl.trial(:,2,:) = dva_y;
    
        % channels
        chX = ismember(tl.label, 'eyeX');
        chY = ismember(tl.label, 'eyeY');
    
        %% get gaze shifts using our custom function, BUT ONLY FOR BIAS PERIOD
        timevec = [951:1351];

        cfg = [];
        data_input = squeeze(tl.trial(:,:,timevec));
        time_input = tl.time(timevec);
    
        [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
    
        %% select usable gaze shifts
        minDisplacement = 0;
        maxDisplacement = 1000;
    
        if oneOrTwoD == 1
            saccadesize = abs(shiftsX);
        elseif oneOrTwoD == 2
            saccadesize = abs(shiftsX+shiftsY*1i);
        end
    
        %% save relevant data
        saccades.sizes = nonzeros(saccadesize)';
        saccades.velocities = nonzeros(peakvelocity)';
        saccades.directions_1d = nonzeros(shiftsX)';
        saccades.directions_2d = nonzeros(shiftsX+shiftsY*1i)';
        
        %% save
        save([param.savedir, '\saved_data\biasSaccades', oneOrTwoD_options{oneOrTwoD} '__', param.subjName, '_', param.session], 'saccades');

    %% end loops
    end % end of session loop
end % end of pp loop
