
-- Info.lua

-- Declares the plugin metadata, commands, permissions etc.





g_PluginInfo =
{
	Name = "ConsoleWorldCommander",
	Date = "2015-05-28",
	Description =
	[[
		This is a plugin for {%a http://cuberite.org}Cuberite{%/a} that allows admins to manipulate world using console commands.
	]],
	
	SourceLocation = "https://github.com/madmaxoft/ConsoleWorldCommander",
	DownloadLocation = "https://github.com/madmaxoft/ConsoleWorldCommander/archive/master.zip",
	
	ConsoleCommands =
	{
		cwc =
		{
			Subcommands =
			{
				fill =
				{
					HelpString = "Fills the selection with specified blocks",
					Handler = HandleConsoleCmdFill,
					ParameterCombinations =
					{
						{
							Params = "blocktype1 [chance1] [blocktype2] [chance2] ...",
							Help = "Fills the selection with the specified blocktypes. Multiple blocktypes with chances are supported",
						},
					},
				},  -- list

				getblock =
				{
					HelpString = "Logs the type of the block at the specified coordinates",
					Handler = HandleConsoleCmdGetBlock,
					ParameterCombinations =
					{
						{
							Params = "x y z",
							Help = "Logs the block at the specified coordinates",
						},
					},
				},  -- getblock

				["select"] =
				{
					HelpString = "Sets the selection to the specified cuboid",
					Handler = HandleConsoleCmdSelect,
					ParameterCombinations =
					{
						{
							Params = "x1 y1 z1 x2 y2 z1",
							Help = "Sets the selection to the specified cuboid",
						},
					},
				},  -- select

				setblock =
				{
					HelpString = "Sets the specified block",
					Handler = HandleConsoleCmdSetBlock,
					ParameterCombinations =
					{
						{
							Params = "x y z blocktype",
							Help = "Sets the specified block to the specified type",
						},
					},
				},  -- setblock

				world =
				{
					HelpString = "Sets or reports the currently selected world",
					Handler = HandleConsoleCmdWorld,
					ParameterCombinations =
					{
						{
							Params = "",
							Help = "Displays the name of the currently selected world",
						},
						{
							Params = "WorldName",
							Help = "Sets the current world to the specified one",
						},
					},
				},  -- world
			},  -- Subcommands
		},  -- cwc
	},  -- ConsoleCommands
}




