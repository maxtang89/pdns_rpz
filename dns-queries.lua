local adult_protect = newNMG()
adult_protect:addMask("1.1.1.1/32")

local no_hacking_protect = newNMG()
no_hacking_protect:addMask("1.1.1.2/32")


function prerpz(dq)
    if not adult_protect:match(dq.remoteaddr) then
        dq:discardPolicy("adult-protection")
    end
    if no_hacking_protect:match(dq.remoteaddr) then
        dq:discardPolicy("hacking-protection")
    end
    local tags = table.concat(dq:getPolicyTags(), ", ")
    pdnslog("preresolve: " .. dq.remoteaddr:toString() .. " to: " .. dq.qname:toString())
    return false
end