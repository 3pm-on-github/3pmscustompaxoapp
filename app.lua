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
        list1 = gui:vlist(win4, 10, 35, 250, 360)
        for i = 1, sillycats do
            print("silly cat")
            local sillycat = gui:image(list1, "sillycat.png", 10, 2, 100, 100)
        end
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

function pictures()
    win5=gui:window()
    
    local title=gui:label(win5, 10, 10, 288, 28)
    title:setFontSize(17)
    title:setText("pictures")
    local list = storage:listDir("../../pictures/")
    local pathlist = {}
    local shownwarning = false
    for i, item in ipairs(list) do
        itempath = "../../pictures/"..item
        if storage:isDir(itempath) then
            if not shownwarning then
                shownwarning = true
                gui:showWarningMessage("Albums are not supported yet")
            end
            print(itempath..": directory")
        elseif storage:isFile(itempath) then
            print(itempath..": file")
            table.insert(pathlist, itempath)
        else
            gui:showErrorMessage("Error fetching pictures.")
        end
    end
    list2 = gui:vlist(win5, 10, 35, 290, 433)
    for i, path in ipairs(pathlist) do
        local image = gui:image(list2, path, 10, 25, 290, 290)
    end
    gui:setWindow(win5)
end

function readebook(bookpath, page)
    win7=gui:window()

    local titleList = gui:vlist(win7, 10, 40, 290, 390)
    local ebookname = string.sub(bookpath, 14, #bookpath - 4)
    local label = gui:label(titleList, 10, 10, 290, 25)
    label:setFontSize(22)
    label:setText(ebookname)
    
    local starttime = time:monotonic()

    local ebook = storage:file(bookpath, 0)
    ebook:open()
    local ebookcontent = ebook:readAll()
    ebook:close()

    -- Word wrap à 42 caractères max, en coupant aux espaces
    local function split_text_by_word(text, max_chars)
        local lines = {}
        local line = ""

        for word in text:gmatch("%S+") do
            if #line + #word + 1 <= max_chars then
                if line == "" then
                    line = word
                else
                    line = line .. " " .. word
                end
            else
                table.insert(lines, line)
                line = word
            end
        end

        if line ~= "" then
            table.insert(lines, line)
        end

        return lines
    end
    local ebooklinecount = 0
    local allLines = {}
    for paragraph in ebookcontent:gmatch("[^\r\n]+") do
        local lines = split_text_by_word(paragraph, 42)
        for _, l in ipairs(lines) do
            ebooklinecount = ebooklinecount + 1
            table.insert(allLines, l)
        end
    end

    local linesPerPage = 100
    local totalPages = math.ceil(#allLines / linesPerPage)
    local currentPage = math.max(1, math.min(page or 1, totalPages))
    local startIdx = (currentPage - 1) * linesPerPage + 1
    local endIdx = math.min(startIdx + linesPerPage - 1, #allLines)

    for i = startIdx, endIdx do
        local contentLabel = gui:label(titleList, 0, 0, 290, 18)
        contentLabel:setFontSize(16)
        contentLabel:setText(allLines[i])
    end

    if totalPages > 1 then
        if currentPage > 1 then
            local prevBtn = gui:label(titleList, 10, 30, 80, 30)
            prevBtn:setText("previous")
            prevBtn:onClick(function() readebook(bookpath, currentPage - 1) end)
        end

        if currentPage < totalPages then
            local nextBtn = gui:label(titleList, 220, 0, 80, 30)
            nextBtn:setText("next")
            nextBtn:onClick(function() readebook(bookpath, currentPage + 1) end)
        end
    end

    local totaltime = (time:monotonic() - starttime) / 1000
    local estimatedramusage = (ebooklinecount + 6) * 2 -- add + 6 to include the ram usage, title & vlist (it counts as an object)
    local estimatedrampercentageusage = estimatedramusage / 40000
    local estimatedusage = gui:label(win7, 0, 430, 290, 18)
    estimatedusage:setText("estimated "..estimatedramusage.."bytes of ram used ("..estimatedrampercentageusage.."%)")
    estimatedusage:setFontSize(13)
    local loadedtime = gui:label(win7, 0, 443, 290, 18)
    loadedtime:setText("loaded in "..totaltime.."s")
    loadedtime:setFontSize(13)
    local thanks = gui:label(win7, 0, 456, 290, 18)
    thanks:setText("thanks to MFajMaz for repairing the ebook reader")
    thanks:setFontSize(13)

    gui:setWindow(win7)
end

function estimateramusage(bookpath)
    win8=gui:window()
    
    local starttime = time:monotonic()
    local ebooknamelinecount = 0
    local currentline = ""
    local characteri = 0 -- 26 characters max per line
    for i = 1, #string.sub(bookpath,14,#bookpath-4) do
        characteri = characteri + 1
        if characteri == 27 then
            currentline = ""
            ebooknamelinecount = ebooknamelinecount + 1
            characteri = 1
        end
    end
    ebooknamelinecount = ebooknamelinecount + 1

    local ebook = storage:file(bookpath, 0)
    ebook:open()
    local ebookcontent = ebook:readAll()
    ebook:close()

    local characteri = 0 -- 35 characters max per line
    local ebooklinecount = 0
    for i = 1, #ebookcontent do
        local char = string.sub(ebookcontent, i, i)
        characteri = characteri + 1
        if char == "\n" then
            characteri = 0
            ebooklinecount = ebooklinecount + 1
            currentline = ""
        elseif characteri == 36 then
            characteri = 1
            ebooklinecount = ebooklinecount + 1
            currentline = ""
        end
    end
    ebooklinecount = ebooklinecount + 1
    local totaltime = (time:monotonic() - starttime) / 1000
    local estimatedramusage = (ebooklinecount + ebooknamelinecount + 4) * 2 -- add + 4 to include the ram usage & vlist (it counts as an object)
    local estimatedrampercentageusage = estimatedramusage / 40000
    local estimatedusage = gui:label(win8, 10, 10, 360, 18)
    estimatedusage:setText("estimated "..estimatedramusage.."bytes of ram will be used ("..estimatedrampercentageusage.."%)")
    estimatedusage:setFontSize(13)
    local loadedtime = gui:label(win8, 10, 23, 290, 18)
    loadedtime:setText("estimated in "..totaltime.."s")
    loadedtime:setFontSize(13)

    gui:setWindow(win8)
end


function ebooks(estimateram)
    win6=gui:window()
    local title=gui:label(win6, 10, 10, 288, 28)
    title:setFontSize(17)
    title:setText("e-books")
    local list = storage:listDir("../../ebooks/")
    local pathlist = {}
    local shownwarning = false
    for i, item in ipairs(list) do
        itempath = "../../ebooks/"..item
        if storage:isDir(itempath) then
            if not shownwarning then
                shownwarning = true
                gui:showWarningMessage("E-Book Bookshelves are not supported yet")
            end
            print(itempath..": directory")
        elseif storage:isFile(itempath) then
            print(itempath..": file")
            table.insert(pathlist, itempath)
        else
            gui:showErrorMessage("Error fetching e-books.")
        end
    end
    list3 = gui:vlist(win6, 10, 90, 250, 280)
    for i, bookpath in ipairs(pathlist) do
        bookname = string.sub(bookpath,14,#bookpath-4)
        local case = gui:box(list3, 0, 0, 250, 18)
        local name = gui:label(case, 0, 0, 230, 18)
        name:setText(bookname)
        name:setFontSize(16)
        case:onClick(function() if estimateram==0 then readebook(bookpath, 1) else estimateramusage(bookpath) end end)
    end
    gui:setWindow(win6)
end

function run()
    win=gui:window()
    
    local title=gui:label(win, 10, 10, 250, 28)
    title:setFontSize(20)
    title:setText("3pm's random stuff")
    local marketable = gui:image(win, "icon.png", 230, 0, 100, 100)
    
    local sendsillycat = gui:label(win, 10, 50, 144, 20)
    sendsillycat:setFontSize(20)
    sendsillycat:setText("send a silly cat")
    sendsillycat:onClick(function() sendasillycat() end)

    local receivesillycats = gui:label(win, 10, 75, 144, 20)
    receivesillycats:setFontSize(20)
    receivesillycats:setText("receive silly cats")
    receivesillycats:onClick(function() receivethesillycats() end)

    local pictureviewer = gui:label(win, 10, 100, 144, 20)
    pictureviewer:setFontSize(20)
    pictureviewer:setText("picture viewer")
    pictureviewer:onClick(function() pictures() end)

    local ebookreader = gui:label(win, 10, 125, 144, 20)
    ebookreader:setFontSize(20)
    ebookreader:setText("e-book reader")
    ebookreader:onClick(function() ebooks(0) end)

    local ebookramusage = gui:label(win, 10, 150, 260, 20)
    ebookramusage:setFontSize(20)
    ebookramusage:setText("e-book ram usage estimater")
    ebookramusage:onClick(function() ebooks(1) end)

    local madewithheart=gui:label(win, 10, 455, 200, 15)
    madewithheart:setFontSize(15)
    madewithheart:setText("made with <3 by 3pm")

    gui:setWindow(win)
end