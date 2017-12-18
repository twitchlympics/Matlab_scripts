clear all
close all
clc


n_viewers=10000;                %%number of viewers
n_attributes=100;                %%number of random attributes for viewer/streamer compatibility, viewer dedication and streamer quality
n_streamers=50;                 %%number of streamers
rounddecimal=2;                 %%attribute decimalrounding
attribute_viewers = round(rand([n_attributes,n_viewers]),rounddecimal); %%creating matrix with viewers in rows and their random attributes in columns
attribute_streamers =  round(rand([n_streamers,n_attributes]),rounddecimal); %%creating matrix with streamers in columns and their random qualities(attributes) in rows

step = 0; % keep track of which step in time one is in
t = 0; % in hours
T = 24; % end time, hours
tStep = 0.25; %step time in hours
n_intervals = (T-t)/tStep;
timeticks=linspace(0,n_intervals,11);   %generate array for time plot
timeticklabels=round(linspace(t,T,11),0);        %generate array for time plot, actual values

streamerOnline = round(rand(1,n_streamers),0);      %generate online Status for streamers

%streamers will get a random straming time value between [x] and [y] hours:
min_streaming_time=4;
max_streaming_time=8;


viewership = zeros(n_intervals, 5); % Matrix for area graph of the top 5 streamers over time

%define matrices allowing for color change in graphs
color_change_on = zeros(1,n_streamers);
color_change_off = zeros(1,n_streamers);

%%defining loop variables
i=1;    
j=1;
sum_attributes_streamers=zeros(n_streamers,1);  %%creating Matrix with later purpose of showing sum of streamer attributes which is streamer quality
sum_attributes_viewers=zeros(n_viewers,1);    %%creating Matrix with later purpose of showing sum of viewer attributes which is viewer dedication
compatibility = zeros(n_viewers,n_streamers);  %%creating matrix with later purpose of representing viewer/streamer compatibility

resultingViewership = zeros(n_viewers,n_streamers);   %%creating matrix with later purpose of representing viewership (viewers in columns, streamers in rows). Each row can only have one 1 as you can only be watchin gone channel. 
sumViewers=zeros(1,n_streamers); %%creating matrix with later purpose of summing up viewers per channel

%define viewing threshhold (and turn off viewers if no match is above this
%value)
viewer_threshhold = 0.8+rand(1,n_viewers)/5;

%base vectors describing how long streamers will still stay on/offline
streameronTime_base = min_streaming_time+round((max_streaming_time-min_streaming_time)*rand([1, n_streamers]), 1);
streameroffTime_base = min_streaming_time+round((max_streaming_time-min_streaming_time)*rand([1, n_streamers]), 1);;

streameronTime=streameronTime_base-min_streaming_time;
streameroffTime=2*(streameroffTime_base-min_streaming_time);

%======== Precalculations =================================================

%%loop that calculates streamer quality for each streamer (sum of attributes) 

while j<=n_streamers;
    sum_attributes_streamers(j,1)=sum(attribute_streamers(j,:));
    j=j+1;
end


