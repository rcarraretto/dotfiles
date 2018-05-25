if string.match(hs.host.localizedName(), 'rc-') then
  require("init_macbook")
else
  require("init_macmini")
end
