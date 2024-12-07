% ball_game.m
% Declare all global variables at the start
global ballX ballY ballZ ball radius score currentQuestion questionIndex questions answers correctWall txtBack txtRight txtBottom scoreText currentImageSet;

% Initialize image sets
imageSet1 = {'red_tile.png', 'Library_door_1.png', 'window.png'};
imageSet2 = {'Library_floor.png', 'Inner_door.png', 'Inner_wall.png'};
imageSet3 = {'Library_floor.png', 'Library_books.png', 'Library_window.png'};

% Initialize variables
ballX = 0;
ballY = 0;
ballZ = 0;
radius = 0.5;
score = 0;
questionIndex = 1;
currentImageSet = 1;  % Initialize image set counter

% Define questions and answers
questions = {
    'What is 5 + 3?',      % Question 1
    'What is 4 x 6?',      % Question 2
    'What is 15 - 7?',     % Question 3
    'What is 12 + 8?',     % Question 4
    'What is 7 x 5?',      % Question 5
    'What is 20 - 9?',     % Question 6
    'What is 16 + 7?',     % Question 7
    'What is 9 x 3?',      % Question 8
    'What is 30 - 13?'     % Question 9
};

% Each row contains [correct_answer, wrong_answer1, wrong_answer2]
answers = [
    8, 7, 9;              % Answers for Question 1
    24, 28, 22;           % Answers for Question 2
    8, 6, 10;             % Answers for Question 3
    20, 18, 22;           % Answers for Question 4
    35, 32, 38;           % Answers for Question 5
    11, 13, 9;            % Answers for Question 6
    23, 21, 25;           % Answers for Question 7
    27, 24, 30;           % Answers for Question 8
    17, 15, 19            % Answers for Question 9
];

% Define which wall will have the correct answer (1=XZ back, 2=YZ right, 3=XY bottom)
correctWall = [2, 1, 3, 1, 2, 3, 2, 1, 3];  % Corresponds to each question

% Create figure window
fig = figure('KeyPressFcn', @keyPress);
hold on;
axis([-10 10 -10 10 -10 10]);
grid on;

% Create the ball (sphere)
[X, Y, Z] = sphere(20);
ball = surf(radius * X + ballX, radius * Y + ballY, radius * Z + ballZ);
set(ball, 'FaceColor', 'red', 'EdgeColor', 'none');

% Set up the lighting
% light('Position', [5 5 10]);
% lightangle(-45, 45);
lighting flat;
axis square;
view(3);

% Add labels to the axes
xlabel('X-Axis (l,r)');
ylabel('Y-Axis (u, d)');
zlabel('Z-Axis (pu, pd)');