%%loop that calculates viewer dedication for each viewer (sum of attributes

while i<=n_viewers;
    sum_attributes_viewers(i,1)=sum(attribute_viewers(:,i));
    i=i+1;
end

%======== Settings for animation testing ==================================
%Find streamer with highest quality
[M,I] = max(sum_attributes_streamers);
bestStreamerIndex = I;

%Set best streamer to be offline at start
streamerOnline(bestStreamerIndex) = 0;


%======== Precalculations =================================================

%%loop that calculates streamer/viewer compatibility (row/column wise
%%multiplication) 
j = 1;
while j <= n_streamers    
    i=1;
    while i <= n_viewers
        compatibility(i,j)= attribute_streamers(j,:)*attribute_viewers(:,i);
        i=i+1;
    end
    j=j+1;
end

%calculate threshhold deciding whether viewers will be on- or offline

for i=1:n_viewers
    max_compatibility(i)=max(compatibility(i,:));
    mean_compatibility(i)=mean(compatibility(i,:));
    mean_comp=mean(mean_compatibility(i));
    sigma_compatibility(i)=std2(compatibility(i,:));
    sigma_comp=std2(sigma_compatibility(i));
end
        
i=1; %%resetting i

%calculating viewership matrix (which streamer a viewer is watchting, if
%any)
while i <= n_viewers
    [M,I] = max(compatibility(i,:).*streamerOnline);
    if max_compatibility(I) > mean_comp-sigma_comp
        resultingViewership(i,I) = 1;
    end
    i=i+1;
end


%========== Animation =====================================================
viewerUpdateRate = round(rand([1, n_viewers]),rounddecimal); %How likely a viewer is going to check for better channels between the time interval
figure
box on;
while t < T
    step = step +1;   
    
    %Set Online Status of Streamers
    i = 1;  %reset i
    while i <=n_streamers
        if (streameronTime(i) <= 0) && (streamerOnline(i) == 1)     
            streamerOnline(i) = 0;                                  %switch streamer to "offline" when running out of time
            streameroffTime(i) = streameroffTime_base(i);           %set offline timer (equal to online timer
            color_change_off(i)=10;                                 %set a color change on status change
        elseif (streameroffTime(i) <= 0) && (streamerOnline(i) == 0)   
            streamerOnline(i) = 1;                                  %switch streamer to "offline" when running out of time
            streameronTime(i) = streameronTime_base(i);             %set offline timer (equal to online timer
            color_change_on(i)=5;                                   %set a color change on status change
        end
        
        i=i+1;
    end
    
    i = 1;
    while i <= n_viewers
        %only upate those viewers who want to change channel
        if viewerUpdateRate(i) > rand(1)
            % calculates which streamer each viewer will be watching.
            % (maximum compatibility column gets a 1, rest 0 for each row)(row
            % corresponds to viewer)
            resultingViewership(i,:) = zeros(1, n_streamers); %reset
            [M,I] = max(compatibility(i,:).*streamerOnline);  %find best compatibility
            if max_compatibility(I) > (mean_comp-sigma_comp)  %only make the viewer watch the channel if compatibility is above threshhold 
                resultingViewership(i,I) = 1;
            end
            
        end

        i=i+1;
    end


    %%loop that sums up all viewers per channel (number of "1" per
    %%streamer/column)
    j=1;
    while j<=n_streamers
        sumViewers(1,j)=sum(resultingViewership(:,j));
        j=j+1;
    end
    
    sumViewers_sorted = sort(sumViewers,'descend');  %%sorting viewership per channel
    
    viewership(step,:) = sumViewers_sorted(1:5);   %%area graph entry
    
    
    %====== Plots =========================================================
    
    %%plot representing sorted viewer distribution over channels
    subplot(2,2,1)
    hold off
    
    bar(sumViewers)
    title('Viewer Distribution over Channels')
    xlabel('Channels')
    ylabel('No. of Viewers')
    xlim([0 n_streamers+1])
    ylim([0 n_viewers])
    
    i=1;            %reset i;
    
    %change bar color if a stramer recently went on- or offline
    while i<=n_streamers
        if color_change_on(i)>=0
            hold on
            ylim([0 n_viewers])
            xlim([0 n_streamers+1])
            bar(i,sumViewers(i),'g');
        elseif color_change_off(i)>=0
            hold on
            ylim([0 n_viewers])
            xlim([0 n_streamers+1])
            bar(i,sumViewers(i),'r');
        end
        i=i+1;
    end
    
    %%plot representing sorted viewer distribution over channels in both
    %%linear and log scale
    subplot(2,2,2)
    hold off
    title('sorted Viewer Distribution over Channels')
    xlabel('Sorted Channels (first Half)')
    xlim([0 n_streamers/2+1])
    yyaxis left;
    bar(sumViewers_sorted)
    ylabel('No. of Viewers [lin scale]')
    yyaxis right;
    semilogy(sumViewers_sorted)
    ylabel('No. of Viewers [log scale]')
    
    %Viewership over time
    subplot(2,1,2)
    area(viewership)
    title('Viewer Distribution for Top 5 Streamers')
    xlabel('time [hours]')
    xticks(timeticks);
    xticklabels(timeticklabels);
    ylabel('No. of Viewers')
    ylim([0 n_viewers]);
    
    pause(0.5);
    
    t = t + tStep;
    streameronTime=streameronTime-tStep;        %reduce durability of streamers by one time step, end of loop
    streameroffTime=streameroffTime-tStep;      %reduce durability of streamers by one time step, end of loop
    color_change_on=color_change_on-1;          %reduce color change durability in graph
    color_change_off=color_change_off-1;        %reduce color change durability in graph
end