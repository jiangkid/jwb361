function ymat = LPCfilter(E,A,ex,win,overlap)

hop = win/overlap;
nsamp = size(A,1)*hop + win;
r = nsamp/length(ex);

t = [1:size(A,1)];
ti = [1:r:size(A,1)];

%E = interp1(t,E,ti,'nearest');
%A = interp1(t,A,ti,'nearest');

%interpolation is done on the poles (not the filter coefficients)
E = interp1(t,E,ti);
r = zeros(size(A,1),size(A,2)-1);
for i = 1:size(A,1),
rtmp = roots(A(i,:));
[tmp,itmp] = sort(angle(rtmp));
r(i,:) = rtmp(itmp);
end
r = interp1(t,r,ti);
for i = 1:size(r,1),
    A(i,:) = poly(r(i,:));    
end


% buffer the excitation (with no tapering)
exmat =  buffer(ex,win,win-hop);
%winmat = hanning(320)*ones(1,size(exmat,2));
%exmat = exmat.*winmat;

% Source - filter (convolve the pulsetrain with the filters)
ymat = zeros(size(exmat));
for i = 1:size(A,1),
ymat(:,i) = filter(E(i),A(i,:),exmat(:,i));
end
ymat = real(ymat);