% Create text objects for answers
txtBack = text(0, 9, 0, '', 'FontSize', 20, 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', '#FFA500');
txtRight = text(9, 0, 0, '', 'FontSize', 20, 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', '#FFA500');
txtBottom = text(0, 0, -9, '', 'FontSize', 20, 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', '#FFA500');

% Create score display
scoreText = text(-9, -9, 9, sprintf('Score: %d', score), 'FontSize', 12);

% Initial game setup
updateWallTextures();
updateGame(true);

function updateWallTextures()
    global currentImageSet ball ballX ballY ballZ radius;
    
    % Get current image set
    if currentImageSet == 1
        currentImages = {'red_tile.png', 'Library_door_1.png', 'window.png'};
    elseif currentImageSet == 2
        currentImages = {'Library_floor.png', 'Inner_door.png', 'Inner_wall.png'};
    else
        currentImages = {'Library_floor.png', 'Library_books.png', 'Library_window.png'};
    end
    
    % Load current set of images
    img1 = imread(currentImages{1});
    img2 = imread(currentImages{2});
    img3 = imread(currentImages{3});
    
    % Delete existing walls if they exist
    delete(findobj(gca, 'Type', 'surface'));
    
    % Recreate walls with new textures
    [XX, YY] = meshgrid(-10:10, -10:10);
    surf(XX, YY, -10 * ones(21, 21), repmat(img1, [1 1]), 'FaceColor', 'texturemap', 'EdgeColor', 'none');

    [XX, ZZ] = meshgrid(-10:10, -10:10);
    surf(XX, 10 * ones(21, 21), ZZ, repmat(img2, [1 1]), 'FaceColor', 'texturemap', 'EdgeColor', 'none');

    [YY, ZZ] = meshgrid(-10:10, -10:10);
    surf(10 * ones(21, 21), YY, ZZ, repmat(img3, [1 1]), 'FaceColor', 'texturemap', 'EdgeColor', 'none');
    
    % Recreate the ball since we deleted all surfaces
    [X, Y, Z] = sphere(20);
    ball = surf(radius * X + ballX, radius * Y + ballY, radius * Z + ballZ);
    set(ball, 'FaceColor', 'red', 'EdgeColor', 'none');
end

function updateGame(newQuestion)
    global questionIndex questions answers correctWall txtBack txtRight txtBottom scoreText score currentImageSet;
    
    if newQuestion
        % Increment question index and handle wraparound
        questionIndex = questionIndex + 1;
        if questionIndex > length(questions)
            questionIndex = 1;
            currentImageSet = 1;
            updateWallTextures();
        elseif questionIndex == 4
            currentImageSet = 2;
            updateWallTextures();
        elseif questionIndex == 7
            currentImageSet = 3;
            updateWallTextures();
        end
    end
    
    % Update question display
    title(questions{questionIndex}, 'FontWeight', 'bold');
    
    % Distribute answers based on correctWall
    switch correctWall(questionIndex)
        case 1 % Back wall (XZ plane)
            set(txtBack, 'String', num2str(answers(questionIndex, 1)));
            set(txtRight, 'String', num2str(answers(questionIndex, 2)));
            set(txtBottom, 'String', num2str(answers(questionIndex, 3)));
        case 2 % Right wall (YZ plane)
            set(txtBack, 'String', num2str(answers(questionIndex, 2)));
            set(txtRight, 'String', num2str(answers(questionIndex, 1)));
            set(txtBottom, 'String', num2str(answers(questionIndex, 3)));
        case 3 % Bottom wall (XY plane)
            set(txtBack, 'String', num2str(answers(questionIndex, 2)));
            set(txtRight, 'String', num2str(answers(questionIndex, 3)));
            set(txtBottom, 'String', num2str(answers(questionIndex, 1)));
    end
    
    % Update score display
    set(scoreText, 'String', sprintf('Score: %d', score));
end

function keyPress(~, event)
    global ballX ballY ballZ ball radius score questionIndex correctWall;
    
    step = 0.5; % Movement step size
    
    % Update position based on key press
    switch event.Key
        case 'leftarrow'
            ballX = ballX - step;
        case 'rightarrow'
            ballX = ballX + step;
        case 'uparrow'
            ballY = ballY + step;
        case 'downarrow'
            ballY = ballY - step;
        case 'pageup'
            ballZ = ballZ + step;
        case 'pagedown'
            ballZ = ballZ - step;
        case 'r'
            resetBall();
            updateBallPosition();
            return; % Exit the function after resetting the ball
    end
    
    % Check for collisions with walls and handle answer checking
    correct = false;
    if abs(ballX) >= 9.5 && abs(ballY) < 1 && abs(ballZ) < 1  % Right wall (YZ)
        if correctWall(questionIndex) == 2
            correct = true;
            score = score + 1;
        end
        resetBall();
        if correct
            updateGame(true);
        end
    elseif abs(ballY) >= 9.5 && abs(ballX) < 1 && abs(ballZ) < 1  % Back wall (XZ)
        if correctWall(questionIndex) == 1
            correct = true;
            score = score + 1;
        end
        resetBall();
        if correct
            updateGame(true);
        end
    elseif abs(ballZ) >= 9.5 && abs(ballX) < 1 && abs(ballY) < 1  % Bottom wall (XY)
        if correctWall(questionIndex) == 3
            correct = true;
            score = score + 1;
        end
        resetBall();
        if correct
            updateGame(true);
        end
    end
    
    % Update ball position
    updateBallPosition();
    
    drawnow;
end

function resetBall()
    global ballX ballY ballZ;
    ballX = 0;
    ballY = 0;
    ballZ = 0;
end

function updateBallPosition()
    global ballX ballY ballZ ball radius;
    [X,Y,Z] = sphere(20);
    set(ball, 'XData', radius*X + ballX, ...
              'YData', radius*Y + ballY, ...
              'ZData', radius*Z + ballZ);
end