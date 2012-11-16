function pd1()


global alfa beta gamma N x0 NS; % parametry modelu
N = 10; % liczba etapów
NS = 80; % liczba symulacji
x0 = 5000; % poczatkowy stan konta
alfa = 0.1;
beta = 0.000001;
gamma = 0.05;

etapy = N:-1:1;
stany = 5000:5000:50000; % saldo na koncie na pocz¹tku etapu
sterowania = 0:0.01:1; % procentowy udzia³ operacji walutowych w etapie k
zaklocenia  = [0.9 0.1;1 0.1; 1.2 0.3; 1.4 0.02; 1.6 0.08; 1.8 0.08; 2 0.08; 2.2 0.08; 2.4 0.08; 2.6 0.08]'; % pary: (zak³ócenie, prawdopodobienstwo zaklocenia)

Jd = zeros(N+1, length(stany)); % optymalne wskazniki jakosci dla etapow i stanów
Ud = zeros(N, length(stany)); % optymalne sterowania dla etapow i stanów

for k = etapy  
  for x = stany    
    xi = indeks_stanu(stany, x);
    for u = sterowania      
      J = 0;
      for w = zaklocenia        
        % stan_nastepny = f(x, w, k);        
        J = J + w(2) * (g(x, u, w(1)) + Jd(k+1, xi));
      end
      
      if J >= Jd(k, xi)         
        Jd(k, xi) = J; 
        Ud(k, xi) = u;        
      end
      
    end
  end
end

Jd
Ud

% symulacja

Js = [];
for s = 1:NS
  X = [x0];
  U = [];
  J = 0;  
  for k = 1:N
    x = X(end);        
    u = Ud(k, indeks_stanu(stany, x));
    w = losowe_zaklocenie(zaklocenia)
    
    X = [X; f(x, u, w)];
    U = [U; u];
    J = J + g(x, u, w);
  end
  Js = [Js; J];
  
end

disp('Sredni wskaznik jakosci wszystkich symulacji');
Jsr = sum(Js) / numel(Js)
disp('Wartosc oczekiwana optymalizacji');
Jd(1, indeks_stanu(stany, x0))
disp('Blad miedzy wartoscia oczekiwana z optymalizacji i symulacji (w %)');
blad = abs((1-Jsr/Jd(1,indeks_stanu(stany, x0))))


% Optymalna polityka
%figure(1);
%surf(Jd(1:N,:))
% Wykres regul decyzyjnych
%figure(2);
%plot(1:length(stany), Ud(:,1:length(stany)))
Jsrch = [];          % Wskaznik jakosci dla kazdej serii symulacji
for i = 1:NS
    Jsrch = [Jsrch; sum(Js(1:i)/i)];
end
plot(1:numel(Jsrch), Jsrch);
% plot(1:numel(Js), Js);

end


function y = losowe_zaklocenie(zaklocenia)
% Wyznaczamy zaklocenie
P = rand;
p = 0;
i = 0;
while p < P
  i = i + 1;
  p = p + zaklocenia(2, i);
end

y = zaklocenia(1, i);
end


function y = indeks_stanu(stany, x)
[val, y] = min(abs(stany - x));
if y > length(stany)
  y = length(stany)
end
end

function y = g(x, u, w)
global alfa beta;
y = alfa * x^2 - beta * u^2;
end

function y = f(x, u, w)
global gamma;
y = u * w * x + (1 - u) * (1 + gamma) * x;
end
