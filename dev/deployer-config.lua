--- @type DeployerUserConfig
local env = require('user-env')
--- run with: deployer --config dev/deployer-config.lua -q -n --watch

--- @type DeploymentConfig
local c = {
  version = "1.0.0",
  name = "DevSuite",
  --- @type table<string, ProjectAddOnInfo>
  addons = {
    ["."] = {
      deploy=true
    },
  },
  deployments = {
    ["classic-era"] = {
      deploy = false,
      dir=env.wow.classic_era.addOnDir
    },
    ["classic"] = {
      deploy = false,
      dir=env.wow.classic.addOnDir
    },
    ["classic-anniversary"] = {
      deploy = true,
      dir=env.wow.classic_anniversary.addOnDir,
    },
    ["retail"] = {
      deploy = false,
      dir=env.wow.retail.addOnDir,
    },
    ["test"] = {
      deploy = false,
      dir=path("%s/Desktop/deployer/wow/", env.home)
    },
  }
}
return c
