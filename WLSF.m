function OUT = wlsFilter(IN, lambda, alpha, L)
% Given an input image IN, we seek a new image OUT, which, on the one 
% hand,is as close as possible to IN, and, at the same time, is as 
% smooth as possible everywhere, except across significant gradients 
% in L.
%
%
%   Input arguments:
%   ----------------
%    IN          Input image (2-D, double, N-by-M matrix). 
%      
%    lambda      Balances between the data term and the smoothness
%                term. Increasing lambda will produce smoother images.
%                Default value is 1.0
%                平衡数据项与平滑度项
%                增加lambda会产生更平滑的图像。默认值为1
%       
%    alpha       Gives a degree of control over the affinities by non-
%                lineary scaling the gradients. Increasing alpha will
%                result in sharper preserved edges. Default value: 1.2
%                通过非线性缩放梯度，对关联性进行一定程度的控制。?
%                增加alpha会使边缘保持保存更清晰。默认值为1.2
%       
%    L           Source image for the affinity matrix. Same dimensions
%                as the input image IN. Default: log(IN)
%                源图像的关联矩阵。与输入图像IN具有相同维度。默认值为log（IN）?
% 
%
%   Example 
%   -------
%     RGB = imread('peppers.png'); 
%     I = double(rgb2gray(RGB));
%     I = I./max(I(:));
%     res = wlsFilter(I, 0.5);
%     figure, imshow(I), figure, imshow(res)
%     res = wlsFilter(I, 2, 2);
%     figure, imshow(res)

if(~exist('L', 'var')),
    L = log(IN+eps);
end

if(~exist('alpha', 'var')),
    alpha = 1.2;
end

if(~exist('lambda', 'var')),
    lambda = 1;
end

smallNum = 0.0001;

[r,c] = size(IN);
k = r*c;

% Compute affinities between adjacent pixels based on gradients of L
dy = diff(L, 1, 1); % 对L矩阵的第一维度上做差分，也就是下面
%                     的行减去上面的行，得到（N-1）x M维的矩阵
dy = -lambda./(abs(dy).^alpha + smallNum);
dy = padarray(dy, [1 0], 'post');% 在最后一行的后面补上一行0
dy = dy(:); % 按列生成向量，就是Ay对角线上的元素构成的矩阵

dx = diff(L, 1, 2); % 对L矩阵的第二维度做差分，也就是右边
%                    的列减去左边的列，得到N x （M-1）维的矩阵?
dx = -lambda./(abs(dx).^alpha + smallNum);
dx = padarray(dx, [0 1], 'post');% 在最后一列的后面补上一列0
dx = dx(:); % 按列生成向量，就是Ay对角线上的元素


% Construct a five-point spatially inhomogeneous Laplacian matrix
B(:,1) = dx;
B(:,2) = dy;
d = [-r,-1];
A = spdiags(B,d,k,k);% 把dx放在-r对应的对角线上，把dy放在-1对应的对角线上

e = dx;
w = padarray(dx, r, 'pre'); w = w(1:end-r);
s = dy;
n = padarray(dy, 1, 'pre'); n = n(1:end-1);

D = 1-(e+w+s+n);
A = A + A' + spdiags(D, 0, k, k);% A 只有五个对角线上有非0元素

% Solve
OUT = A\IN(:);%
OUT = reshape(OUT, r, c);