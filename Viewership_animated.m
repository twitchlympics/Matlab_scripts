clear all
close all
clc


n_viewers=10000;               %%number of viewers
n_attributes=50;                %%number of random attributes for viewer/streamer compatibility, viewer dedication and streamer quality
n_streamers=100;                %%number of streamers
rounddecimal=2;                 %%attribute decimalrounding
attribute_viewers = round(rand([n_attributes,n_viewers]),rounddecimal); %%creating matrix with viewers in rows and their random attributes in columns
attribute_streamers =  round(rand([n_streamers,n_attributes]),rounddecimal); %%creating matrix with streamers in columns and their random qualities(attributes) in rows

%%defining loop variables

i=1;    
j=1;
sum_attributes_streamers=zeros(n_streamers,1);  %%creating Matrix with later purpose of showing sum of streamer attributes which is streamer quality
sum_attributes_viewers=zeros(n_viewers,1);    %%creating Matrix with later purpose of showing sum of viewer attributes which is viewer dedication
compatibility = zeros(n_viewers,n_streamers);  %%creating matrix with later purpose of representing viewer/streamer compatibility

resultingViewership = zeros(n_viewers,n_streamers);   %%creating matrix with later purpose of representing viewership (viewers in columns, streamers in rows). Each row can only have one 1 as you can only be watchin gone channel. 
sumViewers=zeros(1,n_streamers); %%creating matrix with later purpose of summing up viewers per channel

streamerOnline = round(rand([1, n_streamers]), 0); %Vector describing which streamers are online (0:offline, 1:online)


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

i=1; %%reseting i
while i <= n_viewers
    [M,I] = max(compatibility(i,:).*streamerOnline);
    resultingViewership(i,I)=1;
    i=i+1;
end


%========== Animation =====================================================
step = 0; % keep track of which step in time one is in
t = 0; % in hours
T = 10; % end time
tStep = 0.25; %step time in hours
n_intervals = (T-t)/tStep;

viewership = zeros(n_intervals, 5); % Matrix for area graph of the top 5 streamers over time

viewerUpdateRate = round(rand([1, n_viewers]),rounddecimal); %How likely a viewer is going to check for better channels

figure
box on;
while t < T
    step = step +1;
    display(t)
    
    %Bring Best streamer online
    if t > 2
        streamerOnline(bestStreamerIndex) = 1;
        
        if t > 6
            streamerOnline(bestStreamerIndex) = 0;
        end
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
    
    sumViewers_sorted = sort(sumViewers);  %%sorting viewership per channel
    viewership(step,:) = sumViewers_sorted(end-4:end);
    
    %====== Plots =========================================================

    %%plot representing sorted viewer distribution over channels
    subplot(2,2,1)
    bar(sumViewers)
    title('Viewer Distribution over Channels')
    xlabel('Channels')
    ylabel('No. of Viewers')

    %Viewer distribution sorted and semilogarithmic
    subplot(2,2,2)
    semilogy(sumViewers_sorted)
    title('Viewer Distribution over Channels')
    xlabel('Sorted Channels')
    ylabel('No. of Viewers')
    
    
    %Viewership over time
    subplot(2,2,3)
    area(viewership)
    
    

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
    
    pause(1);
    
    t = t + tStep;
end