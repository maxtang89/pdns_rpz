local function read_rpz_file(filepath)
    local rpz_domains = {}
    for line in io.lines(filepath) do
        if not line:match("^%s*;") and not line:match("^%s*$") then
            local domain = line:match("^(%S+)")
            if domain then
                table.insert(rpz_domains, domain)
            end
        end
    end
    return rpz_domains
end

local rpz_adult = read_rpz_file("/etc/powerdns/adult.txt")
local rpz_hacking = read_rpz_file("/etc/powerdns/hacking.txt")
local rpz_malicious = read_rpz_file("/etc/powerdns/malicious.txt")
-- Redirect domain
local rpz_redirect = "zflow.local"

function preresolve(dq)
    pdnslog("preresolve: " .. dq.remoteaddr:toString() .. " " .. dq.qname:toString())
    -- Except IP CIDR
    local ip_no_rpz = newNMG()
    ip_no_rpz:addMask("0.0.0.1/32")
    ip_no_rpz:addMask("0.0.0.2/32")

    -- Admin IP CIDR
    local ip_admin_rpz = newNMG()
    ip_admin_rpz:addMask("0.0.1.0/24")

    -- Class IP CIDR
    local ip_class_rpz = newNMG()
    ip_class_rpz:addMask("0.10.0.0/16")

    if ip_no_rpz:match(dq.remoteaddr) then
        pdnslog("No RPZ for " .. dq.remoteaddr:toString())
        return false
    elseif ip_admin_rpz:match(dq.remoteaddr) then
        pdnslog("Admin RPZ for " .. dq.remoteaddr:toString())
        for _, domain in ipairs(rpz_adult) do
            if dq.qname:toString():match(domain) then
                dq:addAnswer(pdns.CNAME, rpz_redirect)
                pdnslog("[rpz_adult]Rule Matched: " .. domain)
                return true
            end
        end
        for _, domain in ipairs(rpz_hacking) do
            if dq.qname:toString():match(domain) then
                dq:addAnswer(pdns.CNAME, rpz_redirect)
                pdnslog("[rpz_hacking]Rule Matched: " .. domain)
                return true
            end
        end
        for _, domain in ipairs(rpz_malicious) do
            if dq.qname:toString():match(domain) then
                dq:addAnswer(pdns.CNAME, rpz_redirect)
                pdnslog("[rpz_malicious]Rule Matched: " .. domain)
                return true
            end
        end
    elseif ip_class_rpz:match(dq.remoteaddr) then
        pdnslog("Class IP for " .. dq.remoteaddr:toString())
        for _, domain in ipairs(rpz_adult) do
            if dq.qname:toString():match(domain) then
                dq:addAnswer(pdns.CNAME, rpz_redirect)
                pdnslog("[rpz_adult]Rule Matched: " .. domain)
                return true
            end
        end
        for _, domain in ipairs(rpz_malicious) do
            if dq.qname:toString():match(domain) then
                dq:addAnswer(pdns.CNAME, rpz_redirect)
                pdnslog("[rpz_malicious]Rule Matched: " .. domain)
                return true
            end
        end
        return false
    else
        pdnslog("Other IP: " .. dq.remoteaddr:toString())
        return false
    end
    return false
end