local function encodeCharacter(c)
  return string.format("%%%02X", string.byte(c))
end

local function urlencode(str)
  return str and str:gsub("\n", "\r\n"):gsub("([^%w _%%%-%.~])", encodeCharacter):gsub(" ", "+") or str
end

local function urldecode(str)
  if str then
    str = str:gsub("+", " ")
    str = str:gsub("%%(%x%x)", function(h)
      return string.char(tonumber(h, 16))
    end)
    str = str:gsub("\r\n", "\n")
  end
  return str
end

return {
  urlencode = urlencode,
  urldecode = urldecode
}
