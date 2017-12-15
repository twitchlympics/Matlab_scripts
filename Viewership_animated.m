clear all
close all
clc


n_viewers=10000;                %%number of viewers
n_attributes=50;                %%number of random attributes for viewer/streamer compatibility, viewer dedication and streamer quality
n_streamers=50;                %%number of streamers
rounddecimal=2;                 %%attribute decimalrounding
attribute_viewers = round(rand([n_attributes,n_viewers]),rounddecimal); %%creating matrix with viewers in rows and their random attributes in columns
attribute_streamers =  round(rand([n_streamers,n_attributes]),rounddecimal); %%creating matrix with streamers in columns and their random qualities(attributes) in rows

step = 0; % keep track of which step in time one is in
t = 0; % in hours
T = 48; % end time
tStep = 0.25; %step time in hours
n_intervals = (T-t)/tStep;
timeticks=linspace(0,n_intervals,10);   %generate array for time plot
timeticklabels=round(linspace(t,T,10),0);        %generate array for time plot, actual values

streamerOnline = round(rand(1,n_streamers),0);      %generate online Status for streamers

%streamers will get a random straming time value between [x] and [y] hours:
min_streaming_time=2;
max_streaming_time=8;


viewership = zeros(n_intervals, 5); % Matrix for area graph of the top 5 streamers over time

%%defining loop variables

i=1;    
j=1;
sum_attributes_streamers=zeros(n_streamers,1);  %%creating Matrix with later purpose of showing sum of streamer attributes which is streamer quality
sum_attributes_viewers=zeros(n_viewers,1);    %%creating Matrix with later purpose of showing sum of viewer attributes which is viewer dedication
compatibility = zeros(n_viewers,n_streamers);  %%creating matrix with later purpose of representing viewer/streamer compatibility

resultingViewership = zeros(n_viewers,n_streamers);   %%creating matrix with later purpose of representing viewership (viewers in columns, streamers in rows). Each row can only have one 1 as you can only be watchin gone channel. 
sumViewers=zeros(1,n_streamers); %%creating matrix with later purpose of summing up viewers per channel

streameronTime_base = min_streaming_time+round((max_streaming_time-min_streaming_time)*rand([1, n_streamers]), 1); %Vector describing how long streamers will still stay online
streameroffTime_base = min_streaming_time+round((max_streaming_time-min_streaming_time)*rand([1, n_streamers]), 1); %Vector describing how long streamers will still stay offline
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

i=1; %%resetting i
while i <= n_viewers
    [M,I] = max(compatibility(i,:).*streamerOnline);
    resultingViewership(i,I)=1;
    i=i+1;
end


%========== Animation =====================================================
viewerUpdateRate = round(rand([1, n_viewers]),rounddecimal); %How likely a viewer is going to check for better channels between the time interval
figure
box on;
while t < T
    step = step +1;
    display(t)    
    
    %Set Online Status of Streamers
    i = 1;  %reset i
    while i <=n_streamers
        if (streameronTime(i) <= 0) && (streamerOnline(i) == 1)     
            streamerOnline(i) = 0;                                  %switch streamer to "offline" when he runs out of time
            streameroffTime(i) = streameroffTime_base(i);           %set offline timer (equal to online timer
            color_change(i)=3;                                      %set a color change on status change
        elseif (streameroffTime(i) <= 0) && (streamerOnline(i) == 0)   
            streamerOnline(i) = 1;                                  %switch streamer to "offline" when he runs out of time
            streameronTime(i) = streameronTime_base(i);             %set offline timer (equal to online timer
            color_change(i)=3;                                      %set a color change on status change
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
            [M,I] = max(compatibility(i,:).*streamerOnline);
            resultingViewership(i,I) = 1;
            %display('updated choice')
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
    
    viewership(step,:) = sumViewers_sorted(1:5);
    
    
    %====== Plots =========================================================

    %%plot representing sorted viewer distribution over channels
    subplot(2,2,1)
    bar(sumViewers)
    title('Viewer Distribution over Channels')
    xlabel('Channels')
    ylabel('No. of Viewers')
    xlim([0 n_streamers+1]);

%     %Viewer distribution sorted and semilogarithmic
%     subplot(2,2,3)
%     semilogy(sumViewers_sorted)
%     title('Viewer Distribution over Channels')
%     xlabel('Sorted Channels')
%     ylabel('No. of Viewers')
    
    %%plot representing sorted viewer distribution over channels
    subplot(2,2,2)
    bar(sumViewers_sorted)
    title('sorted Viewer Distribution over Channels')
    xlabel('Sorted Channels (first half)')
    ylabel('No. of Viewers')
    xlim([0 n_streamers/2+1]);
    
    %Streamer online indicator
    subplot(2,2,3)
    bar(streamerOnline,'g')
    title('Streamer activity')
    xlabel('Channels')
    xlim([0 n_streamers+1]);
    
    %Viewership over time
    subplot(2,2,4)
    area(viewership)
    title('Viewer Distribution for Top 5 Streamers')
    xlabel('time [hours]')
    xticks(timeticks);
    xticklabels(timeticklabels);
    ylabel('No. of Viewers')
    
    

%     %%creating figures to represent distribution of viewer dedication and
%     %%streamer quality

%     subplot(2,2,3)
%     histogram(sum_attributes_viewers,50)
%     title('Viewer Dedication')
%     xlabel('Dedication')
%     ylabel('No. of Viewers')
% 
%     subplot(2,2,4)
%     histogram(sum_attributes_streamers)
%     title('Streamer Quality')
%     xlabel('Quality')
%     ylabel('No. of Streamers')
    
    pause(0.1);
    
    t = t + tStep;
    streameronTime=streameronTime-tStep;        %reduce durability of streamers by one time step, end of loop
    streameroffTime=streameroffTime-tStep;        %reduce durability of streamers by one time step, end of loop
end