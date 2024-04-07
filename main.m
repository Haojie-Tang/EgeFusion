clc
clear all;
close all;

% Creates a path to save the image
fuse_floder = './fused_img/';
mkdir(fuse_floder);

for i=[1:3]
    tic;
    index = i;
    disp(['-----test No.',num2str(i),'-----']);
    % Input
    path_Vis = strcat('./test_img/vi/',num2str(index),'.bmp');
    path_IR = strcat('./test_img/ir/',num2str(index),'.bmp');
    path_fused = [fuse_floder ,num2str(index),'.bmp'];  
    
    I_vis = double(imread(path_Vis))/255.0;
    I_ir = double(imread(path_IR))/255.0;
    
    if size(I_vis,3)==3
        I_vis=rgb2gray(double(imread(path_Vis))/255.0);
    else
        I_vis=double(imread(path_Vis))/255.0;
    end
    
    if size(I_ir,3)==3
       I_ir=rgb2gray(double(imread(path_IR))/255.0);
    else
       I_ir=double(imread(path_IR))/255.0;
    end

    % Decomposition
    B_vis = WLSF(I_vis, 1.2, 1.4);
    D_vis=I_vis-B_vis;
    
    B_ir = WLSF(I_ir, 1.2, 1.4);
    D_ir=I_ir-B_ir;

    % Fusion of detail layers
    D_enh_vis = SVFEnhance(D_vis, 2, 0.015, 3, 2);
    D_enh_ir = SVFEnhance(D_ir, 2, 0.015, 3, 2);
    F_D = D_enh_vis + D_enh_ir;

    % Fusion of base layers
    S_vis = Visual_saliency_map(I_vis);
    S_ir = Visual_saliency_map(I_ir);
    w = 0.5+0.5*(S_vis-S_ir);
    F_B = w.*B_vis + (1-w).*B_ir;

    % Reconstruction
    F=F_B+F_D;

    imwrite(F,path_fused,'bmp');
    toc;
end
disp(['----- Fusion finish !!! -----']);

