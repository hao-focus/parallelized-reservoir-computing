%start
for iters = 1:1
clear;
ModelParams.tau = 0.25; %% time step
ModelParams.nstep = 100000; % number of time steps to generate
ModelParams.N = 64;  %number of spatial grid points 
ModelParams.d = 22;  % periodicity length 
rng('shuffle') % 根据当前时间为随机数生成器提供种子 这样，rand、randi 和 randn
% 会在您每次调用 rng 时生成不同的数字序列。
init_cond = 0.6*(-1 + 2*rand(1,ModelParams.N)); %random initial condition
data = transpose(kursiv_solve(init_cond,ModelParams)); % 64*100000

measured_vars = 1:1:ModelParams.N; % 1*64
num_measured = length(measured_vars); % 64
measurements = data(measured_vars, :);% + z;

%%
%train reservoir
[num_inputs,~] = size(measurements); % 64
resparams.radius = 0.6; % spectral radius
resparams.degree = 3; % connection degree
approx_res_size = 3000; % reservoir size
resparams.N = floor(approx_res_size/num_inputs)*num_inputs; % actual reservoir size divisible by number of inputs # 2944
resparams.sigma = 0.5; % input weight scaling
resparams.train_length = 70000; % number of points used to train
resparams.num_inputs = num_inputs; 
resparams.predict_length = 2000; % number of predictions after training
resparams.beta = 0.0001; %regularization parameter

[x, H, A, win] = train_reservoir(resparams, measurements(:, 1:resparams.train_length));

[output,~] = predict(A,win,resparams,x,H); % x: states, H: Wout, output, 64*2000
%%
figure()
lambda_max = 0.05; %(max lyapunov exponent for ks model parameter d = 22)
t = (1:1:resparams.predict_length)*ModelParams.tau*lambda_max;
s = (1:1:ModelParams.N).*60/128;

subplot(3,1,1)
imagesc(t,s,data(:,resparams.train_length+1:resparams.train_length + resparams.predict_length))
title('Actual')
xlabel('$$\Lambda_{max}t$$', 'Interpreter', 'Latex')
xlim([0, 20])
colorbar;
subplot(3,1,2)
imagesc(t,s,output)
title('Prediction')
xlabel('$$\Lambda_{max}t$$', 'Interpreter', 'Latex')
xlim([0, 20])
colorbar;
caxis(3*[-1,1])
subplot(3,1,3)
imagesc(t,s,data(:,resparams.train_length+1:resparams.train_length + resparams.predict_length) - output)
title('Error')
xlabel('$$\Lambda_{max}t$$', 'Interpreter', 'Latex')
caxis(3*[-1,1])
colorbar;
xlim([0, 20])
colormap('jet')

end