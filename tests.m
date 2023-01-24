function my_tests()
% calcul des descripteurs de Fourier de la base de données
img_db_path = './db/';
img_db_list = glob([img_db_path, '*.gif']);
img_db = cell(1);
label_db = cell(1);
fd_db = cell(1);
for im = 1:numel(img_db_list)
    img_db{im} = logical(imread(img_db_list{im}));
    label_db{im} = get_label(img_db_list{im});
    disp(label_db{im});
    [fd_db{im}, ~, ~, ~] = compute_fd(img_db{im});
end

% importation des images de requête dans une liste
img_path = './dbq/';
img_list = glob([img_path, '*.gif']);
t = tic(); %#ok<NASGU> % Inutile ?

% pour chaque image de la liste...
for im = 1:numel(img_list)

    % calcul du descripteur de Fourier de l'image
    img = logical(imread(img_list{im}));
    [fd, r, m, poly] = compute_fd(img);

    % calcul et tri des scores de distance aux descripteurs de la base
    for i = 1:length(fd_db)
        scores(i) = norm(fd-fd_db{i}); %#ok<*AGROW>
    end
    [scores, I] = sort(scores);

    % affichage des résultats
    close all;
    figure(1);
    top = 5; % taille du top-rank affiché
    subplot(2, top, 1);
    imshow(img); hold on;
    plot(m(1), m(2), '+b'); % affichage du barycentre
    plot(poly(:, 1), poly(:, 2), 'v-g', 'MarkerSize', 1, 'LineWidth', 1); % affichage du contour calculé
    subplot(2, top, 2:top);
    plot(r); % affichage du profil de forme
    for i = 1:top
        subplot(2, top, top + i);
        imshow(img_db{I(i)}); % affichage des top plus proches images
    end
    drawnow();
    waitforbuttonpress();
end
end

function [fd, r, m, poly] = compute_fd(img)
N = 256; % N valeurs d'un angle t.
M = 32; % M premiers coefficients du vecteur |R(f)|/|R(0)|.
h = size(img, 1); % Hauteur de l'image, nombre de lignes.
w = size(img, 2); % Largeur de l'image, nombre de colonnes.
m = calcul_barycentre(img, h, w); % Barycentre de l'image.
t = linspace(0, 2 * pi, N); % Génération des angles à parcourir.
poly = calcul_contours(img, m, t); % Contours de l'image.
r = pdist2(m, poly); % Calcul du profil de la forme.
fd = calcul_descripteur(r, M);
end

% Calcul du barycentre d'une image.
function m = calcul_barycentre(img, h, w)
x = 0;
y = 0;
cpt = 0;
% On parcourt la matrice de l'image.
for i = 1 : h
    for j = 1 : w
        % Si le pixel est blanc .
        if img(i, j)
            % On ajoute les coordonnées à x et y et on incrémente le
            % compteur.
            x = x + j;
            y = y + i;
            cpt = cpt + 1;
        end
    end
end
% On créé le vecteur ligne de taille 2.
m = round([x, y] / cpt);
end

% Calcul des contours de la forme.
function poly = calcul_contours(img, m, t)
ym = m(1);
xm = m(2);
poly = []; % Tableau des points d'intersections, initialisé vide.

% Boucle sur les angles
for i = 1:length(t)
    angle = t(i);
    % Initialisation de x et y aux coordonnées du barycentre.
    x = xm;
    y = ym;
    % Boucle de détection des points formant le contours.
    while (round(x) < size(img, 1) && round(y) < size(img, 2) && round(x) > 0 && round(y) > 0 && img(round(x), round(y)))
        x = x + cos(angle);
        y = y + sin(angle);
    end
    poly = [poly; y, x]; % Ajout du point à la forme.
end
end

% Calcul du descripteur de fourrier.
function fd = calcul_descripteur(r, M)
R = fft(r);
vecteur = abs(R)/abs(R(1));
fd = vecteur(1:M);
end