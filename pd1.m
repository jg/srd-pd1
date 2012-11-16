function pd1()

% parametry modelu
global alfa beta gamma N;
N = 10; % liczba etapów
alfa = 0.001;
beta = 1;
gamma = 0.01;

etapy = N:-1:1;
stany = 5000:5000:50000; % saldo na koncie na pocz¹tku etapu
sterowania = 0:0.01:1; % procentowy udzia³ operacji walutowych w etapie k
zaklocenia  = [0.9 0.1; 1 0.1; 1.2 0.3; 1.4 0.05; 1.6 0.08; 1.8 0.08; 2 0.08; 2.2 0.08; 2.4 0.08; 2.6 0.08]; % pary: (zak³ócenie, prawdopodobienstwo zaklocenia)

Jd = zeros(N+1,1); % wskazniki jakosci dla etapow
Ud = zeros(N,1); % sterowania dla etapow

for k = etapy  
  for x = stany    
    for u = sterowania      
      J = 0;
      for w = zaklocenia        
        % stan_nastepny = f(x, w, k);
        J = J + w(2) * (g(x, u, w(1)) + Jd(k+1));
      end
      
      if J >= Jd(k)         
        Jd(k) = J; Ud(k) = u;
      end
      
    end
  end
end


end


function y = g(x, u, w)
global alfa beta;

y = alfa * x^2 - beta * u^2;
end

function y = f(x, w, k)
global gamma;

y = u * w * x + (1 - u) * (1 + gamma) * x;
end
