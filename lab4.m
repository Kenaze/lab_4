clc;
clear;
close all;

%% Лабораторная работа № 4. Поиск контуров на изображении
% MATLAB R2024a
%
% Перед запуском укажите имена файлов своего варианта.
% Файлы удобно положить в одну папку с этим скриптом.
jpgFile = 'Variant_07_04.jpg';
gifFile = 'Variant_07_04.gif';

%% Проверка входных файлов
if ~isfile(jpgFile)
    error('Не найден JPG-файл: %s. Укажите имя файла своего варианта в переменной jpgFile.', jpgFile);
end

if ~isfile(gifFile)
    error('Не найден GIF-файл: %s. Укажите имя файла своего варианта в переменной gifFile.', gifFile);
end

fprintf('Лабораторная работа № 4. Поиск контуров на изображении\n');
fprintf('JPG-файл: %s\n', jpgFile);
fprintf('GIF-файл: %s\n\n', gifFile);

%% Задание 1. JPG-изображение и линейные фильтры выделения контуров
Ijpg = imread(jpgFile);

% Для вычисления контуров используем полутоновое изображение.
if ndims(Ijpg) == 3
    IjpgGray = rgb2gray(Ijpg);
else
    IjpgGray = Ijpg;
end

IjpgDouble = im2double(IjpgGray);

figure;
imshow(Ijpg);
title(sprintf('Исходное JPG-изображение: %s', jpgFile), 'Interpreter', 'none');

fprintf('Размер JPG-изображения: %d x %d пикселей\n', ...
    size(IjpgGray, 2), size(IjpgGray, 1));
fprintf('Класс полутонового JPG-изображения: %s\n\n', class(IjpgGray));

% Маски из задания лабораторной работы № 4.
% Первые две маски — операторы Собеля.
H1 = [ 1  2  1;
       0  0  0;
      -1 -2 -1];

H2 = [-1  0  1;
      -2  0  2;
      -1  0  1];

% Направленные маски H5-H12.
H5 = [ 1  1  1;
       1 -2  1;
      -1 -1 -1];

H6 = [ 1  1  1;
      -1 -2  1;
      -1 -1  1];

H7 = [-1  1  1;
      -1 -2  1;
      -1  1  1];

H8 = [-1 -1  1;
      -1 -2  1;
       1  1  1];

H9 = [-1 -1 -1;
       1 -2  1;
       1  1  1];

H10 = [ 1 -1 -1;
        1 -2 -1;
        1  1  1];

H11 = [ 1  1 -1;
        1 -2 -1;
        1  1 -1];

H12 = [ 1  1  1;
       -1 -2 -1;
       -1 -1 -1];

% Маски повышения резкости с наложением исходного изображения на контур.
H16 = [ 0 -1  0;
       -1  5 -1;
        0 -1  0];

H17 = [-1 -1 -1;
       -1  9 -1;
       -1 -1 -1];

H18 = [ 1 -2  1;
       -2  5 -2;
        1 -2  1];

filters = {H1, H2, H5, H6, H7, H8, H9, H10, H11, H12, H16, H17, H18};
filterNames = { ...
    'H1 — Собель, горизонтальные перепады', ...
    'H2 — Собель, вертикальные перепады', ...
    'H5 — направление «север»', ...
    'H6 — направление «северо-восток»', ...
    'H7 — направление «восток»', ...
    'H8 — направление «юго-восток»', ...
    'H9 — направление «юг»', ...
    'H10 — направление «юго-запад»', ...
    'H11 — направление «запад»', ...
    'H12 — направление «северо-запад»', ...
    'H16 — Лаплас + исходное изображение', ...
    'H17 — Лаплас + исходное изображение', ...
    'H18 — Лаплас + исходное изображение'};

for k = 1:numel(filters)
    response = imfilter(IjpgDouble, filters{k}, 'replicate', 'conv');

    % Для H1-H12 присутствуют положительные и отрицательные отклики.
    % abs(...) позволяет показать силу перепада независимо от знака.
    % Для H16-H18 показываем сам результат после нормировки.
    if k <= 10
        shown = mat2gray(abs(response));
    else
        shown = mat2gray(response);
    end

    figure;
    imshow(shown);
    title(filterNames{k});
end

%% Задание 2. GIF-изображение и функция edge
% GIF часто является индексированным изображением, поэтому считываем и карту цветов.
[Xgif, mapGif] = imread(gifFile);

if ~isempty(mapGif)
    IgifGray = ind2gray(Xgif, mapGif);
else
    if ndims(Xgif) == 3
        IgifGray = im2double(rgb2gray(Xgif));
    else
        IgifGray = im2double(Xgif);
    end
end

figure;
imshow(IgifGray, []);
title(sprintf('Исходное GIF-изображение: %s', gifFile), 'Interpreter', 'none');

fprintf('Размер GIF-изображения: %d x %d пикселей\n', ...
    size(IgifGray, 2), size(IgifGray, 1));

% Все методы edge, рассмотренные в лабораторной работе.
[BW_sobel, threshSobel]     = edge(IgifGray, 'sobel');
[BW_prewitt, threshPrewitt] = edge(IgifGray, 'prewitt');
[BW_roberts, threshRoberts] = edge(IgifGray, 'roberts');
[BW_log, threshLog]         = edge(IgifGray, 'log');

% Для zerocross задаём фильтр Лапласа-Гаусса.
sigmaZero = 2;
nZero = ceil(sigmaZero * 3) * 2 + 1;
hZero = fspecial('log', nZero, sigmaZero);
[BW_zerocross, threshZero] = edge(IgifGray, 'zerocross', [], hZero);

[BW_canny, threshCanny] = edge(IgifGray, 'canny');

figure;
imshow(BW_sobel);
title('Границы методом Sobel');

figure;
imshow(BW_prewitt);
title('Границы методом Prewitt');

figure;
imshow(BW_roberts);
title('Границы методом Roberts');

figure;
imshow(BW_log);
title('Границы методом LoG');

figure;
imshow(BW_zerocross);
title('Границы методом Zerocross');

figure;
imshow(BW_canny);
title('Границы методом Canny');

%% Текстовые результаты для отчёта
fprintf('\nАвтоматически выбранные пороги функции edge:\n');
fprintf('Sobel:      %.6f\n', threshSobel);
fprintf('Prewitt:    %.6f\n', threshPrewitt);
fprintf('Roberts:    %.6f\n', threshRoberts);
fprintf('LoG:        %.6f\n', threshLog);
fprintf('Zerocross:  %.6f\n', threshZero);

if numel(threshCanny) == 2
    fprintf('Canny:      [%.6f %.6f]\n', threshCanny(1), threshCanny(2));
else
    fprintf('Canny:      %.6f\n', threshCanny);
end

fprintf('\nЧисло граничных пикселей:\n');
fprintf('Sobel:      %d\n', nnz(BW_sobel));
fprintf('Prewitt:    %d\n', nnz(BW_prewitt));
fprintf('Roberts:    %d\n', nnz(BW_roberts));
fprintf('LoG:        %d\n', nnz(BW_log));
fprintf('Zerocross:  %d\n', nnz(BW_zerocross));
fprintf('Canny:      %d\n', nnz(BW_canny));

fprintf('\nИнформация о переменных скрипта:\n');
whos
