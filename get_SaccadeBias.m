%% Step3-- gaze-shift calculation

%% start clea
clear; clc; close all;

%% parameter
oneOrTwoD  = 1;
oneOrTwoD_options = {'_1D','_2D'};

plotResults = 1;

%% participants
pp = {40, 'b';
      29, 'l'};

%% loop over participants
for p = 1:size(pp, 1)
    
    %% load epoched data of this participant data
    param = getSubjParam(pp{p, 1}, pp{p, 2}, 1); 
    load([param.savedir, '\epoched_data\eyedata_m6', '__', param.subjName, '_', param.session], 'eyedata');

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

    %% selection vectors for conditions -- this is where it starts to become interesting!
    % cued item location is always target location
    targL = ismember(tl.trialinfo(:,1), [21:28]);
    targR = ismember(tl.trialinfo(:,1), [29,210:216]);
      
    % what object was the target
    obj1 = ismember(tl.trialinfo(:,1), [21,29]);
    obj2 = ismember(tl.trialinfo(:,1), [22,210]);
    obj3 = ismember(tl.trialinfo(:,1), [23,211]);
    obj4 = ismember(tl.trialinfo(:,1), [24,212]);
    obj5 = ismember(tl.trialinfo(:,1), [25,213]);
    obj6 = ismember(tl.trialinfo(:,1), [26,214]);
    obj7 = ismember(tl.trialinfo(:,1), [27,215]);
    obj8 = ismember(tl.trialinfo(:,1), [28,216]);

    % channels
    chX = ismember(tl.label, 'eyeX');
    chY = ismember(tl.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg = [];
    data_input = squeeze(tl.trial);
    time_input = tl.time;

    [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    if oneOrTwoD == 1
        saccadesize = abs(shiftsX);
    elseif oneOrTwoD == 2
        saccadesize = abs(shiftsX+shiftsY*1i);
    end

    shiftsL = shiftsX<0 & (saccadesize>minDisplacement & saccadesize<maxDisplacement);
    shiftsR = shiftsX>0 & (saccadesize>minDisplacement & saccadesize<maxDisplacement);

    %% get relevant contrasts out
    saccade = [];
    saccade.time = times;
    sel = ones(size(targL)); %NB: selection of oktrials has happened at the start when remove_unfixated is "on".
    saccade.label = {'all', 'paintbrush', 'bandaid', 'bone', 'bottle', 'carrot', 'spoon', 'ruler', 'wrench'};

    for selection = [1:9] % conditions.
        if     selection == 1  sel = ones(size(targL));
        elseif selection == 2  sel = obj1;
        elseif selection == 3  sel = obj2;
        elseif selection == 4  sel = obj3;
        elseif selection == 5  sel = obj4;
        elseif selection == 6  sel = obj5;
        elseif selection == 7  sel = obj6;
        elseif selection == 8  sel = obj7;
        elseif selection == 9  sel = obj8;
        end

        saccade.toward(selection,:) =  (mean(shiftsL(targL&sel,:)) + mean(shiftsR(targR&sel,:))) ./ 2;
        saccade.away(selection,:)  =   (mean(shiftsL(targR&sel,:)) + mean(shiftsR(targL&sel,:))) ./ 2;
    end

    % add towardness field
    saccade.effect = (saccade.toward - saccade.away);
    
    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    
    saccade.toward = smoothdata(saccade.toward,2,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccade.away   = smoothdata(saccade.away,2,  'movmean',integrationwindow)*1000;
    saccade.effect = smoothdata(saccade.effect,2,'movmean',integrationwindow)*1000;
       
    %% plot
    if plotResults
        figure; 
        hold on
        plot(saccade.time, saccade.toward(1,:,:), 'b');
        plot(saccade.time, saccade.away(1,:,:), 'r');
        plot(saccade.time, saccade.effect(1,:,:), 'k');
        title('Main effect');
        hold off
    end

    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:7-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = times;
    saccadesize.label = saccade.label;

    c = 0;
    for sz = saccadesize.freq;
        c = c+1;
        
        shiftsL = [];
        shiftsR = [];
        shiftsL = shiftsX<-sz+halfbin & shiftsX > -sz-halfbin; % left shifts within this range
        shiftsR = shiftsX>sz-halfbin  & shiftsX < sz+halfbin; % right shifts within this range

        for selection = [1:9] % conditions.
            if     selection == 1  sel = ones(size(targL));
            elseif selection == 2  sel = obj1;
            elseif selection == 3  sel = obj2;
            elseif selection == 4  sel = obj3;
            elseif selection == 5  sel = obj4;
            elseif selection == 6  sel = obj5;
            elseif selection == 7  sel = obj6;
            elseif selection == 8  sel = obj7;
            elseif selection == 9  sel = obj8;
            end

            saccadesize.toward(selection,c,:) = (mean(shiftsL(targL&sel,:)) + mean(shiftsR(targR&sel,:))) ./ 2;
            saccadesize.away(selection,c,:) =   (mean(shiftsL(targR&sel,:)) + mean(shiftsR(targL&sel,:))) ./ 2;
        end

    end
   
    % add towardness field
    saccadesize.effect = (saccadesize.toward - saccadesize.away);

    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccadesize.toward = smoothdata(saccadesize.toward,3,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccadesize.away   = smoothdata(saccadesize.away,  3,'movmean',integrationwindow)*1000;
    saccadesize.effect = smoothdata(saccadesize.effect,3,'movmean',integrationwindow)*1000;
    
    %% plot saccadesize effects
    if plotResults
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = [-0.5, 0.5];
        figure;
        cfg.channel = 1;
        ft_singleplotTFR(cfg, saccadesize);
        colormap('jet');
        drawnow;
    end

    %% save
    save([param.savedir, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName, '_', param.session], 'saccade','saccadesize');
    %% close loops
end % end pp loop
