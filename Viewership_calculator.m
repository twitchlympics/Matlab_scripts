clear all
close all
clc


n_viewers=150000;               %%number of viewers
n_attributes=50;                %%number of random attributes for viewer/streamer compatibility, viewer dedication and streamer quality
n_streamers=100;                %%number of streamers
rounddecimal=2;                 %%attribute decimalrounding
rand_attribute_viewers = round(rand([n_attributes,n_viewers]),rounddecimal); %%creating matrix with viewers in rows and their random attributes in columns
rand_attribute_streamers =  round(rand([n_streamers,n_attributes]),rounddecimal); %%creating matrix with streamers in columns and their random qualities(attributes) in rows


%%defining loop variables

i=1;    
j=1;
sum_attributes_streamers=zeros(n_streamers,1);  %%creating Matrix with later purpose of showing sum of streamer attributes which is streamer quality
sum_attributes_viewers=zeros(n_streamers,1);    %%creating Matrix with later purpose of showing sum of viewer attributes which is viewer dedication

resultingproduct=zeros(n_viewers,n_streamers);  %%creating matrix with later purpose of representing viewer/streamer compatibility
resultingviewership=zeros(n_viewers,n_streamers);   %%creating matrix with later purpose of representing viewrship (viewrs in columns, streamers in rows) 
sumviewers=zeros(1,n_streamers); %%creating matrix with later purpose of summing up viewers per channel


%%loop that calculates streamer/viewer compatibility (row/column wise
%%multiplication) 

while j <= n_streamers
    
    i=1;
    
    while i <= n_viewers
        resultingproduct(i,j)= rand_attribute_streamers(j,:)*rand_attribute_viewers(:,i);
        i=i+1;
    end
    

j=j+1;

end

%%loop that calculates which streamer each viewer will be watching.
%%(maximum compatibility column gets a 1, rest 0 for each row)(row
%%corresponds to viewer)

i=1; %%reseting i
while i <= n_viewers
    
    [M,I] = max(resultingproduct(i,:));
    resultingviewership(i,I)=1;
    i=i+1;
end


j=1; %reseting j


%%loop that sums up all viewers per channel (number of "1" per
%%streamer/column)

while j<=n_streamers
    
    sumviewers(1,j)=sum(resultingviewership(:,j));
j=j+1;

end

j=1; %%reseting j

%%loop that calculates streamer quality for each streamer (sum of attributes) 

while j<=n_streamers;
    
sum_attributes_streamers(j,1)=sum(rand_attribute_streamers(j,:));
j=j+1;

end

i=1; %%resetting i

%%loop that calculates viewer dedication for each viewer (sum of attributes

while i<=n_viewers;
    
sum_attributes_viewers(i,1)=sum(rand_attribute_viewers(:,i));
i=i+1;

end



sumviewers_sorted=sort(sumviewers);  %%sorting viewership per channel

figure %%creating figure representing sorted viewer distribution over chanels
subplot(2,2,1)
bar(sumviewers_sorted)

%%creating figures to represent distribution of viewer dedication and
%%streamer quality
subplot(2,2,2)
histogram(sum_attributes_viewers,50)

subplot(2,2,3)
histogram(sum_attributes_streamers)