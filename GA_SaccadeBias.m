
%% Step3b--grand average plots of gaze-shift (saccade) results

%% start clean
clear; clc; close all;
    
%% parameters
oneOrTwoD       = 1;
oneOrTwoD_options = {'_1D','_2D'};

pp2do = {40, 'b', 1;
      29, 'l', 1;
      40, 'l', 2;
      29, 'b', 2;
      25, 'l', 1;
      36, 'l', 1;
      77, 'l', 1;
      75, 'l', 1;
      13, 'l', 1;
      30, 'b', 1;
      97, 'b', 1;
      17, 'b', 1;
      99, 'b', 1};

subplot_size = ceil(sqrt(size(pp2do, 1)));

nsmooth         = 200;
plotSinglePps   = 1;
plotGAs         = 1;
xlimtoplot      = [-250 1500];

%% load and aggregate the data from all pp
s = 0;
for pp = 1:size(pp2do, 1)
    s = s+1;

    % get participant data
    param = getSubjParam(pp2do{s, 1}, pp2do{s, 2}, pp2do{s, 3});

    % load
    disp(['getting data from participant ', param.subjName]);
    load([param.savedir, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName, '_', param.session], 'saccade','saccadesize');
    
    % smooth?
    if nsmooth > 0
        for i = 1:size(saccade.toward,1)
            saccade.toward(i,:)  = smoothdata(squeeze(saccade.toward(i,:)), 'gaussian', nsmooth);
            saccade.away(i,:)    = smoothdata(squeeze(saccade.away(i,:)), 'gaussian', nsmooth);
            saccade.effect(i,:)  = smoothdata(squeeze(saccade.effect(i,:)), 'gaussian', nsmooth);
        end

        %also smooth saccadesize data over time.
        for i = 1:size(saccadesize.toward,1)
            for j = 1:size(saccadesize.toward,2)
                saccadesize.toward(i,j,:) = smoothdata(squeeze(saccadesize.toward(i,j,:)), 'gaussian', nsmooth);
                saccadesize.away(i,j,:)   = smoothdata(squeeze(saccadesize.away(i,j,:)), 'gaussian', nsmooth);
                saccadesize.effect(i,j,:) = smoothdata(squeeze(saccadesize.effect(i,j,:)), 'gaussian', nsmooth);
            end
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = saccade.toward;
    d2(s,:,:) = saccade.away;
    d3(s,:,:) = saccade.effect;

    d4(s,:,:,:) = saccadesize.toward;
    d5(s,:,:,:) = saccadesize.away;
    d6(s,:,:,:) = saccadesize.effect;
end

%% make GA for the saccadesize fieldtrip structure data, to later plot as "time-frequency map" with fieldtrip. For timecourse data, we directly plot from d structures above. 
saccadesize.toward = squeeze(mean(d4));
saccadesize.away   = squeeze(mean(d5));
saccadesize.effect = squeeze(mean(d6));

%% all subs
if plotSinglePps
    % toward & away - all
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d1(sp,1,:)));
        plot(saccade.time, squeeze(d2(sp,1,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        % ylim([-0.5 0.5]);
        title(pp2do(sp));
    end
    legend({'toward', 'away'});

    % toward vs away - all
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,1,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        % ylim([-0.5 0.5]);
        title(pp2do(sp));
    end
    legend({'effect'});

    % towardness for all conditions condition - saccade bias X saccade size
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp);
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        cfg.xlim = xlimtoplot;
        subplot(subplot_size,subplot_size,sp); hold on;
        saccadesize.effect = squeeze(d6(sp,:,:,:)); % put in data from this pp
        cfg.channel = 1; % all conditions combined.
        ft_singleplotTFR(cfg, saccadesize);
        title(pp2do(sp));
        colormap('jet');
    end
end

%% Plot grand average data patterns of interest, with error bars
if plotGAs
    % plot toward, away and effect - all
    figure; 
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,1,:)), 'b', 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,1,:)), 'r', 'se');
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    legend([p1, p2], {'toward', 'away'});
    ylim([-0.2, 1])
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    hold off
    
    % plot the effect
    figure;
    hold on
    p7 = frevede_errorbarplot(saccade.time, squeeze(d3(:,1,:)), 'k', 'both');
    xlim(xlimtoplot);
    yticks([0 0.5]);
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylim, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    xlabel('Time (ms)');
    hold off
    
    %% just effect as function of saccade size
    cfg = [];
    cfg.parameter = 'effect';
    cfg.figure = 'gcf';
    cfg.zlim = 'maxabs';
    cfg.xlim = xlimtoplot;  
    cfg.colormap = 'jet';
    
    % per condition
    figure;
    for chan = 1:9
        hold on
        cfg.channel = chan;
        subplot(3,3,chan);
        saccadesize.effect = squeeze(mean(d6(:,:,:,:))); % put in data from all pp
        ft_singleplotTFR(cfg, saccadesize);
        ylabel('Saccade size (dva)');
        xlabel('Time (ms)');
        xlim(xlimtoplot);
    end
  
end
