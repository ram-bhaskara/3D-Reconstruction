function [xm,ym,zm,u,v,U,V] = readImage(filename,feats)
% data = textread('iss_xz_test3.txt'); 
data = textread(filename); 
x_data = data(:,1); 
y_data = data(:,2); 
z_data = data(:,3);

x_data(x_data>1e5)=NaN;
y_data(y_data>1e5)=NaN;
z_data(z_data>1e5)=NaN;

x_new = reshape(x_data', 500,500); 
y_new = reshape(y_data', 500,500); 
z_new = reshape(z_data', 500,500); 

[idu,idv] = find(~isnan(x_new));

msize = numel(idu);
% feats = (randperm(msize, nfeat)); % nfeat = 4 = 4 random features 
% u = idu(feats);
% v = idv(feats);

% u = [349,345,348,332];
% v = [272,242,294,261];
u = round(feats(:,1)); v = round(feats(:,2));
%%
figure
I = mat2gray(z_new');
imshow(I)
hold on
plot(u,v,'Or','MarkerSize',4,'MarkerFaceColor','r')
hold off
%%
xm = [];
ym = [];
zm = [];

for ii =1:length(u)
    xm = [xm;x_new(u(ii),v(ii))];
        ym = [ym;y_new(u(ii),v(ii))];
        zm = [zm;z_new(u(ii),v(ii))];
end

[U,V] = imageUV(u,v);

figure 
plot3(x_data, y_data, z_data);
hold on
plot3(xm,ym,zm,'^r','MarkerSize',4,'MarkerFaceColor','r');
hold off
xlabel('x')
ylabel('y')
zlabel('z')
grid on;

end
