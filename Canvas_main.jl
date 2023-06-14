using GLMakie

GLMakie.activate!(inline=false)

data = Observable(fill!(Matrix{Bool}(undef,30,30),true)) 

f, ax, im = heatmap(data, colormap = [:black, :white]; axis = (; aspect = 1,xzoomlock=true,yzoomlock=true), ) 

# added zoomlock for no scroll zooms in heatmap

########################################################
# define buttons 
########################################################

f[2, 1] = buttongrid = GridLayout(tellwidth = false)

button = buttongrid[1,1] = Button(f, label="reset")


on(button.clicks) do click
    data[] .= true
    #data[][1,1] = false
    notify(data)
end


########################################################
# styling
########################################################


hlines!(0.5:30.5, color = :gray50)
vlines!(0.5:30.5, color = :gray50)

hidedecorations!(ax)
hidexdecorations!(ax, ticks = false)
hideydecorations!(ax, ticks = false)

## The following is for highlighting the pixels you want

#x1,x2 = 2.06, 3.06
#y1,y2 = 1.06,1.06

#lines!([x1,x2],[y1,y2], color = :green)

#a,b = 6,7

#xs = [a-1.47,a-0.47,a-0.47,a-1.47,a-1.47]
#ys = [b-1.47,b-1.47, b-0.47 ,b-0.47,b-1.47]


#lines!(xs,ys, color = :green)

################################################################
# Axis interactions with mouse
################################################################
interacted_with = Set{Point2{Int}}()

register_interaction!(ax, :toggler) do event::MouseEvent, ax
    if event.type === MouseEventTypes.leftdown
        empty!(interacted_with)
    elseif event.type in (MouseEventTypes.leftclick, MouseEventTypes.leftdrag)
        index = round.(Int, event.data)
        #print(index)
        if typeof(index[1]) != Int 
            return
        end
        index in interacted_with && return
        push!(interacted_with, index)
        data[][index...] = !data[][index...]
        notify(data)
    end
end

## deactivate interaction for drag zoom
deactivate_interaction!(ax, :rectanglezoom,)

typeof(error) == NaN

# update rules
# data[] .= fn(...)
# notify(data)

display(f)

##to see all the interactions of ax (axis)

#interactions(ax) 