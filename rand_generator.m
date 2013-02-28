% This function is written to generate a random number for any given analytical function
% it can draw n=number random number which follows the PDF of @myfun, range from xmin to xmax.
% notice that the function @myfun is arbitrary over a constant. It doens't necessarily normalised.
% Yiming Hu, Feb, 2013
 function [random_vector] = rand_generator(myfun,xmin,xmax,number)

% fun is the analytical expression of the function
% xmin is the lower boundary of the generator
% xmax is the upper boundary of the generator
% number is the needed sample numbers for this generation.

if nargin == 0
	disp(['need to specify some inputs!'])
 	disp(['function [random_vector] = rand_generator(fun,xmin,xmax,number)'])
	disp([' fun is the analytical expression of the functiondisp'])
	disp([' xmin is the lower boundary of the generatordisp'])
	disp([' xmax is the upper boundary of the generatordisp'])
	disp([' number is the needed sample numbers for this generation.'])
	disp(['==================================================='])
	disp(['Here gives a Gaussian distribution as an example'])
	myfun = @(x)exp(-1/2*x.^2);
	xmin = -5;
	xmax = 5;
	number = 100;
end

x = linspace(xmin,xmax,10*number);
% to make sure that the x-axis is dense enough

mypdf = myfun(x);
Normalisation = sum(mypdf);

mycdf = cumsum(mypdf)/Normalisation;
%cumulative add up the probalibity distribution funtion.

% use interpolation to get the corresponding value for a uniform random number
for i=1:number
	xi = rand;
	random_vector(i)= interp1(mycdf,x,xi,'spline');
end

[n,xout]=hist(random_vector,xmin:((xmax-xmin)/number*10):xmax);
bar(xout,n/number),hold on
plot(x,mypdf/Normalisation/(xmax-xmin)*number*10),hold off

return
