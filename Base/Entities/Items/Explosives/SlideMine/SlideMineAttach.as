// SlideMineAttach.as

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
    if (!isServer()) return;

    if (this !is null && attached !is null) {
        if (attached.getConfig() == "slidemine") {
            attached.set_u8("mine_priming_time", 5);
        }
    }
}