// WhatAState.as

void Reset(CRules@ this)
{
    if (!isServer()) return;

    this.set_bool("is_warmup", true);
	this.Sync("is_warmup", true);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
    Reset(this);
}

void onStateChange(CRules@ this, const u8 oldState)
{
    if(!isServer()) return;

    if(this.getCurrentState() == GAME)
	{
        this.set_bool("is_warmup", false);
	    this.Sync("is_warmup", true);
    }
}