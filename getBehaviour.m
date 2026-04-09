clear all
close all
clc

%% set parameters and loops
display_percentage_ok = 0;
plot_individuals = 1;
plot_averages = 1;

pp = {40, 'b';
      29, 'l'};

subplot_size = ceil(sqrt(size(pp, 1)));

for p = 1:size(pp, 1)
    ppnum(p) = pp{p, 1};
    figure_nr = 1;
    
    param = getSubjParam(pp{p, 1}, pp{p, 2}, 1); 
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    behdata = readtable(param.log);

    %% check percentage oktrials
    % select trials with reasonable decision times
    oktrials = abs(zscore(behdata.idle_reaction_time_in_ms))<=3; 
    percentageok(p) = mean(oktrials)*100;
  
    % display percentage ok trials
    if display_percentage_ok
        fprintf('%s has %.2f%% oktrials\n\n', param.subjName, percentageok(p,1))
    end
    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.idle_reaction_time_in_ms,50);
        title(['decision time - pp ', num2str(ppnum(p))]);
        xlim([0 2000]);
        ylim([0 150]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(behdata.response_time_in_ms, 50);
        title(['response time - pp ', num2str(ppnum(p))]);
        xlim([0 2010]);
        ylim([0 150]);
        
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.signed_difference(oktrials),50);
        title(['signed error - pp ', num2str(ppnum(p))]);
        xlim([-100 100]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.absolute_difference(oktrials),50);
        title(['error - pp ', num2str(ppnum(p))]);
        xlim([0 100]);
    end

    
    %% trial selections
    left_trials = ismember(behdata.target_position, {'left'});
    right_trials = ismember(behdata.target_position, {'right'});

    obj1_trials = behdata.target_object == 1;
    obj2_trials = behdata.target_object == 2;
    obj3_trials = behdata.target_object == 3;
    obj4_trials = behdata.target_object == 4;
    obj5_trials = behdata.target_object == 5;
    obj6_trials = behdata.target_object == 6;
    obj7_trials = behdata.target_object == 7;
    obj8_trials = behdata.target_object == 8;

    premature_trials = ismember(behdata.premature_pressed, {'True'});
    
    %% extract data of interest
    overall_dt(p,1) = mean(behdata.idle_reaction_time_in_ms(oktrials), "omitnan");
    overall_error(p,1) = mean(behdata.signed_difference(oktrials), "omitnan");
    overall_abs_error(p,1) = mean(behdata.absolute_difference(oktrials), "omitnan");
    
end

if plot_averages
 %% check performance
    figure; 
    figure_nr = figure_nr+1;
    subplot(4,1,1);
    bar(ppnum, overall_dt(:,1));
    title('overall decision time');
    ylim([0 900]);
    xlabel('pp #');

    subplot(4,1,2);
    bar(ppnum, overall_error(:,1));
    title('overall error');
    xlabel('pp #');

    subplot(4,1,3);
    hold on
    bar(ppnum, overall_abs_error(:,1));
    title('overall abs error');
    xlabel('pp #');

    subplot(4,1,4);
    bar(ppnum, percentageok);
    title('percentage ok trials');
    ylim([90 100]);
    xlabel('pp #');

end
