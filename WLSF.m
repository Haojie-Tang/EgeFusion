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
%                ƽ����������ƽ������
%                ����lambda�������ƽ����ͼ��Ĭ��ֵΪ1
%       
%    alpha       Gives a degree of control over the affinities by non-
%                lineary scaling the gradients. Increasing alpha will
%                result in sharper preserved edges. Default value: 1.2
%                ͨ�������������ݶȣ��Թ����Խ���һ���̶ȵĿ��ơ�?
%                ����alpha��ʹ��Ե���ֱ����������Ĭ��ֵΪ1.2
%       
%    L           Source image for the affinity matrix. Same dimensions
%                as the input image IN. Default: log(IN)
%                Դͼ��Ĺ�������������ͼ��IN������ͬά�ȡ�Ĭ��ֵΪlog��IN��?
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
dy = diff(L, 1, 1); % ��L����ĵ�һά��������֣�Ҳ��������
%                     ���м�ȥ������У��õ���N-1��x Mά�ľ���
dy = -lambda./(abs(dy).^alpha + smallNum);
dy = padarray(dy, [1 0], 'post');% �����һ�еĺ��油��һ��0
dy = dy(:); % ������������������Ay�Խ����ϵ�Ԫ�ع��ɵľ���

dx = diff(L, 1, 2); % ��L����ĵڶ�ά������֣�Ҳ�����ұ�
%                    ���м�ȥ��ߵ��У��õ�N x ��M-1��ά�ľ���?
dx = -lambda./(abs(dx).^alpha + smallNum);
dx = padarray(dx, [0 1], 'post');% �����һ�еĺ��油��һ��0
dx = dx(:); % ������������������Ay�Խ����ϵ�Ԫ��


% Construct a five-point spatially inhomogeneous Laplacian matrix
B(:,1) = dx;
B(:,2) = dy;
d = [-r,-1];
A = spdiags(B,d,k,k);% ��dx����-r��Ӧ�ĶԽ����ϣ���dy����-1��Ӧ�ĶԽ�����

e = dx;
w = padarray(dx, r, 'pre'); w = w(1:end-r);
s = dy;
n = padarray(dy, 1, 'pre'); n = n(1:end-1);

D = 1-(e+w+s+n);
A = A + A' + spdiags(D, 0, k, k);% A ֻ������Խ������з�0Ԫ��

% Solve
OUT = A\IN(:);%
OUT = reshape(OUT, r, c);