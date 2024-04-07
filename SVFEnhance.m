%{
    Example use:
        [A, result] = svf(double(imread('cat.png'))/255.0, 3, 0.025);
        imshow(result);
%}

%   Parameters
%       inName  = Name of your PNG image sans extension
%       radius  = filter radius (in pixels)
%       epsilon = epsilon (threshold variance value of a clear edge to preserve)
%       mAmp    = Medium details enhancement factor
%       fAmp    = Fine details enhancement factor
%
%   Outputs:
%       The enhanced image
%

function result = SVFEnhance( inimg, radius, epsilon, fAmp, sAmp, mAmp)
    B=inimg;
    B=cat(3,B,B,B);

    inImage=double(B);
    [~, base0] = svf( inImage, radius, epsilon );
    detailF = inImage - base0;
    [~, base1] = svf( base0, radius * 2, epsilon * 2 );
    detailS = base0 - base1;

    result = base0 + fAmp * detailF + sAmp * detailS;
    result=result(:,:,1);

end