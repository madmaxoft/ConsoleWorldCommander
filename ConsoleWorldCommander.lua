
-- ConsoleWorldCommander.lua

-- Implements the main entrypoint to the plugin






function Initialize(a_Plugin)
	a_Plugin:SetName("ConsoleWorldCommander")

	-- Register the commands:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoConsoleCommands()

	return true
end




