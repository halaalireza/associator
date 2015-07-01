i1 = [1 0 0; 0 1 0];
i2 = [1 0 0 1; 0 1 1 0];
w = zeros(ncols(i1),ncols(i2));
LR = 0.1;

%%

for epoch = 1:10000
    
    % train for one epoch
    for i = 1:nrows(i1)
        w = Hebbian(i1(i,:), i2(i,:), w, LR);
        w = normbyrowmax(w);
    end
    
    % test for the whole training set
    o = NaN(size(i2));
    for i = 1:nrows(i1)
        o(i,:) = i1(i,:) * w;
    end
    
end

imagesc(w)
o


