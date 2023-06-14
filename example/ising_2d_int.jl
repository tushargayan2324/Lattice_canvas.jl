function mod_new(n,N)
    if n == 0
        return 1
    elseif n%N == 0
        return n
    else
        return n%N
    end
end

function energy(M)
    J = -0.01
    N = size(M)[1]

    E = 0

    for i=1:N
        for j=i:N
            #s = M[i,j]
            E += -M[i,j]*(M[mod_new(i+1,N),j] + M[i,mod_new(j+1,N)] + M[mod_new(i-1,N),j] + M[i,mod_new(j-1,N)]-1)  #neighbour(M,(i,j))
        end
    end

    return E
end

function neighbour(M,(a,b))
    N = size(M)[1]
    return M[mod_new(a+1,N),b] + M[a,mod_new(b+1,N)] + M[mod_new(a-1,N),b] + M[a,mod_new(b-1,N)]
end

function magnetization(M)
    m = 0
    len_lat = size(M)[1]
    for i=1:len_lat
        for j=1:len_lat
            m+=M[i,j]
        end
    end
    return abs(m)
end

function minimum_ele(M)
    if M[1] > M[2]
        return M[2]
    else
        return M[1]
    end        
end

function monte_new(M, temp)
    n = 10^3
    len = size(M)[1]
    for i=1:n
        a, b = rand(1:len,(1,2))
        spin = M[a,b]
        
        dE = 2*spin*neighbour(M,(a,b))#(M[mod_new(a+1,N),b] + M[a,mod_new(b+1,N)] + M[mod_new(a-1,N),b] + M[a,mod_new(b-1,N)])
            
        tent = minimum_ele([1.0, exp(-dE/temp)])
        
        prob = rand() # rand no between 0 1 uniformly distributed
        
        if tent > prob
            spin = -1*spin
        end
        M[a,b] = spin
    end
    return M
end

function main_new()
    Pts = 65

    temp_arr = LinRange(1,3,Pts)
    
    Erg_array = zeros(Pts,1) #LinRange(0.001,5,Pts)
    Mag_array = zeros(Pts,1) #LinRange(0.001,5,Pts)
    
    len_lat = 200
    Lat = rand((-1,1),(len_lat,len_lat))
            
    for i=1:(10^4)
        Lat = monte_new(Lat,(3+1/i))
    end
 
    for i=1:Pts #annealing
        magn_cal = 0
        erg_cal = 0

        for j=1:10^3 #ensemble average for a given temprature
            Lat = monte(Lat,temp_array[Pts-i+1])
            magn_cal+=magnetization(Lat)
            erg_cal+=energy(Lat)
        end
        Mag_array[i] = magn_cal/((10^3)*len_lat^2)
        Erg_array[i] = erg_cal/((10^3)*len_lat^2)
    end

    
    return reverse(Mag_array), reverse(Erg_array)
end

###########################################################

###########################################################

#function main_new(temp)
    #Pts = 65

    #temp_arr = LinRange(1,3,Pts)
    
    # Erg_array = zeros(Pts,1) #LinRange(0.001,5,Pts)
    # Mag_array = zeros(Pts,1) #LinRange(0.001,5,Pts)

    using GLMakie

    GLMakie.activate!(inline=false)

    len_lat = 75

    data = Observable(rand((-1,1), len_lat, len_lat))

    f, ax, im = heatmap(data, colormap = [:black, :white]; axis = (; aspect = 1,xzoomlock=true,yzoomlock=true), )


    f[2, 1] = buttongrid = GridLayout(tellwidth = false)

    button1 = buttongrid[1,1] = Button(f, label="reset")

    on(button1.clicks) do click1
        data[] = rand((-1,1), len_lat, len_lat)
        #data[][1,1] = false
        notify(data)
    end

    stop_butn = 1

    button2 = buttongrid[1,2] = Button(f, label="stop")

    on(button2.clicks) do click2
        #data[] .= rand((-1,1), 30, 30)
        #data[][1,1] = false
        #notify(data)
        stop_butn = (stop_butn + 1)%2
        #stop_butn = stop_butn%2
    end


    #Lat = rand((-1,1),(len_lat,len_lat))

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
            #data[][index...] = !data[][index...]
            data[][index...] = -1 .* data[][index...]
            notify(data)
        end
    end

    magn_cal = 0
    erg_cal = 0

    temp = 0.5

    deactivate_interaction!(ax, :rectanglezoom,)

    hidedecorations!(ax)
    hidexdecorations!(ax, ticks = false)
    hideydecorations!(ax, ticks = false)


    # while Bool(stop_butn)==true
    #     data[] = monte_new(data[],temp)
    #     magn_cal += magnetization(data[])
    #     erg_cal += energy(data[])
    #     notify(data) 
    #     sleep(0.01)       
    # end

    for i=1:(5*(10^2))
        #Lat = monte_new(Lat,(3+1/i))
        data[] = monte_new(data[],temp)
        magn_cal += magnetization(data[])
        erg_cal += energy(data[])
        notify(data)
        sleep(0.02)
    end



    

    # for i=1:Pts #annealing
    #     magn_cal = 0
    #     erg_cal = 0

    #     for j=1:10^3 #ensemble average for a given temprature
    #         Lat = monte(Lat,temp_array[Pts-i+1])
    #         magn_cal+=magnetization(Lat)
    #         erg_cal+=energy(Lat)
    #     end
    #     Mag_array[i] = magn_cal/((10^3)*len_lat^2)
    #     Erg_array[i] = erg_cal/((10^3)*len_lat^2)
    # end
    #return reverse(Mag_array), reverse(Erg_array)
#end

##################################################################

#main_new(2)

#m = Bool((3,3))



# using Plots

# Ts = temp_array

# n = 70
# Pts = n #no. of points on Energy-Temp graph

# temp_array = LinRange(1,3,Pts)

# tent_arra = main(temp_array,n)
# M_arra, E_arra = tent_arra[1], tent_arra[2];

#plot(temp_array, E_arra, label="Erg_MC", marker="o")
#plot(temp_array, M_arra, label="Mag_MC", marker="v")#,xrange=(2.2,2.5))
