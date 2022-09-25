function [F1,F2] = matchFeatures_truthInit(img_true, img_guess)
    
    % Extract features from true and create four strong feature matches between
    % the true and the guessed images
    
    IM1 = rgb2gray(imread(img_true));
    IM2 = rgb2gray(imread(img_guess));

%     points1 = detectMinEigenFeatures(IM1,'ROI', [1 1 500 495]);
    points1 = detectMinEigenFeatures(IM1,'ROI', [150 150 200 200]);
    points2 = detectMinEigenFeatures(IM2,'ROI', [1 1 500 495]);
    [features1,validPoints1] = extractFeatures(IM1,points1);
    [features2,validPoints2] = extractFeatures(IM2,points2);
    
%   figure; imshow(img1); hold on
%   plot(validPoints1);
%   hold off
%   figure; imshow(img1); hold on
%   plot(points);
%   hold off 

[indexPairs,matchmetric] = matchFeatures(features1,features2,'MaxRatio',0.7, ...
    'Unique',true);

% % sort matchmetric to find the strongest matches
% [m, id_] = sort(matchmetric); 
%  % indexPairs = indexPairs(id_(1:10),:)
% 

matchedPoints1 = validPoints1(indexPairs(:,1),:);
matchedPoints2 = validPoints2(indexPairs(:,2),:);
% matchedFeatures = length(matchedPoints1);


% Custom matchmetric to eliminate anamolies based on squared distances

dist = zeros(length(matchedPoints1),1); 

for ii=1:length(matchedPoints1)
    dist(ii) = squaredDistance(matchedPoints1(ii).Location, matchedPoints2(ii).Location);
end

[dist_, id] = sort(dist); 

% Only select the top four matched points

matchedPoints1 = matchedPoints1(id(1:4));
matchedPoints2 = matchedPoints2(id(1:4));

figure; 
showMatchedFeatures(IM1,IM2,matchedPoints1,matchedPoints2);

F1 = (matchedPoints1.Location);
                
F2 = (matchedPoints2.Location);

end

function d = squaredDistance(y1, y2)
    % y1 = [u1, v1]
    d = norm(y1-y2);

end