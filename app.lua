function sendasillycat()
    win2=gui:window()
    
    print("if anyone sees this, just note that at the time of coding i wasted around 1 hour trying to make this work just to realize i forgot to replace win by win2")

    local title=gui:label(win2, 10, 10, 288, 28)
    title:setFontSize(17)
    title:setText("who do you want to send a silly cat to")

    listO = gui:vlist(win2, 10, 90, 250, 280)

    contactList = gsm:listContacts()
    for i, value in pairs(contactList) do
        local case = gui:box(listO, 0, 0, 250, 36)

        local name = gui:label(case, 0, 0, 230, 18)
        name:setText(value.name)
        name:setFontSize(16)

        local num = gui:label(case, 0, 18, 230, 18)
        num:setText(value.phone)
        num:setTextColor(COLOR_GREY)
        num:setFontSize(16)

        case:onClick(function() gsm.newMessage(value.phone, "3PMSCA:sillycat");run() end)
    end

    gui:setWindow(win2)
end

function receivesillycatz(number)
    win4=gui:window()

    messages = gsm.getMessages(number)

    list = gui:vlist(win4, 20, 76, 280, 320)
    sillycats = 0
    for i, message in pairs(messages) do
        if not message.message:match("/(%d+)%.jpg") and message.message == "3PMSCA:sillycat" and message.who == true then
            print("yipe")
            sillycats = sillycats + 1
        end
    end

    if sillycats == 0 then
        print("no silly cats ;(")
        local title=gui:label(win4, 10, 10, 288, 28)
        title:setFontSize(15)
        title:setText("you didn't receive any silly cats in total ;(")
    else
        print(sillycats.." sillycats in total")
        local title=gui:label(win4, 10, 10, 288, 28)
        title:setFontSize(15)
        title:setText("you received "..sillycats.." silly cats in total")
    end

    gui:setWindow(win4)
end

function receivethesillycats()
    win3=gui:window()

    local title=gui:label(win3, 10, 10, 288, 28)
    title:setFontSize(15)
    title:setText("who do you want to receive silly cats from")

    listO = gui:vlist(win3, 10, 90, 250, 280)

    contactList = gsm:listContacts()
    for i, value in pairs(contactList) do
        local case = gui:box(listO, 0, 0, 250, 36)

        local name = gui:label(case, 0, 0, 230, 18)
        name:setText(value.name)
        name:setFontSize(16)

        local num = gui:label(case, 0, 18, 230, 18)
        num:setText(value.phone)
        num:setTextColor(COLOR_GREY)
        num:setFontSize(16)

        case:onClick(function() receivesillycatz(value.phone) end)
    end

    gui:setWindow(win3)
end

function run()
    win=gui:window()
    
    local title=gui:label(win, 10, 10, 144, 28)
    title:setFontSize(20)
    title:setText("3pm's custom app")
    local marketable = gui:image(win, "icon.png", 230, 0, 100, 100)
    
    
    local sendsillycat = gui:label(win, 10, 50, 144, 20)
    sendsillycat:setFontSize(20)
    sendsillycat:setText("send a silly cat")
    sendsillycat:onClick(function() sendasillycat() end)

    local receivesillycats = gui:label(win, 10, 75, 144, 20)
    receivesillycats:setFontSize(20)
    receivesillycats:setText("receive silly cats")
    receivesillycats:onClick(function() receivethesillycats() end)

    local madewithheart=gui:label(win, 10, 455, 200, 15)
    madewithheart:setFontSize(15)
    madewithheart:setText("made with <3 by 3pm")

    gui:setWindow(win)
end