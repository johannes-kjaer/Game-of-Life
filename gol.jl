



n, m = 10, 10 # Game board dimensions
GameBoard = zeros(Int8, n ,m)
initial = [0 0 0 0 0 0 0 0 0 0;
           0 0 0 0 0 0 0 0 0 0;
           0 0 0 0 0 0 0 0 0 0;
           0 0 0 0 1 0 0 0 0 0;
           0 0 0 0 1 1 1 0 0 0;
           0 0 0 0 1 0 0 0 0 0;
           0 0 0 0 0 0 0 0 0 0;
           0 0 0 0 0 0 0 0 0 0;
           0 0 0 0 0 0 0 0 0 0;
           0 0 0 0 0 0 0 0 0 0;]


function convolution(arry::Array, n::Int64, m::Int64, kernel::Array)
    paddedArry = zeros(Int8, n+2,m+2)
    paddedArry[2:end-1,2:end-1] = arry
    #print(paddedArry)

    convBoard = zeros(Int8, n, m)
    for i = 1:n
        for j = 1:m
            convBoard[i,j] = sum(paddedArry[i:i+2,j:j+2] .* kernel)
        end
    end
    #print("Convolved board: ")
    #display(convBoard)
    return convBoard
end

function updateBoard(GameBoard::Array, n::Int64, m::Int64)
    ######### The Rules of the Game ########
    # 1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
    # 2. Any live cell with two or three live neighbours lives on to the next generation.
    # 3. Any live cell with more than three live neighbours dies, as if by overpopulation.
    # 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.


    # Count neighbours of all cells
    neighbourCount = convolution(GameBoard, n, m, [1 1 1; 1 0 1; 1 1 1])
   
    # 1. Find all cells with less than two neighbours
    lonely = neighbourCount .< 2
    #print("Lonely:")
    #display(lonely)

    # 4. Find all the cells with exactly three surrounding live cells
    revive = neighbourCount .== 3
    #print("Revive:")
    #display(revive)

    # 2. Find all cells with two or three neighbours
    survive = (neighbourCount .== 2) .+ revive
    #print("Survive:")
    #display(survive)

    # 3. Find all cells with more than three live neighbours
    suffocate = neighbourCount .> 3 
    #print("Suffocate")
    #display(suffocate)

    newBoard = GameBoard - lonely - suffocate + revive
    newBoard[newBoard .< 0] .= 0
    newBoard[newBoard .> 0] .= 1
    return newBoard
end

b = initial
for i = 1:10
    global b = updateBoard(b, 10 ,10)
    display(b)
end

#print(convolution([1 2 3; 4 5 6], 2, 3, [1 1 1; 1 1 1; 1 1 1]))