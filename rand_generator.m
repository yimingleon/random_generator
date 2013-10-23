% This function is written to generate a random number for any given analytical function
% it can draw n=number random number which follows the PDF of @myfun, range from xmin to xmax.
% notice that the function @myfun is arbitrary over a constant. It doens't necessarily normalised.
% Yiming Hu, Feb, 2013
 function [random_vector] = rand_generator(myfun,xmin,xmax,number,mode_switch)

% fun is the analytical expression of the function
% xmin is the lower boundary of the generator
% xmax is the upper boundary of the generator
% number is the needed sample numbers for this generation.

if nargin <= 3
	disp(['need to specify some inputs!'])
 	disp(['function [random_vector] = rand_generator(fun,xmin,xmax,number)'])
	disp([' fun is the analytical expression of the functiondisp'])
	disp([' xmin is the lower boundary of the generatordisp'])
	disp([' xmax is the upper boundary of the generatordisp'])
	disp([' number is the needed sample numbers for this generation.'])
	%disp([' nbin is the number for how many bins you want for histogram.'])
	disp(['==================================================='])
	disp(['Here gives a Gaussian distribution as an example'])
	myfun = @(x)exp(-1/2*x.^2);
	xmin = -5;
	xmax = 5;
	number = 100;
	mode_switch = 'fast';
else if nargin == 4
       mode_switch = 'fast';	
       end
end

if (~strcmp(mode_switch,'fast') && ~strcmp(mode_switch,'slow'))
	disp('Error! the final argument should be either ''slow'' or ''fast''')
	return
end

nbin = 10;

if (strcmp(mode_switch,'fast'))
	sample_number = min(max(number,100),1000);
	% to make sure that the x-axis is dense enough
	method = 'linear';
else 
	sample_number = min(max(10,number),min((xmax-xmin)*10,10000));
	method = 'spline';
end
x = linspace(xmin,xmax,sample_number);

mypdf = myfun(x);

if (find(mypdf<0))
	% which means that for some x, there are some negative pdf(x) value, this means the input file is not a probability function.
	disp(sprintf('ERROR!!!!! \nThe input function is not a probability function!\nIt contains negative value!'));
	return;
end
Normalisation = sum(mypdf);
pdfNormalise=Normalisation*(x(2)-x(1));

mycdf = cumsum(mypdf)/Normalisation;
%cumulative add up the probalibity distribution funtion.

tail = length(mycdf);
head = 1;
flag_t = 0;
flag_h = 0;
while ((mycdf(tail)-mycdf(tail-10)) < 1e-4)
	tail = tail-10;
	flag_t = 1;
end

while(mycdf(head+10)-mycdf(head) < 1e-4)
	head = head+10;
	flag_h = 1;
end

if(flag_t) 
	xmax = x(tail);
	disp(['xmax has been rescaled to ' num2str(xmax)]);
	mycdf(tail+1:length(mycdf)) = [];
	mypdf(tail+1:length(mypdf)) = [];
	x(tail+1:length(x)) = [];
end

if(flag_h) 
	xmin = x(head);
	disp(['xmin has been rescaled to ' num2str(xmin)]);
	mycdf(1:head) = [];
	mypdf(1:head) = [];
	x(1:head) = [];
end

if(flag_t || flag_h)
	mycdf = mycdf/(mycdf(length(mycdf))-mycdf(1));
end

x = linspace(xmin,xmax,sample_number);
mypdf = myfun(x);
Normalisation = sum(mypdf);
pdfNormalise=Normalisation*(x(2)-x(1));
mycdf = cumsum(mypdf)/Normalisation;
	
x_step = ((xmax-xmin)/nbin);
% use interpolation to get the corresponding value for a uniform random number
	
%end

onepercent = floor(number/100);

%random_vector = x;
%save data.mat
%return 

for i=1:number
	xi = rand;
	random_vector(i)= interp1(mycdf,x,xi,method);
	if (~mod(i,onepercent))
		fprintf('=');
	end
end
fprintf('\n');
[n,xout]=hist(random_vector,xmin+x_step/2:x_step:xmax+x_step/2);
bar(xout,n/number),hold on
plot(x,mypdf/pdfNormalise*(xmax-xmin)/nbin),hold off

return
