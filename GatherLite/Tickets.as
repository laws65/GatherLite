shared class Tickets
{
	private uint blueTickets = 0;
	private uint redTickets = 0;
	private uint ticketsPerPlayer;

	Tickets(CBitStream@ bs)
	{
		blueTickets = bs.read_u32();
		redTickets = bs.read_u32();
		ticketsPerPlayer = bs.read_u32();
	}

	void Reset()
	{
		uint playerCount = getGatherMatch().getPlayerCount();
		uint tickets = (playerCount * ticketsPerPlayer) / 2;

		SetBlueTickets(tickets);
		SetRedTickets(tickets);
	}

	void Clear()
	{
		SetBlueTickets(0);
		SetRedTickets(0);
	}

	uint getBlueTickets()
	{
		return blueTickets;
	}

	uint getRedTickets()
	{
		return redTickets;
	}

	uint getTickets(u8 team)
	{
		switch (team)
		{
			case 0:
				return getBlueTickets();
			case 1:
				return getRedTickets();
		}
		return 0;
	}

	void SetBlueTickets(uint tickets)
	{
		blueTickets = tickets;
	}

	void SetRedTickets(uint tickets)
	{
		redTickets = tickets;
	}

	void SetTickets(u8 team, uint tickets)
	{
		switch (team)
		{
			case 0:
				SetBlueTickets(tickets);
				break;
			case 1:
				SetRedTickets(tickets);
				break;
		}
	}

	bool hasTickets(u8 team)
	{
		return getTickets(team) > 0;
	}

	bool canDecrementTickets()
	{
		return getGatherMatch().isLive() && getRules().isMatchRunning();
	}

	void DecrementTickets(u8 team)
	{
		if (canDecrementTickets())
		{
			if (hasTickets(team))
			{
				uint tickets = getTickets(team);
				SetTickets(team, tickets - 1);
			}
		}
	}

	void PlaySound(CPlayer@ victim)
	{
		//this is most likely called before victim blob is removed, if they were alive

		GatherMatch@ gatherMatch = getGatherMatch();
		u8 team = victim.getTeamNum();
		uint tickets = getTickets(team);

		int calcTickets = tickets - gatherMatch.getDeadCount(team);
		uint teamSize = gatherMatch.getTeamSize(team);

		if (calcTickets <= 0)
		{
			Sound::Play("depleted.ogg");
		}
		else if (calcTickets <= teamSize)
		{
			Sound::Play("depleting.ogg");
		}
	}

	void LoadConfig(ConfigFile@ cfg)
	{
		ticketsPerPlayer = cfg.read_u32("tickets_per_player", 8);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u32(blueTickets);
		bs.write_u32(redTickets);
		bs.write_u32(ticketsPerPlayer);
	}
}
