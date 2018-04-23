function rgb = solarized(m)
% solarized(m) returns an mx3 color map of level intensity.
% Implements a solarized color map by linear interpolation
% if m>8, or subsampling if m<=8; from the
% eight colors at http://ethanschoonover.com/solarized
% AJ Roberts, 24 May 2013
%{
$base03:    #002b36;
$base02:    #073642;
$base01:    #586e75;
$base00:    #657b83;
$base0:     #839496;
$base1:     #93a1a1;
$base2:     #eee8d5;
$base3:     #fdf6e3;
$violet:    #6c71c4;
$blue:      #268bd2;
$cyan:      #2aa198;
$green:     #859900;
$yellow:    #b58900;
$orange:    #cb4b16;
$red:       #dc322f;
$magenta:   #d33682;
%}
% Form rgb values
dec=hex2dec([
'6c71c4'
'268bd2'
'2aa198'
'859900'
'b58900'
'cb4b16'
'dc322f'
'd33682'
    ]);
rgb=[floor(dec/256^2) mod(floor(dec/256),256) mod(dec,256)];
rgb=rgb/256;
% depending upon input m
if nargin==0, m=8; end
if m<=8 % choose subset of colors
    j=[2 4 7 3 6 8 5 1];
    j=sort(j(1:m));
    rgb=rgb(j,:);
else % linearly interpolate across spectrum
    %c=8*(1:m)'/m;
    c=1+7*(0:m-1)'/(m-1);
    i=floor(c); f=c-i; j=i+1;
    i=mod(i-1,8)+1; j=mod(j-1,8)+1;
    rgb=(1-[f,f,f]).*rgb(i,:)+[f,f,f].*rgb(j,:);
end
