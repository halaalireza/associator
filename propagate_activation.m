function L = propagate_activation(L, W, P, mode, input)

if strcmp(mode, 'S')
    L(1).state = input; % SI
    L(2).state = P.transferfn(L(1).state * W(1).state + randomnoise(P.noise(1), [1, L(2).size]), P.T); % SH
    L(3).state = P.transferfn(L(2).state * W(2).state + randomnoise(P.noise(1), [1, L(3).size]), P.T); % SO
end
if strcmp(mode, 'P')
    L(4).state = input; % PI
    L(5).state = P.transferfn(L(4).state * W(3).state + randomnoise(P.noise(2), [1, L(5).size]), P.T); % PH
    L(6).state = P.transferfn(L(5).state * W(4).state + randomnoise(P.noise(2), [1, L(6).size]), P.T); % PO
end
if strcmp(mode, 'R')
    L(1).state = input; % SI
    L(2).state = P.transferfn(L(1).state * W(1).state + randomnoise(P.noise(1), [1, L(2).size]), P.T); % SH
    L(7).state = P.transferfn(L(2).state * W(5).state + randomnoise(P.noise(3), [1, L(7).size]), P.T); % AR from SH
    L(5).state = P.transferfn(L(7).state * W(6).state + randomnoise(P.noise(3), [1, L(5).size]), P.T); % PH from AR
    L(6).state = P.transferfn(L(5).state * W(4).state + randomnoise(P.noise(2), [1, L(6).size]), P.T); % PO
end
if strcmp(mode, 'L')
    L(4).state = input; % PI
    L(5).state = P.transferfn(L(4).state * W(3).state + randomnoise(P.noise(2), [1, L(5).size]), P.T); % PH
    L(8).state = P.transferfn(L(5).state * W(7).state + randomnoise(P.noise(4), [1, L(8).size]), P.T); % AL from PH
    L(2).state = P.transferfn(L(8).state * W(8).state + randomnoise(P.noise(4), [1, L(2).size]), P.T); % SH from AL
    L(3).state = P.transferfn(L(2).state * W(2).state + randomnoise(P.noise(1), [1, L(3).size]), P.T); % SO
end





