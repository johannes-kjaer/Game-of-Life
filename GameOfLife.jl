using Plots

n, m = 100, 100 # Game board dimensions
T = 1000 # time steps


GameBoard = zeros(Int8, n ,m)
GameBoard[CartesianIndex.([44,45,46,45,45,46,47, 15,16,17,16,16,15],[44,44,44,46,47,45,45, 69,69,69,71,72,72])] .= 1



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

function updateBoard(GameBoard::Array)
    ######### The Rules of the Game ########
    # 1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
    # 2. Any live cell with two or three live neighbours lives on to the next generation.
    # 3. Any live cell with more than three live neighbours dies, as if by overpopulation.
    # 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

    (n,m) = size(GameBoard)

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
    #survive = (neighbourCount .== 2) .+ revive # This one is superfluous, but left here for completeness
    #print("Survive:")
    #display(survive)

    # 3. Find all cells with more than three live neighbours
    suffocate = neighbourCount .> 3 
    #print("Suffocate")
    #display(suffocate)

    newBoard = GameBoard - lonely - suffocate + revive
    newBoard[newBoard .< 0] .= 0
    newBoard[newBoard .> 0] .= 1
    return (newBoard .> 0)
end


p = heatmap(title="Conway's Game of Life", colorbar=false, legend=false, grid=true)

for i = 1:T
    global GameBoard = updateBoard(GameBoard)
    heatmap!(p, GameBoard)
    display(p)
end






####### Plotting #######
using GLMakie

# Create a figure and axis
f = Figure()
ax = Axis(f[1, 1]) #, aspect = 1, title = "Conway's Game of Life")

# Create a heatmap for the board

p = heatmap!(ax, 1:n, 1:m, GameBoard, colormap = [:white, :black])

display(p)

## Function to update the visualization
#function update_plot!(GameBoard, p)
#    p[3] = GameBoard  # Update the heatmap data
#    notify(p)     # Notify Makie to update the plot
#end
#
## Animation loop
#running = Ref(true)
#function simulate()
#    while running[]
#        GameBoard = updateBoard(GameBoard)
#        update_plot!(GameBoard, p)
#        sleep(0.1)  # Control simulation speed
#        yield()     # Allow other tasks to run
#    end
#end
#
## Start the simulation in a separate task
#sim_task = @task simulate()
#schedule(sim_task)
#
## Pause/Resume toggle
#on(events(f).keyboardbutton) do event
#    if event.key == Keyboard.space
#        running[] = !running[]
#        if running[]
#            schedule(sim_task)  # Resume
#        end
#    end
#end
#
## Display the figure
#display(f)