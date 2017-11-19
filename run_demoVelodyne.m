function run_demoVelodyne (base_dir,calib_dir)
% KITTI RAW DATA DEVELOPMENT KIT
% 
% Demonstrates projection of the velodyne points into the image plane
%
% Input arguments:
% base_dir .... absolute path to sequence base directory (ends with _sync)
% calib_dir ... absolute path to directory that contains calibration files

% clear and close everything
close all; dbstop error; clc;
disp('======= KITTI DevKit Demo =======');

% options (modify this to select your sequence)
if nargin<1
  base_dir = './data/2011_09_26_drive_0005_sync';%场景路径
end
if nargin<2
  calib_dir = './data/2011_09_26';%标定文件路径
end
cam       = 2; % 第二个相机
frame     = 0; % 帧数

% load calibration
calib = loadCalibrationCamToCam(fullfile(calib_dir,'calib_cam_to_cam.txt'));
Tr_velo_to_cam = loadCalibrationRigid(fullfile(calib_dir,'calib_velo_to_cam.txt'));

% compute projection matrix velodyne->image plane
R_cam_to_rect = eye(4);
R_cam_to_rect(1:3,1:3) = calib.R_rect{1};
P_velo_to_img = calib.P_rect{cam+1}*R_cam_to_rect*Tr_velo_to_cam; %内外参数

% load and display image
img = imread(sprintf('%s/image_%02d/data/%010d.png',base_dir,cam,frame));
fig = figure('Position',[20 100 size(img,2) size(img,1)]); axes('Position',[0 0 1 1]);
imshow(img); hold on;

% load velodyne points
fid = fopen(sprintf('%s/velodyne_points/data/%010d.bin',base_dir,frame),'rb');
velo = fread(fid,[4 inf],'single')';
velo = velo(1:5:end,:); % remove every 5th point for display speed
fclose(fid);

% remove all points behind image plane (approximation
idx = velo(:,1)<5;
velo(idx,:) = [];

% project to image plane (exclude luminance)
velo_img = project(velo(:,1:3),P_velo_to_img);

% plot points
cols = jet;
for i=1:size(velo_img,1)
  col_idx = round(64*5/velo(i,1));
  plot(velo_img(i,1),velo_img(i,2),'o','LineWidth',4,'MarkerSize',1,'Color',cols(col_idx,:));
end

X_plane=round(velo_img(:,2));
Y_plane=round(velo_img(:,1));
cloud=velo(:,1:3);
indice=find(X_plane>size(img,1));
X_plane(indice)=[];
Y_plane(indice)=[];
cloud(indice,:)=[];
indice=find(X_plane<1);
X_plane(indice)=[];
Y_plane(indice)=[];
cloud(indice,:)=[];
indice=find(Y_plane>size(img,2));
X_plane(indice)=[];
Y_plane(indice)=[];
cloud(indice,:)=[];
indice=find(Y_plane<1);
X_plane(indice)=[];
Y_plane(indice)=[];
cloud(indice,:)=[];

R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);

induv=sub2ind(size(R),X_plane,Y_plane);

cloud(:,4)=double(R(induv))/255+1;
cloud(:,5)=double(G(induv))/255+1;
cloud(:,6)=double(B(induv))/255+1;

savepcd('color_cloud.pcd',cloud');

