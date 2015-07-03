function [ synthim, offsets ] = PatchMatch( sourceim, targetim, winsize, iter)
%implementation of PatchMatch

greySrc = rgb2gray(sourceim);

[mTarg, nTarg, oTarg] = size(targetim);
[mSrc, nSrc, oSrc] = size(sourceim);

offi = randi([1 mSrc-winsize+1],mTarg-winsize+1,nTarg-winsize+1);
offj = randi([1 nSrc-winsize+1],mTarg-winsize+1,nTarg-winsize+1);

for i = 1:size(offi,1)
    for j = 1:size(offi,2)
        offsets{i,j} = [offi(i,j) offj(i,j)];
    end
end


for it=1:iter
    it
    for i=1:size(offsets,1)
        for j=1:size(offsets,2)
            impatch = rgb2gray(targetim(i:i+winsize-1,j:j+winsize-1,:));
            offset = offsets{i,j};
            %if iter even do even prop
            if ~mod(iter,2) & i < size(offsets,1) & j < size(offsets,2)
                down = offsets{i+1, j};
                right = offsets{i,j+1};
                offsets{i,j} = propEven(impatch, greySrc, offset, down, right, winsize);
                
            elseif mod(iter,2)  & i>1 & j>1
                up = offsets{i-1,j};
                left = offsets{i,j-1};
                offsets{i,j} = propOdd(impatch, greySrc, offset, up, left, winsize);
            end
            
            randSearch(impatch, greySrc, offsets,i,j,winsize, offsets{i,j});
            
        end
    end
    
end

synthim = reconImg(offsets, winsize, sourceim);

end

function [image] = reconImg(offsets, winsize, sourceim)
image = zeros([size(offsets)+winsize-1, 3]);

for i=1:size(offsets,1)
    for j=1:size(offsets,2)
        coords = offsets{i,j};
        imi = coords(1);
        imj = coords(2);
        image(i:i+winsize-1,j:j+winsize-1,:) = image(i:i+winsize-1,j:j+winsize-1,:) + sourceim(imi:imi+winsize-1,imj:imj+winsize-1,:);
    end
end

image = image ./ (winsize^2);
imshow(image);

end

function offset = propOdd(impatch, greySrc, offset, down, right, winsize)
% compare each offset (offset, down, right) and see which best matches
% patch at i:i+win-1, j:j+win-1
currpatch = greySrc(offset(1):offset(1)+winsize-1,offset(2):offset(2)+winsize-1,:);
downpatch = greySrc(down(1):down(1)+winsize-1,down(2):down(2)+winsize-1,:);
rightpatch = greySrc(right(1):right(1)+winsize-1,right(2):right(2)+winsize-1,:);

dist = norm(currpatch-impatch);

if norm(downpatch-impatch) < dist
    dist = norm(downpatch-impatch);
    offset = down;
end
if norm(rightpatch-impatch) < dist
    dist = norm(rightpatch-impatch);
    offset = right;
end

end

function offset = propEven(impatch, greySrc, offset, up, left, winsize)
currpatch = greySrc(offset(1):offset(1)+winsize-1,offset(2):offset(2)+winsize-1,:);
uppatch = greySrc(up(1):up(1)+winsize-1,up(2):up(2)+winsize-1,:);
leftpatch = greySrc(left(1):left(1)+winsize-1,left(2):left(2)+winsize-1,:);

dist = norm(currpatch-impatch);

if norm(uppatch-impatch) < dist
    dist = norm(uppatch-impatch);
    offset = up;
end
if norm(leftpatch-impatch) < dist
    dist = norm(leftpatch-impatch);
    offset = left;
end

end

function [offset] = randSearch(impatch, greySrc, offsets,i,j,winsize, offset)
iter = 0;
w = min(size(offsets));

r = w*.5^iter;

offcoords = [i,j];
while r > 1
    while offcoords == [i,j]
        r = round(r);
        ri = randi([-r r]);
        rj = randi([-r r]);
        offcoords = [i+ri,j+rj];
        offcoords(1) = min(max(1,offcoords(1)),size(offsets,1));
        offcoords(2) = min(max(1,offcoords(2)),size(offsets,2));
    end
    
    i = offcoords(1);
    j = offcoords(2);
    
    cand = offsets{offcoords(1),offcoords(2)};
    
    currpatch = greySrc(offset(1):offset(1)+winsize-1,offset(2):offset(2)+winsize-1,:);
    dist = norm(currpatch - impatch);
    
    candidate = greySrc(cand(1):cand(1)+winsize-1,cand(2):cand(2)+winsize-1,:);
    
    if norm(candidate-impatch) < dist
        offset = cand;
    end
    
    iter = iter+1;
    r = w*.5^i;

end
end


