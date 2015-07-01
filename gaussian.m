
    function y = gaussian(t, sigma, mu)

    if nargin<3
       mu = 0;
    end


    y = (1/(sqrt(2*pi)*sigma)) .* exp( - ((t-mu)/sigma).^2/2 );

