// CheckLimits.as

// initialization limits
int archers_limit;
int builders_limit;

void onTick (CBlob@ this) {
    CRules@ rules = getRules();

    archers_limit = rules.get_u8("archers_limit");
    builders_limit = rules.get_u8("builders_limit");

    if (getControls().isKeyJustPressed(KEY_LSHIFT)) {
        printf("Archer class limits: " + archers_limit);
        printf("Builder class limits: " + builders_limit);
    }
}