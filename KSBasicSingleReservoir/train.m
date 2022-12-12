function w_out = train(params, states, data)

beta = params.beta;

idenmat = beta*speye(params.N);

states(2:2:params.N,:) = states(2:2:params.N,:).^2; % only on half of the reservoir nodes (thus p1 & p2), 2944*70000
w_out = data*transpose(states)*pinv(states*transpose(states)+idenmat); % 64*2944